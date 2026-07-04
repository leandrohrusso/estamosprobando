import Link from 'next/link'
import type { ActiveMembership } from '@/lib/auth/session'
import { OrgSwitcher } from '@/components/nav/org-switcher'

/**
 * Barra de navegación del contexto de organización (shell del backoffice ·
 * Claude Design SKIP firmado · primitivos del DS directo). Muestra el nombre de
 * la org, los links de navegación (Miembros solo para Owner · RBAC surface G6),
 * y el selector de organización cuando el usuario pertenece a ≥2 (G7).
 */
export function AppNav({
  current,
  memberships,
}: {
  current: ActiveMembership
  memberships: ActiveMembership[]
}) {
  return (
    <header className="border-b border-border bg-card">
      <div className="mx-auto flex max-w-4xl items-center gap-4 px-4 py-3">
        <span className="font-semibold text-card-foreground">{current.name}</span>
        <nav className="flex items-center gap-4 text-sm">
          <Link
            href={`/${current.slug}/dashboard`}
            className="text-muted-foreground hover:text-foreground"
          >
            Panel
          </Link>
          {current.role === 'owner' ? (
            <Link
              href={`/${current.slug}/members`}
              className="text-muted-foreground hover:text-foreground"
            >
              Miembros
            </Link>
          ) : null}
        </nav>
        <div className="ml-auto">
          <OrgSwitcher memberships={memberships} currentSlug={current.slug} />
        </div>
      </div>
    </header>
  )
}
