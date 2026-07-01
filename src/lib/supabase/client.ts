import { createBrowserClient } from '@supabase/ssr'

/**
 * Cliente Supabase para el navegador (Client Components).
 *
 * Skeleton de PRP-001: declara el cliente con la anon key pública (protegida
 * por RLS · constraint #1 de BUSINESS_LOGIC §8). La integración real de Auth
 * (magic link · memberships) y el resolver de `organization_id` desde sesión
 * llegan en TASK-002.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  )
}
