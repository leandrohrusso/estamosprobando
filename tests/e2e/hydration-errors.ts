// Helper E2E · listener canónico de errores de hidratación React.
//
// Por qué existe: hydration mismatch por causas no-visuales (ej: ICU U+202F NBSP
// cuando server libc UTC ↔ client browser difieren en `toLocaleString()`) no se
// atrapa con visual matching de Playwright — el client gana el re-render
// post-hydration y los `expect(...).toBeVisible()` pasan igual. La única señal
// es el `console.error` "Hydration failed" / "did not match" que React emite en
// dev. Esta función vincula esos canales a un array vivo · el caller hace
// `expect(hydrationErrors).toEqual([])` después del `page.goto` + assertion
// visible (paridad regla #15 `regression-first-on-fix`).
//
// Uso:
//   const hydrationErrors = collectHydrationErrors(page)
//   await page.goto(url, { waitUntil: 'networkidle' })
//   await expect(page.locator('h1').first()).toBeVisible()
//   expect(hydrationErrors).toEqual([])

import type { Page } from '@playwright/test'

const HYDRATION_ERROR_PATTERNS = [
  'Hydration failed',
  'did not match',
  'Text content does not match server-rendered HTML',
] as const

/** Engancha listeners `console` + `pageerror` que acumulan mensajes de
 *  hidratación. Devuelve el array vivo para assertion posterior. */
export function collectHydrationErrors(page: Page): string[] {
  const errors: string[] = []
  page.on('console', (msg) => {
    if (msg.type() !== 'error') return
    const text = msg.text()
    if (HYDRATION_ERROR_PATTERNS.some((pattern) => text.includes(pattern))) {
      errors.push(text)
    }
  })
  page.on('pageerror', (err) => {
    if (err.message.includes('Hydration')) errors.push(err.message)
  })
  return errors
}
