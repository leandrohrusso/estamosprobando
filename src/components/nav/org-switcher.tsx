'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import type { ActiveMembership } from '@/lib/auth/session'
import { Button } from '@/components/ui/button'

/**
 * Selector de organización (G7). Solo tiene sentido con ≥2 memberships · con 1
 * o 0 no renderiza nada. La navegación ocurre solo al **confirmar** (submit del
 * form · botón "Cambiar" o Enter), NO en cada `onChange` del select (LR-002
 * lr_bug_004 · WCAG 3.2.2 On Input): así un usuario de teclado puede recorrer las
 * opciones con las flechas sin ser sacado de la página antes de elegir.
 */
export function OrgSwitcher({
  memberships,
  currentSlug,
}: {
  memberships: ActiveMembership[]
  currentSlug: string
}) {
  const router = useRouter()
  const [selected, setSelected] = useState(currentSlug)

  if (memberships.length < 2) return null

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        if (selected !== currentSlug) router.push(`/${selected}/dashboard`)
      }}
      className="flex items-center gap-2"
    >
      <select
        aria-label="Cambiar de organización"
        value={selected}
        onChange={(e) => setSelected(e.target.value)}
        className="h-9 rounded-md border border-input bg-background px-2 text-sm text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
      >
        {memberships.map((m) => (
          <option key={m.organizationId} value={m.slug}>
            {m.name}
          </option>
        ))}
      </select>
      <Button type="submit" variant="ghost" size="sm">
        Cambiar
      </Button>
    </form>
  )
}
