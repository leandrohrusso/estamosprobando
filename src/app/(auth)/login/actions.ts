'use server'

import { headers } from 'next/headers'
import { createClient } from '@/lib/supabase/server'
import { loginSchema } from '@/lib/auth/schemas'

export type LoginState = {
  status: 'idle' | 'sent' | 'error'
  message?: string
  email?: string
}

/**
 * Envía el magic link (email OTP) al email ingresado. El link apunta a
 * `/auth/confirm`, que establece la sesión y redirige según memberships
 * (SD-cos-9). Sin contraseñas (constraint del PRD · magic link only).
 */
export async function sendMagicLink(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const parsed = loginSchema.safeParse({ email: formData.get('email') })
  if (!parsed.success) {
    return { status: 'error', message: parsed.error.issues[0].message }
  }

  // Base del redirect del magic link. Preferimos una constante server-side confiable
  // (NEXT_PUBLIC_SITE_URL) sobre el header `Origin`, que es controlable por el cliente:
  // así el token del enlace nunca se ancla a un host que ponga el request (LR-002
  // lr_bug_007 · defensa que se suma a la allow-list de Redirect URLs de Supabase).
  // El header queda solo como fallback de desarrollo (sin NEXT_PUBLIC_SITE_URL seteada).
  const configuredSiteUrl = process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/+$/, '')
  const origin = configuredSiteUrl ?? (await headers()).get('origin')
  if (!origin) {
    return { status: 'error', message: 'No pudimos resolver el sitio. Probá de nuevo.' }
  }

  const supabase = await createClient()
  const { error } = await supabase.auth.signInWithOtp({
    email: parsed.data.email,
    options: { emailRedirectTo: `${origin}/auth/confirm` },
  })

  if (error) {
    return { status: 'error', message: 'No pudimos enviar el enlace. Probá de nuevo.' }
  }

  return { status: 'sent', email: parsed.data.email }
}
