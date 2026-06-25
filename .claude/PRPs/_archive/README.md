# `.claude/PRPs/_archive/` · Archivado de PRPs y templates obsoletos

> **Qué es:** carpeta de archivado del directorio `.claude/PRPs/` · contiene templates legacy · drafts descartados · PRPs deprecated que se preservan por trazabilidad histórica sin contaminar el directorio activo.
>
> **Por qué se creó:** convención del template workflow-base · cuando un PRP del directorio activo queda obsoleto (superseded por otro · template legacy reemplazado por versión nueva · draft descartado pre-firma del user) se archiva acá con `git mv` para preservar trazabilidad histórica sin contaminar el directorio activo. Paridad arquitectónica con [`.claude/memory/_archive/`](../../memory/_archive/) (mismo concepto · para memorias).
>
> **Para qué sirve:** preservar contexto histórico de templates/PRPs sin contaminar el directorio activo `.claude/PRPs/`. Los skills del flujo ([`/planificar`](../../skills/planificar/SKILL.md) · [`/implementar`](../../skills/implementar/SKILL.md)) **NO leen** de esta carpeta · solo referencia histórica para auditorías retrospectivas + trazabilidad de evolución del proceso.

## Convención

- **Naming:** kebab-case descriptivo del origen + sufijo del shape archivado cuando aplica (ej: `prp-base-v1.md` deja claro que era versión 1 del template · NO `prp-base-old.md` que pierde contexto del origen).
- **Shape / formato:** los archivos preservan su shape original al momento del archivado · **cero edición retroactiva** (paridad regla [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) "snapshots históricos inmutables").
- **Archivado obligatorio con `git mv`:** preserva historia git verificable con `git log --follow <archivo-archivado>` · NUNCA `cp` + delete original (rompe trazabilidad).
- **Cero edits post-archivado:** una vez archivado, el archivo es snapshot inmutable. Si surge necesidad de un template nuevo, se crea NUEVO archivo activo en `.claude/PRPs/` · NO se desarchiva.

## Archivos actuales

_(vacío al boot del pack · primer archivo se archiva cuando un template o PRP del directorio activo queda obsoleto)_

## Carpetas hermanas

- [`.claude/PRPs/`](../) (parent) — directorio activo de PRPs · template opcional `prp-base.md` · PRPs activos en estados `PENDIENTE` / `APROBADO` / `EN PROGRESO` / `COMPLETADO`. Usar `.claude/PRPs/_archive/` solo cuando un archivo del directorio activo queda obsoleto y debe preservarse por trazabilidad.
- [`.claude/memory/_archive/`](../../memory/_archive/) — archivado paralelo del directorio `.claude/memory/` · paridad arquitectónica (mismo concepto · misma convención de inmutabilidad post-archivado · misma convención de `git mv` para preservar historia).

## Cómo agregar un archivo nuevo

1. **`git mv <src> .claude/PRPs/_archive/<nombre-archivado>.md`** (preserva historia · NUNCA `cp` + delete).
2. **Actualizar tabla "Archivos actuales"** de este README con fila nueva (archivo + rol + fecha + PRP/evento que disparó el archivado).
3. **Actualizar `.claude/PRPs/README.md` parent** para reflejar que el archivo ya NO está en el directorio activo (si el README parent lista archivos activos explícitos).
4. **Si el archivado cierra una DT** registrada en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md): mover la fila DT a sección "Deudas resueltas" con commit hash del archivado (paridad regla [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) checklist 6 ítems · ítem 4.6.b cierre inmediato de DT).
5. **Verificar `git log --follow`** del archivo archivado retorna la historia completa (incluyendo commits pre-rename) · garantiza trazabilidad preservada.

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
