import { createClient } from '@/lib/supabase/server'
import type { User } from '@supabase/supabase-js'

export type MembershipRole = 'owner' | 'admin' | 'staff'

/** Membership activa del usuario en sesión + slug/nombre de su organización. */
export type ActiveMembership = {
  organizationId: string
  role: MembershipRole
  slug: string
  name: string
}

/**
 * Devuelve el usuario autenticado (o `null`). Usa `getUser()` (valida contra el
 * servidor de Auth) · nunca `getSession()` desde el servidor (confía en la
 * cookie sin validar).
 */
export async function getSessionUser(): Promise<User | null> {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  return user
}

/**
 * Memberships `active` **propias** del usuario en sesión (filtro explícito por
 * `user_id` · no las de otros miembros de sus orgs que RLS también dejaría ver).
 * Base del algoritmo de redirect post-login (SD-cos-9).
 */
export async function getActiveMemberships(): Promise<ActiveMembership[]> {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) return []

  const { data, error } = await supabase
    .from('memberships')
    .select('organization_id, role, organizations!inner(slug, name)')
    .eq('user_id', user.id)
    .eq('status', 'active')

  // Un error real (permission-denied de RLS · timeout · embed roto) NO es lo
  // mismo que "el usuario no tiene orgs": colapsarlo a `[]` mandaría a un usuario
  // CON organización a crear una nueva (segunda org / slug duplicado). Lo
  // propagamos para que el caller decida (típicamente volver a /login).
  if (error) {
    throw new Error(`getActiveMemberships: ${error.message}`)
  }

  return (data ?? []).map((row) => {
    // el join to-one llega como objeto; algunos tipados lo infieren como array
    const org = Array.isArray(row.organizations)
      ? row.organizations[0]
      : row.organizations
    return {
      organizationId: row.organization_id,
      role: row.role as MembershipRole,
      slug: org.slug as string,
      name: org.name as string,
    }
  })
}
