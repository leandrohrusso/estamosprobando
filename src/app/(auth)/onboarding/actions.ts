'use server'

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { createOrganizationSchema } from '@/lib/auth/schemas'
import { isReservedSlug, slugCandidate, slugify } from '@/lib/auth/slug'

export type OnboardingState = {
  status: 'idle' | 'error'
  message?: string
}

/** Reintentos ante colisión de slug antes de rendirse (SD-cos-8). */
const MAX_SLUG_ATTEMPTS = 5
/** Código Postgres de unique_violation (slug ya tomado). */
const UNIQUE_VIOLATION = '23505'

/**
 * Crea la organización + membership Owner del usuario en sesión, vía la RPC
 * `create_organization_with_owner` (SECURITY DEFINER · resuelve el chicken-and-egg
 * de RLS · SD-cos-1). En colisión de slug reintenta con sufijo `-2`, `-3`…
 * (SD-cos-8) y aterriza en el dashboard de la org (Bif 2=A).
 */
export async function createOrganization(
  _prev: OnboardingState,
  formData: FormData,
): Promise<OnboardingState> {
  const parsed = createOrganizationSchema.safeParse({
    name: formData.get('name'),
    requestId: formData.get('requestId'),
  })
  if (!parsed.success) {
    return { status: 'error', message: parsed.error.issues[0].message }
  }

  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) {
    return { status: 'error', message: 'Tu sesión expiró. Volvé a entrar.' }
  }

  const base = slugify(parsed.data.name)
  if (!base) {
    return {
      status: 'error',
      message: 'Elegí un nombre con al menos una letra o número.',
    }
  }

  // Un base que pisa una ruta reservada de primer nivel (`login`, `auth`, …) se
  // trata como si el bare ya estuviera tomado: se arranca en `-2` (SD-cos-8 +
  // guard de colisión de rutas de Fase 3). El candidato por intento vive en
  // `slugCandidate` (pura · testeada · LR-002 unicidad de slug).
  const firstAttempt = isReservedSlug(base) ? 2 : 1

  let createdSlug: string | null = null
  for (let n = firstAttempt; n < firstAttempt + MAX_SLUG_ATTEMPTS; n++) {
    const slug = slugCandidate(base, n)
    const { error } = await supabase.rpc('create_organization_with_owner', {
      p_name: parsed.data.name,
      p_slug: slug,
      p_request_id: parsed.data.requestId,
    })
    if (!error) {
      createdSlug = slug
      break
    }
    if (error.code === UNIQUE_VIOLATION) continue
    return {
      status: 'error',
      message: 'No pudimos crear la organización. Probá de nuevo.',
    }
  }

  if (!createdSlug) {
    return { status: 'error', message: 'Ese nombre ya está en uso. Probá con otro.' }
  }

  redirect(`/${createdSlug}/dashboard`)
}
