import { describe, it, expect, beforeEach, vi } from 'vitest'

// LR-002 lr_bug_005 (hermano de LR-001) · `getActiveMemberships` NO debe colapsar
// un error real de la query a `[]`: hacerlo mandaría a un usuario CON organización a
// crear una segunda (mismo bug que expulsaba al usuario a /onboarding ante un fallo
// transitorio). Regresamos la lógica en `fetchActiveMemberships` (uncached).
//
// `react`.cache se mockea a identidad: getSessionUser está envuelto en cache() (solo
// corre en RSC) · en node lo queremos como función plana.
vi.mock('react', () => ({ cache: <T>(fn: T): T => fn }))

const state = vi.hoisted(() => ({
  user: null as { id: string } | null,
  result: { data: null as unknown, error: null as unknown },
}))

vi.mock('@/lib/supabase/server', () => ({
  createClient: async () => ({
    auth: { getUser: async () => ({ data: { user: state.user } }) },
    from: () => {
      const chain = {
        select: () => chain,
        eq: () => chain,
        then: (resolve: (v: unknown) => void) => resolve(state.result),
      }
      return chain
    },
  }),
}))

import { fetchActiveMemberships } from '../../src/lib/auth/session'

beforeEach(() => {
  state.user = null
  state.result = { data: null, error: null }
})

describe('fetchActiveMemberships · error ≠ vacío', () => {
  it('sin sesión devuelve [] (no consulta)', async () => {
    state.user = null
    await expect(fetchActiveMemberships()).resolves.toEqual([])
  })

  it('un error real de la query se PROPAGA (no se colapsa a [])', async () => {
    state.user = { id: 'u1' }
    state.result = { data: null, error: { message: 'permission denied' } }
    await expect(fetchActiveMemberships()).rejects.toThrow(/permission denied/)
  })

  it('mapea las filas a ActiveMembership cuando hay datos', async () => {
    state.user = { id: 'u1' }
    state.result = {
      data: [
        {
          organization_id: 'org-1',
          role: 'owner',
          organizations: { slug: 'mi-org', name: 'Mi Org' },
        },
      ],
      error: null,
    }
    await expect(fetchActiveMemberships()).resolves.toEqual([
      { organizationId: 'org-1', role: 'owner', slug: 'mi-org', name: 'Mi Org' },
    ])
  })
})
