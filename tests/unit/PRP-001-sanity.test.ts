import { describe, it, expect } from 'vitest'
import { createClient } from '../../src/lib/supabase/client'

// Smoke del scaffold (PRP-001 Fase 3): valida que el harness de vitest corre y
// que el módulo del cliente Supabase browser compila e importa, exponiendo su
// factory. NO invoca el cliente (eso requiere env real · TASK-002).
describe('scaffold sanity', () => {
  it('el cliente Supabase browser exporta una factory', () => {
    expect(typeof createClient).toBe('function')
  })
})
