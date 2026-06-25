# `.claude/memory/_archive/` · Memorias archivadas

> **Qué es:** carpeta de archivado de memorias obsoletas · supersedidas · históricas. Contenido NO se carga al boot · queda en el repo como trazabilidad histórica.
>
> **Por qué se creó:** el lint mensual de memoria (regla #19 [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md)) detecta stale claims · contradicciones · orphan files. Cuando una memoria deja de ser cierta o útil, NO se borra (preserva trazabilidad git-friendly) · se mueve acá con cross-ref desde el archivo original o desde el log de archivado.
>
> **Para qué sirve:** mantener memoria activa liviana + permitir auditoría retrospectiva ("¿qué decía el agente en X sobre Y?") sin que pese en el contexto cargado al boot.

## Convención

- **Naming:** preservar nombre original + sufijo opcional `<original-name>-superseded-<YYYY-MM-DD>.md` o agrupar en subcarpetas `<prefijo>/` cuando se archivan en batch (ej: post-refactor mass-archive).
- **Frontmatter:** mantener el original (`type` no cambia) · agregar campo `archived_on: YYYY-MM-DD` + `archived_reason: <razón corta>`.
- **NO indexar en MEMORY.md raíz** · el archivado se desindexa explícitamente (mueve la entry del § correspondiente · puede dejar 1 línea en una sección "Archivos archivados" si la traza es importante).
- **Subcarpetas en `_archive/`:** se admiten cuando se archivan en batch agrupado (ej: `_archive/post-refactor-2026-05/`).

## Memorias archivadas

> Vacío al boot del pack. Se va llenando conforme el lint mensual detecta memorias para archivar y el user firma su mudanza.

## Cómo archivar una memoria

1. Detectar la memoria a archivar (vía lint mensual o vía observación directa de stale).
2. Confirmar con el user que se archiva (regla #6 [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md)).
3. `git mv <path-original> _archive/<nombre>-superseded-<YYYY-MM-DD>.md` (preserva git history).
4. Agregar frontmatter `archived_on: YYYY-MM-DD` + `archived_reason: <razón>`.
5. Remover la entry de [`../MEMORY.md`](../MEMORY.md) del § correspondiente (NO duplicar acá).
6. Si la memoria archivada es referenciada por otras memorias o reglas firmes activas · actualizar cross-refs para evitar links rotos (criterio 5 del lint).
7. Sumar entry en [`../log.md`](../log.md) tipo `lint` documentando el archivado.

## Carpetas hermanas

- [`.claude/memory/feedback/`](../feedback/) · [`reference/`](../reference/) · [`project/`](../project/) · [`user/`](../user/) — carpetas activas · cargadas al boot.

## Reglas firmes asociadas

- [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md) — lint mensual detecta candidates · esta carpeta es destino del archivado decidido caso por caso.
- [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) — el archivado se registra como entry tipo `lint` en `log.md`.
- [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) — sub-carpetas dentro de `_archive/` siguen la convención de README + firma user.

---

*Convención de README firmada 2026-05-20 (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
