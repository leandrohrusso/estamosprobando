import { defineConfig } from 'vitest/config'

// =====================================================================
// vitest config · scope acotado a tests unitarios
// ---------------------------------------------------------------------
// Necesario para que vitest NO levante los specs de Playwright
// (`tests/e2e/**/*.spec.ts` importan @playwright/test). Vitest corre solo
// `tests/unit/**/*.test.ts`; Playwright corre `**/*.spec.ts` (su config).
// =====================================================================

export default defineConfig({
  test: {
    include: ['tests/unit/**/*.test.ts'],
    environment: 'node',
  },
})
