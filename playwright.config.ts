import { defineConfig, devices } from '@playwright/test'

const PORT = process.env.PORT ?? '3000'
const BASE_URL = process.env.PLAYWRIGHT_BASE_URL ?? `http://localhost:${PORT}`

export default defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.ts',
  testIgnore: ['**/_archive/**'],
  globalSetup: './tests/global-setup.ts',
  // Outputs (videos · traces · screenshots de fallos · `.last-run.json`)
  // van dentro de `tests/` para mantener la raíz limpia.
  outputDir: './tests/test-results',
  // Tests pueden tocar la misma BD; evitamos contención con un solo worker
  // hasta que el proyecto tenga cleanup transaccional o test DB aislada.
  // Subir `workers` opt-in cuando la cobertura E2E sea concurrent-safe.
  fullyParallel: false,
  workers: 1,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? [['github'], ['list']] : 'list',
  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  // Si no hay un server corriendo en BASE_URL, arranca `npm run dev`.
  // En local con un server propio, lo reusa. En CI conviene pre-warmar
  // el server en un step previo (Turbopack/SWC compila las rutas críticas
  // antes de Playwright para evitar races de hidratación) → `reuseExistingServer: true`
  // garantiza que Playwright reuse ese server en lugar de arrancar otro y chocar puerto.
  webServer: {
    command: 'npm run dev',
    url: BASE_URL,
    reuseExistingServer: true,
    timeout: 120_000,
  },
})
