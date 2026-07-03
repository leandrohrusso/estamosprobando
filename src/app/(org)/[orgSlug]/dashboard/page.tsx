import { requireMembership } from '@/lib/auth/org'
import { roleLabel } from '@/lib/auth/roles'

/**
 * Dashboard de la organización · destino del redirect post-login (SD-cos-9) y
 * del onboarding. Shell mínimo en esta fase: las métricas de ventas/ingresos
 * (≤5 KPIs · regla principios-desarrollo-flujo #30) llegan en TASK-011.
 */
export default async function DashboardPage({
  params,
}: {
  params: Promise<{ orgSlug: string }>
}) {
  const { orgSlug } = await params
  const membership = await requireMembership(orgSlug)

  return (
    <section className="flex flex-col gap-2">
      <h1 className="text-h1 font-bold text-primary">{membership.name}</h1>
      <p className="text-body-lg text-fg-2">
        Este es el panel de tu organización. Desde acá vas a publicar eventos y
        vender entradas.
      </p>
      <p className="text-small text-fg-4">Tu rol: {roleLabel(membership.role)}</p>
    </section>
  )
}
