import { requireMembership } from '@/lib/auth/org'
import { getActiveMemberships } from '@/lib/auth/session'
import { AppNav } from '@/components/nav/app-nav'

/**
 * Layout del contexto de organización `/{orgSlug}/...` (SD-cos-5/7). Ejerce el
 * guard de pertenencia en el server (`requireMembership` → `/login` sin sesión ·
 * `notFound()` si no es miembro activo de la org) y monta el shell con la nav.
 * Las páginas hijas re-validan (defensa · `getActiveMemberships` cachea, cero
 * round-trip extra) y añaden su gate de rol cuando corresponde (`/members`).
 */
export default async function OrgLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ orgSlug: string }>
}) {
  const { orgSlug } = await params
  const current = await requireMembership(orgSlug)
  const memberships = await getActiveMemberships()

  return (
    <div className="min-h-screen bg-background">
      <AppNav current={current} memberships={memberships} />
      <main className="mx-auto max-w-4xl px-4 py-8">{children}</main>
    </div>
  )
}
