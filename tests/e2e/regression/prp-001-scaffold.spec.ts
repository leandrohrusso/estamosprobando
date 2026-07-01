import { test, expect } from '@playwright/test'

// Smoke E2E del scaffold (PRP-001 Fase 3): la home responde 200 y rinde el
// placeholder de PUERTITA. Página estática · cero DB (specs con datos → TASK-002).
// Regression: cubre src/app/{layout,page}.tsx · un PRP futuro que los toque
// corre este spec en la pre-validación (regla #16).
test('la home responde 200 y muestra PUERTITA', async ({ page }) => {
  const response = await page.goto('/')
  expect(response?.status()).toBe(200)
  await expect(page.getByRole('heading', { name: 'PUERTITA' })).toBeVisible()
})
