import { describe, it, expect } from 'vitest'
import {
  slugify,
  slugCandidate,
  isReservedSlug,
  MAX_SLUG_LENGTH,
  RESERVED_SLUGS,
} from '../../src/lib/auth/slug'

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

// LR-002 · unicidad de slug: el candidato por intento resuelve colisiones con
// sufijo `-n` (SD-cos-8). Pura + testeada · antes solo se cubría slugify().
describe('slugCandidate', () => {
  it('n=1 devuelve el base sin sufijo', () => {
    expect(slugCandidate('mi-org', 1)).toBe('mi-org')
  })

  it('n>=2 agrega sufijo -n (colisión de unicidad)', () => {
    expect(slugCandidate('mi-org', 2)).toBe('mi-org-2')
    expect(slugCandidate('mi-org', 3)).toBe('mi-org-3')
  })

  it('respeta MAX_SLUG_LENGTH recortando el base', () => {
    const base = 'a'.repeat(MAX_SLUG_LENGTH)
    const candidate = slugCandidate(base, 2)
    expect(candidate.length).toBeLessThanOrEqual(MAX_SLUG_LENGTH)
    expect(candidate.endsWith('-2')).toBe(true)
  })

  it('no deja doble guión si el recorte cae sobre un guión (foo--2)', () => {
    // base de 62 chars terminando en guión: slice(0, 61) dejaría el guión colgando.
    const base = `${'a'.repeat(60)}-b` // 62 chars
    const candidate = slugCandidate(base, 2)
    expect(candidate).not.toContain('--')
    expect(candidate.endsWith('-2')).toBe(true)
  })
})
