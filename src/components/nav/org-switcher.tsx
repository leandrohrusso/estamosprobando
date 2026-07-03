'use client'

import { useRouter } from 'next/navigation'
import type { ActiveMembership } from '@/lib/auth/session'

/**
 * Selector de organización (G7). Solo tiene sentido con ≥2 memberships · con 1
 * o 0 no renderiza nada. Al cambiar, navega al dashboard de la org elegida
 * (`/{slug}/dashboard`) · el contexto de tenant lo resuelve el layout server.
 */
export function OrgSwitcher({
  memberships,
  currentSlug,
}: {
  memberships: ActiveMembership[]
  currentSlug: string
}) {
  const router = useRouter()

  if (memberships.length < 2) return null

  return (
    <select
      aria-label="Cambiar de organización"
      value={currentSlug}
      onChange={(e) => router.push(`/${e.target.value}/dashboard`)}
      className="h-9 rounded-md border border-input bg-background px-2 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
    >
      {memberships.map((m) => (
        <option key={m.organizationId} value={m.slug}>
          {m.name}
        </option>
      ))}
    </select>
  )
}
