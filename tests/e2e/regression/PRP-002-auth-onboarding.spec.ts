import { test, expect } from '@playwright/test'
import {
  signInAs,
  deleteTestUser,
  deleteOrganizationBySlug,
  getOwnerMembershipByEmail,
} from '../auth-session'
import { slugify } from '../../../src/lib/auth/slug'

/**
 * PRP-002 Fase 2 · login (magic link) + onboarding → Owner.
 * Cubre: G5 (login envía el enlace) · G4 (onboarding crea org + membership Owner).
 * Regression: cubre `src/app/(auth)/login/*` · `src/app/auth/confirm/route.ts` ·
 * `src/app/(auth)/onboarding/*` · helpers `src/lib/auth/*` · tabla `organizations`/`memberships`.
 */

test('G5 · el login renderiza el form de magic link (sin contraseñas)', async ({
  page,
}) => {
  // El happy-path "form→enviado" hace un envío real de email, inestable en CI
  // por el rate-limit del SMTP built-in de Supabase (429) y el rechazo del TLD
  // `.test` → cubierto por el smoke visual de Fase 4 + manual · automatización
  // diferida a SMTP propio (DT-003 · disparador TASK-008 Resend). El pipeline
  // de auth end-to-end lo prueba G4 vía el route real /auth/confirm.
  await page.goto('/login')
  await expect(
    page.getByRole('heading', { name: 'Entrar a PUERTITA' }),
  ).toBeVisible()
  await expect(page.getByText('Sin contraseñas')).toBeVisible()
  await expect(page.getByLabel('Email')).toBeVisible()
  await expect(
    page.getByRole('button', { name: 'Enviarme el enlace' }),
  ).toBeVisible()
})

test('G5 · email inválido muestra error sin enviar', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill('no-es-un-email')
  await page.getByRole('button', { name: 'Enviarme el enlace' }).click()
  await expect(page.getByRole('alert')).toBeVisible()
  // Sigue en el formulario (no transicionó a "revisá tu email").
  await expect(
    page.getByRole('heading', { name: 'Entrar a PUERTITA' }),
  ).toBeVisible()
})

test('G4 · usuario nuevo hace onboarding y queda Owner de su organización', async ({
  page,
}) => {
  const stamp = Date.now()
  const email = `owner-${stamp}@puertita.test`
  const orgName = `Productora Test ${stamp}`

  try {
    // Sesión vía el route real /auth/confirm → usuario sin memberships → /onboarding.
    await signInAs(page, email)
    await expect(page).toHaveURL(/\/onboarding$/)
    await expect(
      page.getByRole('heading', { name: 'Creá tu organización' }),
    ).toBeVisible()

    await page.getByLabel('Nombre de la organización').fill(orgName)
    await page.getByRole('button', { name: 'Crear organización' }).click()

    // Redirect a /{slug}/dashboard (la página se materializa en Fase 3;
    // acá validamos la URL destino + el estado real en BD · criterio binario G4).
    await page.waitForURL(/\/[a-z0-9-]+\/dashboard$/)

    const membership = await getOwnerMembershipByEmail(email)
    expect(membership, 'debería existir la membership Owner').not.toBeNull()
    expect(membership!.role).toBe('owner')
    expect(membership!.status).toBe('active')
    expect(membership!.orgName).toBe(orgName)

    // Slug válido (lowercase/alfanumérico/guiones simples) y determinístico.
    expect(membership!.slug).toMatch(/^[a-z0-9]+(-[a-z0-9]+)*$/)
    expect(membership!.slug).toBe(slugify(orgName))
  } finally {
    const created = await getOwnerMembershipByEmail(email)
    if (created) await deleteOrganizationBySlug(created.slug)
    await deleteTestUser(email)
  }
})
