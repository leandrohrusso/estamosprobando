import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

/**
 * Cliente Supabase para el servidor (Server Components · Server Actions · Route
 * Handlers). Lee/escribe la sesión vía cookies de Next.
 *
 * Skeleton de PRP-001: declara el cliente con cookies. La integración real de
 * Auth (magic link · memberships) y el resolver de `organization_id` desde
 * sesión (nunca de input del cliente · constraint #1) llegan en TASK-002.
 */
export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            )
          } catch {
            // `setAll` desde un Server Component falla (read-only): ignorable
            // si hay middleware refrescando la sesión. Patrón canónico Supabase.
          }
        },
      },
    },
  )
}
