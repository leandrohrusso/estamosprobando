import { z } from 'zod'

/**
 * Esquemas Zod de validación de inputs de auth/onboarding. Toda Server Action
 * valida su input con estos antes de tocar la BD (defensa en capas · regla
 * principios-desarrollo-flujo). Server Actions de gestión de miembros (Fase 3)
 * suman sus esquemas acá.
 */

export const loginSchema = z.object({
  email: z.email({ message: 'Ingresá un email válido.' }),
})
export type LoginInput = z.infer<typeof loginSchema>

export const createOrganizationSchema = z.object({
  name: z
    .string()
    .trim()
    .min(2, { message: 'El nombre debe tener al menos 2 caracteres.' })
    .max(80, { message: 'El nombre no puede superar los 80 caracteres.' }),
})
export type CreateOrganizationInput = z.infer<typeof createOrganizationSchema>

/**
 * Roles asignables desde la gestión de miembros (Fase 3). Owner queda **fuera**:
 * el dueño se obtiene solo al crear la org (onboarding · SD-cos-1) y es inmutable
 * vía esta UI · así el alta/cambio de rol nunca pueden dejar la org sin Owner
 * (anti-lockout · sin contar owners). Ver `removeMember`/`changeRole`.
 */
export const assignableRoleSchema = z.enum(['admin', 'staff'], {
  message: 'Elegí un rol válido.',
})
export type AssignableRole = z.infer<typeof assignableRoleSchema>

/** Alta de miembro por email + rol (Bif 3=A · crea membership `pending`). */
export const addMemberSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .pipe(z.email({ message: 'Ingresá un email válido.' })),
  role: assignableRoleSchema,
})
export type AddMemberInput = z.infer<typeof addMemberSchema>

/** Cambio de rol de un miembro existente (identificado por su membership id). */
export const changeRoleSchema = z.object({
  membershipId: z.guid({ message: 'Miembro inválido.' }),
  role: assignableRoleSchema,
})
export type ChangeRoleInput = z.infer<typeof changeRoleSchema>

/** Baja de un miembro (identificado por su membership id). */
export const removeMemberSchema = z.object({
  membershipId: z.guid({ message: 'Miembro inválido.' }),
})
export type RemoveMemberInput = z.infer<typeof removeMemberSchema>
