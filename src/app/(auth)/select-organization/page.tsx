import Link from 'next/link'
import { redirect } from 'next/navigation'
import { getActiveMemberships, getSessionUser } from '@/lib/auth/session'
import { resolvePostLoginRedirect } from '@/lib/auth/org'
import { roleLabel } from '@/lib/auth/roles'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'

/**
 * Selección de organización (happy path 3 · multi-org). Se llega acá cuando el
 * usuario tiene ≥2 memberships activas (SD-cos-9). Con 0 o 1 no hay nada que
 * elegir → se reusa `resolvePostLoginRedirect` para mandar a onboarding o al
 * único dashboard (idempotente si alguien entra directo a la URL).
 */
export default async function SelectOrganizationPage() {
  // Paridad con onboarding/page (LR-002 lr_bug_003): gate de sesión + distinguir
  // "fallo real de la query" de "sin orgs". Sin esto, un error de la query crashea
  // la página (500) en vez de degradar a /login, y un usuario sin sesión da un hop
  // indirecto en vez de ir directo a /login.
  const user = await getSessionUser()
  if (!user) redirect('/login')

  let memberships
  try {
    memberships = await getActiveMemberships()
  } catch {
    redirect('/login?error=session')
  }

  if (memberships.length < 2) {
    redirect(resolvePostLoginRedirect(memberships))
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-background p-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Elegí una organización</CardTitle>
          <CardDescription>
            Pertenecés a varias. Entrá a la que quieras gestionar.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ul className="flex flex-col gap-2">
            {memberships.map((m) => (
              <li key={m.organizationId}>
                <Link
                  href={`/${m.slug}/dashboard`}
                  className="flex items-center justify-between rounded-md border border-input px-4 py-3 hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
                >
                  <span className="font-medium">{m.name}</span>
                  <span className="text-small text-fg-4">
                    {roleLabel(m.role)}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        </CardContent>
      </Card>
    </main>
  )
}
