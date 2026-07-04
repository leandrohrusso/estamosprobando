import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import type { Page } from '@playwright/test'
import { WebSocket as NodeWebSocket } from 'ws'

// `createClient` de @supabase/supabase-js construye un RealtimeClient eager que exige
// un `WebSocket` global (Node < 21 no lo trae nativo · el CI corre Node 20). Este helper
// solo usa `auth.admin` + queries REST (nunca abre una conexión realtime), pero el
// constructor igual pide el WS. Polyfill defensivo cuando el runtime no lo expone
// (no-op en Node ≥ 21, ej. el local en v24 · activo en el runner CI Node 20).
{
  const g = globalThis as unknown as { WebSocket?: unknown }
  if (typeof g.WebSocket === 'undefined') g.WebSocket = NodeWebSocket
}

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

// ---------------------------------------------------------------------------
// Setup directo de tenants/miembros para specs de RBAC/multi-org (Fase 3 ·
// G6/G7/G8). Todo vía `service_role` (bypassa RLS · SD-cos-10 · solo test).
// Complementan al onboarding real (que crea org + Owner en un paso): acá
// necesitamos armar escenarios con roles y estados arbitrarios.
// ---------------------------------------------------------------------------

/** Crea una organización directamente (sin RPC de onboarding). Devuelve su id. */
export async function createOrganizationDirect(
  name: string,
  slug: string,
): Promise<string> {
  const a = admin()
  const { data, error } = await a
    .from('organizations')
    .insert({ name, slug })
    .select('id')
    .single()
  if (error || !data) {
    throw new Error(`No pude crear la org ${slug}: ${error?.message}`)
  }
  return data.id as string
}

/**
 * Crea (si hace falta) el test user y le agrega una membership **activa** con el
 * rol dado en la org. Sirve para armar Owners/Staff activos de un escenario.
 */
export async function addActiveMember(
  organizationId: string,
  email: string,
  role: 'owner' | 'admin' | 'staff',
): Promise<void> {
  const a = admin()
  const userId = await ensureTestUser(email)
  const { error } = await a.from('memberships').insert({
    organization_id: organizationId,
    user_id: userId,
    email: email.toLowerCase(),
    role,
    status: 'active',
  })
  if (error) {
    throw new Error(`No pude agregar miembro activo ${email}: ${error.message}`)
  }
}

/** Agrega una membership **pending** (user_id NULL) · invitación sin vincular. */
export async function addPendingMember(
  organizationId: string,
  email: string,
  role: 'admin' | 'staff',
): Promise<void> {
  const a = admin()
  const { error } = await a.from('memberships').insert({
    organization_id: organizationId,
    email: email.toLowerCase(),
    role,
    status: 'pending',
  })
  if (error) {
    throw new Error(`No pude agregar miembro pending ${email}: ${error.message}`)
  }
}

/** Membership (role/status/userId) por org+email · `null` si no existe. */
export async function getOrgMembership(
  organizationId: string,
  email: string,
): Promise<{ role: string; status: string; userId: string | null } | null> {
  const a = admin()
  const { data, error } = await a
    .from('memberships')
    .select('role, status, user_id')
    .eq('organization_id', organizationId)
    .eq('email', email.toLowerCase())
    .maybeSingle()
  if (error || !data) return null
  return {
    role: data.role as string,
    status: data.status as string,
    userId: (data.user_id as string | null) ?? null,
  }
}
