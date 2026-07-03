import type { MembershipRole } from '@/lib/auth/session'

/**
 * Etiquetas en español de los roles (copy de UI · client-safe: solo importa el
 * tipo `MembershipRole`, que se borra en compilación · no arrastra el cliente
 * Supabase server-only de `session.ts`).
 */
const ROLE_LABELS: Record<MembershipRole, string> = {
  owner: 'Dueño',
  admin: 'Administrador',
  staff: 'Staff',
}

export function roleLabel(role: MembershipRole): string {
  return ROLE_LABELS[role]
}
