import { NextResponse, type NextRequest } from 'next/server'
import type { EmailOtpType } from '@supabase/supabase-js'
import { createClient } from '@/lib/supabase/server'
import { getActiveMemberships } from '@/lib/auth/session'
import { resolvePostLoginRedirect } from '@/lib/auth/org'

/**
 * Callback del magic link. Establece la sesión (verifyOtp con `token_hash` —
 * flujo SSR verificado contra docs Supabase `@supabase/ssr` 0.12 — o
 * `exchangeCodeForSession` si el template de email usa el flujo PKCE con
 * `code`), vincula memberships `pending` por email (Bif 3=A · SD-cos-2) y
 * redirige según la cantidad de memberships activas (SD-cos-9).
 */
export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const tokenHash = searchParams.get('token_hash')
  const type = searchParams.get('type') as EmailOtpType | null
  const code = searchParams.get('code')

  const supabase = await createClient()
  let authenticated = false

  if (tokenHash && type) {
    const { error } = await supabase.auth.verifyOtp({ token_hash: tokenHash, type })
    authenticated = !error
  } else if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    authenticated = !error
  }

  if (!authenticated) {
    return NextResponse.redirect(`${origin}/login?error=auth`)
  }

  // Vincula memberships pending (user_id NULL) cuyo email coincide con el del
  // usuario recién autenticado → user_id seteado + status='active' (SD-cos-2).
  // Si el vínculo falla, NO seguir como "usuario nuevo": un invitado terminaría
  // en /onboarding creando su propia org en vez de unirse a la que lo invitó.
  const { error: linkError } = await supabase.rpc('link_pending_memberships')
  if (linkError) {
    return NextResponse.redirect(`${origin}/login?error=link`)
  }

  let memberships
  try {
    memberships = await getActiveMemberships()
  } catch {
    // Fallo real de la query (no "sin orgs") → volver a login, no a onboarding.
    return NextResponse.redirect(`${origin}/login?error=session`)
  }
  const destination = resolvePostLoginRedirect(memberships)
  return NextResponse.redirect(`${origin}${destination}`)
}
