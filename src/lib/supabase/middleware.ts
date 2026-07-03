import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

/**
 * Refresca la sesión Supabase en cada request y propaga las cookies rotadas
 * tanto al request (para Server Components downstream) como al response (para el
 * navegador). Patrón canónico `@supabase/ssr` para el App Router.
 *
 * **Thin por diseño (SD-cos-7):** este helper SOLO refresca la sesión · la
 * validación de membership/rol vive en `(org)/[orgSlug]/layout.tsx` (server
 * component con acceso pleno · el edge runtime del middleware es limitado).
 *
 * `getUser()` NO es opcional: dispara el refresco del token · sin esa llamada
 * entre `createServerClient` y el `return`, las sesiones se caen de forma
 * intermitente (advertencia oficial Supabase).
 */
export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          )
          response = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          )
        },
      },
    },
  )

  await supabase.auth.getUser()

  return response
}
