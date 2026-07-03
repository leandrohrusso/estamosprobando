'use server'

import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { createOrganizationSchema } from '@/lib/auth/schemas'
import { MAX_SLUG_LENGTH, slugify } from '@/lib/auth/slug'

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

  let slug = base
  let createdSlug: string | null = null
  for (let attempt = 1; attempt <= MAX_SLUG_ATTEMPTS; attempt++) {
    const { error } = await supabase.rpc('create_organization_with_owner', {
      p_name: parsed.data.name,
      p_slug: slug,
    })
    if (!error) {
      createdSlug = slug
      break
    }
    if (error.code === UNIQUE_VIOLATION) {
      const suffix = `-${attempt + 1}`
      slug = `${base.slice(0, MAX_SLUG_LENGTH - suffix.length)}${suffix}`
      continue
    }
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
