import type { ActiveMembership } from '@/lib/auth/session'

/**
 * Algoritmo de redirect post-login (SD-cos-9), a partir de las memberships
 * `active` propias del usuario:
 * - **0** → `/onboarding` (usuario nuevo · crea su organización).
 * - **1** → `/{slug}/dashboard` de esa organización.
 * - **≥2** → `/select-organization` (elige con cuál entrar).
 *
 * En Fase 3 este módulo suma `requireMembership(slug)` / `requireRole(slug, roles)`
 * para los layouts server del contexto de organización.
 */
export function resolvePostLoginRedirect(
  memberships: ActiveMembership[],
): string {
  if (memberships.length === 0) return '/onboarding'
  if (memberships.length === 1) return `/${memberships[0].slug}/dashboard`
  return '/select-organization'
}
