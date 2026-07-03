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

type ServerClient = Awaited<ReturnType<typeof createClient>>

/**
 * `true` si la membership existe en la org y **no** es Owner → mutable desde la
 * UI. El Owner es inmutable acá (anti-lockout · nunca dejamos la org sin dueño ·
 * ver `assignableRoleSchema`). El scoping por `organization_id` es defensa extra
 * sobre la policy `mbr_write` (que ya restringe la escritura al Owner de la org).
 */
async function isManageableTarget(
  supabase: ServerClient,
  organizationId: string,
  membershipId: string,
): Promise<boolean> {
  const { data } = await supabase
    .from('memberships')
    .select('role')
    .eq('id', membershipId)
    .eq('organization_id', organizationId)
    .maybeSingle()
  return Boolean(data && data.role !== 'owner')
}

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
 * Cambia el rol de un miembro (admin ↔ staff). No toca al Owner (inmutable ·
 * anti-lockout). Silencioso ante input inválido/target no manejable: la UI ya
 * oculta los controles del Owner · esto es defensa server-side.
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
  if (
    !(await isManageableTarget(
      supabase,
      membership.organizationId,
      parsed.data.membershipId,
    ))
  ) {
    return
  }

  await supabase
    .from('memberships')
    .update({ role: parsed.data.role })
    .eq('id', parsed.data.membershipId)
    .eq('organization_id', membership.organizationId)

  revalidatePath(`/${orgSlug}/members`)
}

/** Baja de un miembro. No toca al Owner (inmutable · anti-lockout). */
export async function removeMember(formData: FormData): Promise<void> {
  const parsed = removeMemberSchema.safeParse({
    membershipId: formData.get('membershipId'),
  })
  if (!parsed.success) return

  const orgSlug = String(formData.get('orgSlug') ?? '')
  const membership = await requireRole(orgSlug, ['owner'])

  const supabase = await createClient()
  if (
    !(await isManageableTarget(
      supabase,
      membership.organizationId,
      parsed.data.membershipId,
    ))
  ) {
    return
  }

  await supabase
    .from('memberships')
    .delete()
    .eq('id', parsed.data.membershipId)
    .eq('organization_id', membership.organizationId)

  revalidatePath(`/${orgSlug}/members`)
}
