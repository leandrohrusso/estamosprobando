import { redirect } from 'next/navigation'
import { getActiveMemberships, getSessionUser } from '@/lib/auth/session'
import { resolvePostLoginRedirect } from '@/lib/auth/org'
import { OnboardingForm } from './onboarding-form'

/**
 * Onboarding "crear organización" de un paso (Bif 2=A). Guard server:
 * - sin sesión → `/login`.
 * - con ≥1 membership activa → ya está onboardeado · redirigir según SD-cos-9.
 * Solo el usuario nuevo (0 memberships) ve el formulario.
 */
export default async function OnboardingPage() {
  const user = await getSessionUser()
  if (!user) redirect('/login')

  const memberships = await getActiveMemberships()
  if (memberships.length > 0) redirect(resolvePostLoginRedirect(memberships))

  return (
    <main className="flex min-h-screen items-center justify-center bg-background p-4">
      <OnboardingForm />
    </main>
  )
}
