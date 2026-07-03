import { getOrgMembers, requireRole } from '@/lib/auth/org'
import { MembersManager } from './members-manager'

/**
 * Gestión de miembros · Owner-only (G6 · `requireRole` bloquea a admin/staff
 * devolviéndolos a su dashboard). Lista los miembros (activos + pendientes) y
 * expone alta/baja/cambio de rol (Bif 3=A). El Owner es inmutable desde acá
 * (anti-lockout · ver actions + schemas).
 */
export default async function MembersPage({
  params,
}: {
  params: Promise<{ orgSlug: string }>
}) {
  const { orgSlug } = await params
  const membership = await requireRole(orgSlug, ['owner'])
  const members = await getOrgMembers(membership.organizationId)

  return (
    <section className="flex flex-col gap-6">
      <div className="flex flex-col gap-1">
        <h1 className="text-h1 font-bold text-primary">Miembros</h1>
        <p className="text-body-lg text-fg-2">
          Gestioná quién tiene acceso a {membership.name}.
        </p>
      </div>
      <MembersManager orgSlug={orgSlug} members={members} />
    </section>
  )
}
