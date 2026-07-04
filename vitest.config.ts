import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vitest/config'

// =====================================================================
// vitest config · scope acotado a tests unitarios
// ---------------------------------------------------------------------
// Necesario para que vitest NO levante los specs de Playwright
// (`tests/e2e/**/*.spec.ts` importan @playwright/test). Vitest corre solo
// `tests/unit/**/*.test.ts`; Playwright corre `**/*.spec.ts` (su config).
//
// Alias `@/` → `./src` (paridad con tsconfig paths): habilita testear módulos
// que importan por alias (ej. `session.ts` → `@/lib/supabase/server`), mockeando
// sus deps con vi.mock (LR-002 · regresión de fetchActiveMemberships).
// =====================================================================

export default defineConfig({
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  test: {
    include: ['tests/unit/**/*.test.ts'],
    environment: 'node',
  },
})
