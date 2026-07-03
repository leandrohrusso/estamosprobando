import { notFound, redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import {
  getActiveMemberships,
  getSessionUser,
  type ActiveMembership,
  type MembershipRole,
} from '@/lib/auth/session'

/**
 * Algoritmo de redirect post-login (SD-cos-9), a partir de las memberships
 * `active` propias del usuario:
 * - **0** → `/onboarding` (usuario nuevo · crea su organización).
 * - **1** → `/{slug}/dashboard` de esa organización.
 * - **≥2** → `/select-organization` (elige con cuál entrar).
 */
export function resolvePostLoginRedirect(
  memberships: ActiveMembership[],
): string {
  if (memberships.length === 0) return '/onboarding'
  if (memberships.length === 1) return `/${memberships[0].slug}/dashboard`
  return '/select-organization'
}

/**
 * Guard de layout server para el contexto de organización (SD-cos-7: la authz
 * vive en el server component, no en el proxy edge). Exige que el usuario en
 * sesión sea miembro `active` de la org identificada por `slug`.
 * - sin sesión → `/login`
 * - con sesión pero no miembro activo de esa org → `notFound()` (404 · no
 *   revelamos si la org existe a quien no pertenece).
 *
 * En el happy-path (usuario miembro) resuelve con una sola llamada a Auth
 * (`getActiveMemberships` cachea `getSessionUser`); el doble round-trip solo
 * ocurre en el path de fallo (raro).
 */
export async function requireMembership(
  slug: string,
): Promise<ActiveMembership> {
  const memberships = await getActiveMemberships()
  const membership = memberships.find((m) => m.slug === slug)
  if (membership) return membership

  // No es miembro activo de esta org: distinguir "no hay sesión" (→ login) de
  // "hay sesión pero no pertenece" (→ 404) para no mandar a login a un usuario
  // logueado que solo se equivocó de slug.
  const user = await getSessionUser()
  if (!user) redirect('/login')
  notFound()
}

/**
 * Guard de rol dentro de una org. Exige membership `active` (delegando en
 * `requireMembership`) **y** que el rol esté en `roles`. Si el usuario pertenece
 * a la org pero le falta el rol, lo devolvemos a su dashboard de esa org
 * (bloqueado sin filtrar la existencia de la sección · un miembro legítimo no
 * merece un 404 críptico). Base del RBAC gate (G6).
 */
export async function requireRole(
  slug: string,
  roles: MembershipRole[],
): Promise<ActiveMembership> {
  const membership = await requireMembership(slug)
  if (!roles.includes(membership.role)) redirect(`/${slug}/dashboard`)
  return membership
}

/** Fila de miembro para la pantalla de gestión (`/{slug}/members`). */
export type OrgMember = {
  id: string
  email: string
  role: MembershipRole
  status: 'pending' | 'active'
  /** El propio usuario en sesión: se muestra sin controles de acción. */
  isSelf: boolean
}

/**
 * Miembros de una organización (activos + `pending`) para la pantalla de
 * gestión. RLS (`mbr_select`) ya restringe la lectura a miembros activos de la
 * org · el caller (`/members`) además exige rol Owner (`requireRole`).
 *
 * Orden: **pendientes primero** (invitaciones sin vincular · piden acción),
 * luego activos, y por email dentro de cada grupo. El orden se hace en JS y no
 * en la BD a propósito: ordenar por la columna `status` usa el orden de
 * declaración del enum (`pending` < `active`), un acoplamiento frágil al schema.
 */
export async function getOrgMembers(
  organizationId: string,
): Promise<OrgMember[]> {
  const supabase = await createClient()
  const user = await getSessionUser()

  const { data, error } = await supabase
    .from('memberships')
    .select('id, email, role, status, user_id')
    .eq('organization_id', organizationId)
    .order('email', { ascending: true })

  if (error) {
    throw new Error(`getOrgMembers: ${error.message}`)
  }

  const members: OrgMember[] = (data ?? []).map((row) => ({
    id: row.id as string,
    email: row.email as string,
    role: row.role as MembershipRole,
    status: row.status as 'pending' | 'active',
    isSelf: Boolean(user && row.user_id === user.id),
  }))

  // Pendientes primero (piden acción) · email ya viene ordenado de la BD.
  return members.sort((a, b) => {
    if (a.status === b.status) return 0
    return a.status === 'pending' ? -1 : 1
  })
}
