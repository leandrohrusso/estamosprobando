# `docs/design/handoff/` · Handoff briefs · input para Claude Design

> **Qué es:** carpeta de briefs PARA Claude Design + bundles cerrados de los handoffs ya recibidos. Cada brief es un documento autocontenido que se pega como primer mensaje en una sesión nueva de Claude Design ([claude.ai/design](https://claude.ai/design)) · y cada bundle (sub-carpeta `prp-NNN-*/`) es output inmutable del proveedor.
>
> **Por qué se creó:** materializar el lado **input** del flujo `PRP → Claude Design → Implementación` definido por la regla #28 [`claude-design-matrix.md`](../../../.claude/rules/claude-design-matrix.md). Sin esta carpeta, los briefs y bundles quedarían dispersos · perderían trazabilidad y reusabilidad entre PRPs.
>
> **Para qué sirve:** servir de SoT del input visual de cada PRP que requirió Claude Design · preservar el bundle del proveedor inmutable · indexar el estado del handoff (recibido vs implementado).

## Convención

- **Briefs como archivos sueltos:** `task-NNN-<feature>-brief.md` o `prp-NNN-<feature>-brief.md` para tasks/PRPs con brief simple.
- **Bundles como sub-carpetas:** `prp-NNN-<feature>/` cuando el handoff tiene múltiples archivos (HTML + prototipos + chats + project files). El bundle es **inmutable** · NO se edita post-recepción · NO se renombra.
- **Cómo se usa un brief:** abrir [claude.ai/design](https://claude.ai/design) → New Project → pegar el contenido del brief en el chat → iterar hasta output satisfactorio → handoff to Claude Code → integrar al repo traduciendo el prototipo al stack real.
- **Vacío al boot del pack:** sin briefs ni bundles al arrancar · el adopter agrega uno por cada PRP/TASK que la matriz Claude Design marque como `SÍ` o `CHICO`.

## Briefs sueltos (raíz)

_(vacío al boot · llenar con `task-NNN-*-brief.md` / `prp-NNN-*-brief.md` conforme lleguen)_

| Brief | Task/PRP | Estado | UI kit resultado |
|---|---|---|---|
| — | — | — | — |

## Bundles cerrados por PRP (subcarpetas)

_(vacío al boot · llenar con `prp-NNN-<feature>/` cuando un handoff tiene múltiples archivos)_

| Sub-carpeta | PRP | Estado | Contenido |
|---|---|---|---|
| — | — | — | — |

## Cómo agregar un handoff nuevo

1. Verificar que la superficie nueva cae en `SÍ` o `CHICO` de la matriz Claude Design (regla #28 [`claude-design-matrix.md`](../../../.claude/rules/claude-design-matrix.md)).
2. Armar el brief siguiendo el formato canónico (contexto + estructura + estados a mockupear + copy clave + qué NO entra + cómo entregar) · guardarlo como `prp-NNN-<feature>-brief.md` (brief simple) o crear sub-carpeta `prp-NNN-<feature>/` (handoff con múltiples archivos).
3. Pasar el brief por Claude Design · al recibir el output, preservar el bundle inmutable + curar lo reusable a [`../reference/`](../reference/).
4. Actualizar las tablas de este README con la fila nueva (estado + UI kit resultado).

## Carpetas hermanas

- [`../reference/`](../reference/) — UI kits resultado de los handoffs + tokens del DS + HTML previews (output curado al repo).
- [`../../product/references/`](../../product/references/) — strategy + constraints + vocabulario del producto · contexto que alimenta los briefs.

## Reglas firmes asociadas

- [`../../../.claude/rules/claude-design-matrix.md`](../../../.claude/rules/claude-design-matrix.md) — matriz de decisión sobre cuándo abrir sesión Claude Design · los briefs viven acá (regla #28).
- [`../../../.claude/rules/heuristica-referente-mercado.md`](../../../.claude/rules/heuristica-referente-mercado.md) — el referente del rubro anchorea las decisiones de los briefs (regla #29).
- [`../../../.claude/rules/folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22).

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
