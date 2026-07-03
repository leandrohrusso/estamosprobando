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
