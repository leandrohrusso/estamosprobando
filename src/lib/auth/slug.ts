/** Longitud máxima del slug de organización (SD-cos-8 · coincide con validaciones de URL). */
export const MAX_SLUG_LENGTH = 63

/**
 * Deriva un slug URL-safe del nombre de la organización (SD-cos-8):
 * lowercase · alfanumérico ASCII + guiones simples · sin guiones al borde · ≤63
 * chars. El slug es **inmutable post-creación** (cambiarlo rompería URLs
 * públicas) · la unicidad la garantiza `UNIQUE(slug)` en la BD (el caller
 * reintenta con sufijo `-2`, `-3` en colisión).
 */
export function slugify(name: string): string {
  return name
    .normalize('NFKD') // separa diacríticos de sus letras base
    .replace(/[̀-ͯ]/g, '') // quita los diacríticos combinantes
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-') // no-alfanumérico → guión
    .replace(/^-+|-+$/g, '') // recorta guiones de los bordes
    .slice(0, MAX_SLUG_LENGTH)
    .replace(/-+$/g, '') // el slice pudo cortar dejando un guión colgando
}
