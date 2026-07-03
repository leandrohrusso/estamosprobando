import { test, expect } from '@playwright/test'
import {
  signInAs,
  deleteTestUser,
  deleteOrganizationBySlug,
  createOrganizationDirect,
  addActiveMember,
  addPendingMember,
  getOrgMembership,
} from '../auth-session'

/**
 * PRP-002 Fase 3 · RBAC gate + selección de org + gestión de miembros.
 * Cubre: G6 (staff bloqueado en /members · owner la ve) · G7 (selector multi-org)
 * · G8 (alta pending → vinculación al login) · CRUD de miembros (add/changeRole/
 * remove). Regression: `src/app/(org)/[orgSlug]/*` · `src/components/nav/*` ·
 * `src/app/(auth)/select-organization/*` · helpers `requireMembership`/
 * `requireRole`/`getOrgMembers` + actions de miembros.
 */

test('G6 · staff es bloqueado en /members y owner la ve', async ({ page }) => {
  const stamp = Date.now()
  const slug = `rbac-${stamp}`
  const ownerEmail = `owner-${stamp}@puertita.test`
  const staffEmail = `staff-${stamp}@puertita.test`

  const orgId = await createOrganizationDirect(`RBAC Org ${stamp}`, slug)
  try {
    await addActiveMember(orgId, ownerEmail, 'owner')
    await addActiveMember(orgId, staffEmail, 'staff')

    // Staff: 1 membership activa → aterriza en su dashboard; /members lo rebota.
    await signInAs(page, staffEmail)
    await expect(page).toHaveURL(new RegExp(`/${slug}/dashboard$`))
    await page.goto(`/${slug}/members`)
    await expect(page).toHaveURL(new RegExp(`/${slug}/dashboard$`))
    await expect(page.getByRole('heading', { name: 'Miembros' })).toHaveCount(0)

    // Owner: ve la pantalla de gestión.
    await signInAs(page, ownerEmail)
    await page.goto(`/${slug}/members`)
    await expect(page.getByRole('heading', { name: 'Miembros' })).toBeVisible()
  } finally {
    await deleteOrganizationBySlug(slug)
    await deleteTestUser(ownerEmail)
    await deleteTestUser(staffEmail)
  }
})

test('G7 · usuario multi-org elige y cambia de organización', async ({
  page,
}) => {
  const stamp = Date.now()
  const slug1 = `sw1-${stamp}`
  const slug2 = `sw2-${stamp}`
  const name1 = `Org Uno ${stamp}`
  const name2 = `Org Dos ${stamp}`
  const email = `multi-${stamp}@puertita.test`

  const org1 = await createOrganizationDirect(name1, slug1)
  const org2 = await createOrganizationDirect(name2, slug2)
  try {
    await addActiveMember(org1, email, 'owner')
    await addActiveMember(org2, email, 'admin')

    // ≥2 memberships → selector de organización.
    await signInAs(page, email)
    await expect(page).toHaveURL(/\/select-organization$/)
    await expect(page.getByRole('heading', { name: 'Elegí una organización' })).toBeVisible()
    await expect(page.getByRole('link', { name: new RegExp(name1) })).toBeVisible()
    await expect(page.getByRole('link', { name: new RegExp(name2) })).toBeVisible()

    // Entra a la primera.
    await page.getByRole('link', { name: new RegExp(name1) }).click()
    await expect(page).toHaveURL(new RegExp(`/${slug1}/dashboard$`))
    await expect(page.getByRole('heading', { name: name1 })).toBeVisible()

    // Cambia a la segunda con el switcher → cambia el contexto de tenant.
    await page.getByLabel('Cambiar de organización').selectOption(slug2)
    await expect(page).toHaveURL(new RegExp(`/${slug2}/dashboard$`))
    await expect(page.getByRole('heading', { name: name2 })).toBeVisible()
  } finally {
    await deleteOrganizationBySlug(slug1)
    await deleteOrganizationBySlug(slug2)
    await deleteTestUser(email)
  }
})

test('G8 · owner invita por email y esa persona se vincula al login', async ({
  page,
}) => {
  const stamp = Date.now()
  const slug = `invite-${stamp}`
  const ownerEmail = `owner-${stamp}@puertita.test`
  const inviteeEmail = `invitee-${stamp}@puertita.test`

  const orgId = await createOrganizationDirect(`Invite Org ${stamp}`, slug)
  try {
    await addActiveMember(orgId, ownerEmail, 'owner')

    // Owner da de alta al invitado (rol Staff por defecto).
    await signInAs(page, ownerEmail)
    await page.goto(`/${slug}/members`)
    await page.getByLabel('Email del miembro').fill(inviteeEmail)
    await page.getByRole('button', { name: 'Agregar' }).click()

    // Aparece como pendiente en la lista (fila · exact evita matchear el mensaje
    // de éxito "Invitaste a …") + membership pending en BD (user_id NULL).
    await expect(page.getByText(inviteeEmail, { exact: true })).toBeVisible()
    await expect
      .poll(async () => await getOrgMembership(orgId, inviteeEmail))
      .toMatchObject({ status: 'pending', role: 'staff', userId: null })

    // El invitado entra por magic link → link_pending_memberships lo vincula.
    await signInAs(page, inviteeEmail)
    await expect(page).toHaveURL(new RegExp(`/${slug}/dashboard$`))
    const linked = await getOrgMembership(orgId, inviteeEmail)
    expect(linked?.status).toBe('active')
    expect(linked?.userId).not.toBeNull()

    // Sin acceso a /members (es staff · G6 aplicado al recién vinculado).
    await page.goto(`/${slug}/members`)
    await expect(page).toHaveURL(new RegExp(`/${slug}/dashboard$`))
  } finally {
    await deleteOrganizationBySlug(slug)
    await deleteTestUser(ownerEmail)
    await deleteTestUser(inviteeEmail)
  }
})

test('CRUD · owner cambia el rol y quita a un miembro', async ({ page }) => {
  const stamp = Date.now()
  const slug = `crud-${stamp}`
  const ownerEmail = `owner-${stamp}@puertita.test`
  const memberEmail = `member-${stamp}@puertita.test`

  const orgId = await createOrganizationDirect(`CRUD Org ${stamp}`, slug)
  try {
    await addActiveMember(orgId, ownerEmail, 'owner')
    await addPendingMember(orgId, memberEmail, 'staff')

    await signInAs(page, ownerEmail)
    await page.goto(`/${slug}/members`)
    await expect(page.getByText(memberEmail)).toBeVisible()

    // Cambia el rol staff → admin (el select de la fila auto-submitea).
    await page.getByLabel(`Rol de ${memberEmail}`).selectOption('admin')
    await expect
      .poll(async () => (await getOrgMembership(orgId, memberEmail))?.role)
      .toBe('admin')

    // Lo quita → desaparece de la lista y de la BD.
    await page.getByRole('button', { name: `Quitar a ${memberEmail}` }).click()
    await expect(page.getByText(memberEmail)).toBeHidden()
    await expect
      .poll(async () => await getOrgMembership(orgId, memberEmail))
      .toBeNull()
  } finally {
    await deleteOrganizationBySlug(slug)
    await deleteTestUser(ownerEmail)
    await deleteTestUser(memberEmail)
  }
})
