import type { NextRequest } from 'next/server'
import { updateSession } from '@/lib/supabase/middleware'

/**
 * Proxy thin (SD-cos-7): refresca la sesión Supabase en cada request de página.
 * La autorización real (membership + rol) vive en los layouts server.
 *
 * Convención `proxy` de Next.js 16 (reemplaza `middleware`, deprecada · misma
 * semántica edge · verificado contra docs oficiales · ver PRP § Aprendizajes).
 */
export async function proxy(request: NextRequest) {
  return updateSession(request)
}

export const config = {
  matcher: [
    /*
     * Corre en todo path EXCEPTO assets estáticos y el favicon:
     * - _next/static · _next/image · favicon.ico
     * - archivos con extensión de imagen
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
