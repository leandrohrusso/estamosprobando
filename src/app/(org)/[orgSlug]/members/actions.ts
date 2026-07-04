'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { requireRole } from '@/lib/auth/org'
import {
  addMemberSchema,
  changeRoleSchema,
  removeMemberSchema,
} from '@/lib/auth/schemas'

export type AddMemberState = {
  status: 'idle' | 'error' | 'added'
  message?: string
  email?: string
}

/** Código Postgres de unique_violation (email ya miembro/invitado en la org). */
const UNIQUE_VIOLATION = '23505'

/**
 * Alta de miembro por email + rol (Bif 3=A · happy path 2). Crea una membership
 * `pending` con `user_id` NULL · se vincula al login de esa persona
 * (`link_pending_memberships` · SD-cos-2). Sin envío de email (link compartido a
 * mano · el envío automático llega en TASK-008).
 */
export async function addMember(
  _prev: AddMemberState,
  formData: FormData,
): Promise<AddMemberState> {
  const parsed = addMemberSchema.safeParse({
    email: formData.get('email'),
    role: formData.get('role'),
  })
  if (!parsed.success) {
    return { status: 'error', message: parsed.error.issues[0].message }
  }

  const orgSlug = String(formData.get('orgSlug') ?? '')
  const membership = await requireRole(orgSlug, ['owner'])

  const supabase = await createClient()
  const { error } = await supabase.from('memberships').insert({
    organization_id: membership.organizationId,
    email: parsed.data.email,
    role: parsed.data.role,
    status: 'pending',
  })

  if (error) {
    if (error.code === UNIQUE_VIOLATION) {
      return {
        status: 'error',
        message: 'Ese email ya es miembro o está invitado.',
      }
    }
    return {
      status: 'error',
      message: 'No pudimos agregar al miembro. Probá de nuevo.',
    }
  }

  revalidatePath(`/${orgSlug}/members`)
  return { status: 'added', email: parsed.data.email }
}

/**
 * Cambia el rol de un miembro (admin ↔ staff). El Owner es inmutable (anti-lockout):
 * el filtro `.neq('role', 'owner')` va en el propio UPDATE, así el "no tocar al
 * Owner" y la escritura son **una sola operación atómica** (sin ventana TOCTOU de un
 * SELECT-then-write) · defensa que se suma a la policy `mbr_write` (owner-gated +
 * role<>'owner'). Un fallo REAL de la BD se propaga (no se colapsa a no-op silencioso
 * · LR-002 lr_bug_001): distinguimos "no había nada que tocar" (0 filas · Owner o
 * inexistente) de "la escritura falló".
 */
export async function changeRole(formData: FormData): Promise<void> {
  const parsed = changeRoleSchema.safeParse({
    membershipId: formData.get('membershipId'),
    role: formData.get('role'),
  })
  if (!parsed.success) return

  const orgSlug = String(formData.get('orgSlug') ?? '')
  const membership = await requireRole(orgSlug, ['owner'])

  const supabase = await createClient()
  const { error } = await supabase
    .from('memberships')
    .update({ role: parsed.data.role })
    .eq('id', parsed.data.membershipId)
    .eq('organization_id', membership.organizationId)
    .neq('role', 'owner')

  if (error) {
    // Fallo real de escritura (RLS inesperada · conexión) ≠ "target no manejable":
    // propagar en vez de revalidar como si hubiera funcionado (falsa sensación de éxito).
    throw new Error(`changeRole: ${error.message}`)
  }

  revalidatePath(`/${orgSlug}/members`)
}

/**
 * Baja de un miembro. El Owner es inmutable (anti-lockout): el filtro
 * `.neq('role', 'owner')` va en el propio DELETE (atómico · sin SELECT previo). Un
 * fallo REAL de la BD se propaga (LR-002 lr_bug_001 · no swallow silencioso).
 */
export async function removeMember(formData: FormData): Promise<void> {
  const parsed = removeMemberSchema.safeParse({
    membershipId: formData.get('membershipId'),
  })
  if (!parsed.success) return

  const orgSlug = String(formData.get('orgSlug') ?? '')
  const membership = await requireRole(orgSlug, ['owner'])

  const supabase = await createClient()
  const { error } = await supabase
    .from('memberships')
    .delete()
    .eq('id', parsed.data.membershipId)
    .eq('organization_id', membership.organizationId)
    .neq('role', 'owner')

  if (error) {
    throw new Error(`removeMember: ${error.message}`)
  }

  revalidatePath(`/${orgSlug}/members`)
}
