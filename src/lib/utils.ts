import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

/**
 * Combina clases condicionales (clsx) y resuelve conflictos de Tailwind
 * (tailwind-merge). Helper canónico de shadcn/ui · primer caller real en PRP-002
 * (SD-cos-6).
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
