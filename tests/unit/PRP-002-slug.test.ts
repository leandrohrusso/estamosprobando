import { describe, it, expect } from 'vitest'
import { slugify, isReservedSlug, RESERVED_SLUGS } from '../../src/lib/auth/slug'

// PRP-002 Fase 3 · slug determinístico + guard de slugs reservados. El guard
// evita que una org tome una ruta estática de primer nivel (`/{orgSlug}/...`
// comparte raíz con /login · /auth · etc · colisión introducida por el route
// group (org) de Fase 3).
describe('slugify', () => {
  it('normaliza a lowercase + guiones simples, sin diacríticos ni bordes', () => {
    expect(slugify('Productora La Puerta')).toBe('productora-la-puerta')
    expect(slugify('  Café & Föo!!  ')).toBe('cafe-foo')
    expect(slugify('---héllo---')).toBe('hello')
  })

  it('es determinístico (misma entrada → mismo slug)', () => {
    expect(slugify('Org Test 42')).toBe(slugify('Org Test 42'))
  })
})

describe('isReservedSlug', () => {
  it('marca las rutas estáticas de primer nivel como reservadas', () => {
    for (const reserved of RESERVED_SLUGS) {
      expect(isReservedSlug(reserved)).toBe(true)
    }
    expect(isReservedSlug('login')).toBe(true)
    expect(isReservedSlug('auth')).toBe(true)
  })

  it('no marca slugs normales', () => {
    expect(isReservedSlug('productora-la-puerta')).toBe(false)
    expect(isReservedSlug('mi-organizacion')).toBe(false)
  })
})
