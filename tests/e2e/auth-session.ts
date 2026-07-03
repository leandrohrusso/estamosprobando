import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import type { Page } from '@playwright/test'

/**
 * Utilidades de sesión para specs e2e (SD-cos-10). Usan la **Supabase Admin API**
 * con `service_role` que vive SOLO en el entorno de test/CI (`.env.local`) ·
 * NUNCA en `src/` (guard constraint #10, verificado en Fase 4).
 *
 * La sesión se establece pasando el browser por el route REAL `/auth/confirm`
 * (mismo camino que la app en producción) con un `token_hash` generado vía
 * `generateLink` · cero construcción manual de cookies `@supabase/ssr`.
 */

function admin(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!url || !serviceKey) {
    throw new Error(
      'Faltan NEXT_PUBLIC_SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY en el entorno de test.',
    )
  }
  return createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })
}

/** Crea (o recupera si ya existe) un test user con email confirmado. Devuelve su id. */
export async function ensureTestUser(email: string): Promise<string> {
  const a = admin()
  const { data, error } = await a.auth.admin.createUser({
    email,
    email_confirm: true,
  })
  if (!error && data.user) return data.user.id

  // Ya existía → buscarlo en la lista (TEST DB chica · perPage alto alcanza).
  const { data: list, error: listErr } = await a.auth.admin.listUsers({
    page: 1,
    perPage: 1000,
  })
  if (listErr) {
    throw new Error(`No pude listar users para encontrar ${email}: ${listErr.message}`)
  }
  const found = list.users.find(
    (u) => u.email?.toLowerCase() === email.toLowerCase(),
  )
  if (!found) {
    throw new Error(
      `No pude crear ni encontrar el test user ${email}: ${error?.message}`,
    )
  }
  return found.id
}

/**
 * Autentica al `page` como `email`, atravesando el route real `/auth/confirm`.
 * Tras la llamada, el browser quedó con sesión y redirigido según memberships
 * (SD-cos-9). El caller decide qué URL esperar.
 */
export async function signInAs(page: Page, email: string): Promise<void> {
  const a = admin()
  await ensureTestUser(email)

  const { data, error } = await a.auth.admin.generateLink({
    type: 'magiclink',
    email,
  })
  const tokenHash = data?.properties?.hashed_token
  if (error || !tokenHash) {
    throw new Error(
      `No pude generar el magic link para ${email}: ${error?.message ?? 'sin hashed_token'}`,
    )
  }

  await page.goto(`/auth/confirm?token_hash=${tokenHash}&type=magiclink`)
}

/** Borra el test user por email (idempotente · limpieza post-spec). */
export async function deleteTestUser(email: string): Promise<void> {
  const a = admin()
  const { data: list } = await a.auth.admin.listUsers({ page: 1, perPage: 1000 })
  const found = list?.users.find(
    (u) => u.email?.toLowerCase() === email.toLowerCase(),
  )
  if (found) await a.auth.admin.deleteUser(found.id)
}

/** Membership Owner activa creada durante el onboarding (para asserts de G4). */
export type OwnerMembershipRow = {
  organizationId: string
  slug: string
  orgName: string
  role: string
  status: string
}

/**
 * Devuelve la membership Owner activa del usuario (por email) + slug/nombre de la
 * org creada. `null` si no existe. Usa `service_role` (bypassa RLS · solo test).
 */
export async function getOwnerMembershipByEmail(
  email: string,
): Promise<OwnerMembershipRow | null> {
  const a = admin()
  const { data, error } = await a
    .from('memberships')
    .select('organization_id, role, status, organizations!inner(slug, name)')
    .eq('email', email.toLowerCase())
    .eq('role', 'owner')
    .eq('status', 'active')
    .maybeSingle()

  if (error || !data) return null
  const org = Array.isArray(data.organizations)
    ? data.organizations[0]
    : data.organizations
  return {
    organizationId: data.organization_id as string,
    slug: org.slug as string,
    orgName: org.name as string,
    role: data.role as string,
    status: data.status as string,
  }
}

/** Borra una organización por slug (cascada a memberships · limpieza post-spec). */
export async function deleteOrganizationBySlug(slug: string): Promise<void> {
  const a = admin()
  await a.from('organizations').delete().eq('slug', slug)
}
