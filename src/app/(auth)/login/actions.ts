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

  const origin = (await headers()).get('origin')
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
