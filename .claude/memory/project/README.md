# `.claude/memory/project/` · Estado vivo · checkpoints · handoffs

> **Qué es:** memorias del estado vivo del proyecto · checkpoints de PRPs en curso · handoffs entre sesiones (regla #26 [`session-handoff.md`](../../rules/session-handoff.md)) · decisiones arquitectónicas activas que aún no se cristalizaron en código.
>
> **Por qué se creó:** sin esto, retomar trabajo multi-sesión cuesta horas de re-onboarding. Los checkpoints + handoffs garantizan que la sesión nueva arranca con contexto preciso de "qué quedó cerrado · qué falta · qué gotchas se detectaron". Es el único canal donde el estado vivo viaja con el repo entre conversaciones.
>
> **Para qué sirve:** continuidad multi-sesión · trazabilidad histórica de PRPs cerrados · soporte operativo del flujo de 6 pasos cuando una sesión no alcanza para cerrar un paso completo.

## Convención

- **Naming:** kebab-case · `<scope>-<contexto>-<YYYY-MM-DD>.md` para checkpoints/handoffs · `<scope>-status.md` para estados vivos persistentes.
- **Frontmatter:** `name` · `description` · `type: project`.
- **Estructura para handoffs:** shape canónico de 7 secciones (regla #26 [`session-handoff.md`](../../rules/session-handoff.md)) · 6 obligatorias + Gotchas opcional. Ver [`_template.md`](./_template.md).
- **Estructura para checkpoints:** menos rígida · contexto + estado + próxima acción + decisiones firmadas + cross-refs.
- **Indexar en MEMORY.md:** una línea por entry · descripción 1-frase con el estado (CERRADO · ACTIVO · BLOQUEADO · etc).

## Memorias seed (pack workflow-base)

> Vacío al boot del pack. Se va llenando conforme arrancan PRPs del proyecto y se generan handoffs entre sesiones.

## Cómo agregar una memoria nueva

1. Para handoff entre sesiones: invocar el skill [`/handoff`](../../skills/handoff/SKILL.md) que aplica regla #26 con shape canónico de 7 secciones.
2. Para checkpoint mid-PRP: crear archivo con kebab-case + frontmatter `type: project` + estado al cierre de la fase + próxima acción 1-2 frases.
3. Sumar entry en [`../MEMORY.md`](../MEMORY.md) § `project/` con descripción 1-frase + estado del trabajo.
4. Al cerrar el PRP entero, marcar la entry como CERRADO + commit hash del merge a `main`.

## Carpetas hermanas

- [`.claude/memory/feedback/`](../feedback/) — anti-patterns técnicos (NO estados vivos).
- [`.claude/memory/reference/`](../reference/) — referencias operativas estables (NO estados activos).
- [`.claude/memory/user/`](../user/) — perfil del user (NO contexto de PRPs).
- [`.claude/PRPs/`](../../PRPs/) — PRPs activos · cada uno con su sección "Aprendizajes / Self-Annealing" actualizada al cierre.

## Reglas firmes asociadas

- [`session-handoff.md`](../../rules/session-handoff.md) — shape canónico de 7 secciones del handoff entre sesiones.
- [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — al cerrar PRP · checklist 6 ítems incluye actualizar memoria persistente.
- [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) — camino B (cerrar acá + handoff) genera entry en esta carpeta automáticamente.

---

*Convención de README firmada 2026-05-20 (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)).*
