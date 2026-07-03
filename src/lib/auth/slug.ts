/** Longitud máxima del slug de organización (SD-cos-8 · coincide con validaciones de URL). */
export const MAX_SLUG_LENGTH = 63

/**
 * Slugs que colisionarían con segmentos estáticos de primer nivel (`/{slug}/...`
 * comparte raíz con estas rutas · Fase 3 monta `(org)/[orgSlug]`). Una org cuyo
 * nombre slugifique a uno de estos valores recibe sufijo `-2` como en cualquier
 * colisión de unicidad (createOrganization), en vez de tomar la ruta reservada.
 * Incluye `api` por la convención de Next para route handlers.
 */
export const RESERVED_SLUGS: ReadonlySet<string> = new Set([
  'login',
  'onboarding',
  'select-organization',
  'auth',
  'api',
])

/** `true` si el slug pisa una ruta reservada de primer nivel (ver RESERVED_SLUGS). */
export function isReservedSlug(slug: string): boolean {
  return RESERVED_SLUGS.has(slug)
}

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
