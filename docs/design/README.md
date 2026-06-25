# `docs/design/` · Diseño del producto · flujo Claude Design

> **Qué es:** carpeta agrupadora del flujo de diseño visual del producto. Agrupa las dos hermanas que materializan **input** y **output** de Claude Design (briefs/bundles que se le pasan al proveedor + UI kits/tokens/previews curados al repo) bajo una única raíz semántica · paridad con la separación firme `cómo trabajamos` (`.claude/`) vs `qué construimos` (`docs/`).
>
> **Por qué se creó:** convención del pack `workflow-base` · materializa la regla #28 [`claude-design-matrix.md`](../../.claude/rules/claude-design-matrix.md) que define el orden firme `PRP → Claude Design → Implementación`. Sin una raíz explícita en el filesystem, los briefs y los bundles quedarían dispersos · perderían trazabilidad input→output y reusabilidad entre PRPs.
>
> **Para qué sirve:** consultar el ciclo completo del handoff visual sin saltar entre carpetas sueltas · servir de SoT del estado del diseño (qué briefs hay · qué bundles llegaron · qué UI kits son referencia para el código de `src/`) · alinear el flujo de la matriz Claude Design con una jerarquía explícita.

> ⚙️ **Stack adaptation banner:** los ejemplos de tokens del runtime asumen un stack típico del pack (Next.js · `src/app/globals.css` + `src/lib/theme.ts` como espejo del DS · demos en `src/app/dev/`). Si tu proyecto usa otro stack/framework, adaptá los paths concretos · el principio (input/output del diseño versionado · bundles inmutables del proveedor · referencia canónica para implementar UI) es universal.

## Convención

- **Input vs output:** [`handoff/`](./handoff/) es input (briefs que se pegan en una sesión Claude Design + bundles cerrados de output del proveedor preservados inmutables) · [`reference/`](./reference/) es el output curado al repo (UI kits con prototipos + HTML previews del DS + tokens visuales canónicos).
- **Bundles inmutables:** las sub-carpetas por PRP/TASK dentro de `handoff/` y `reference/ui_kits/` son outputs literales del proveedor · NO se editan post-recepción · NO se renombran ni se aplanan.
- **Naming:** sub-carpetas en kebab-case por PRP/TASK (`prp-NNN-<feature>/` · `task-NNN-<feature>-brief.md`). Briefs sueltos como `.md` cuando el handoff es simple · bundles como sub-carpeta cuando hay múltiples archivos. Naming técnico en inglés industria-estándar (regla #31 [`routing-paths-in-english.md`](../../.claude/rules/routing-paths-in-english.md)) · copy de los mockups en el idioma del producto.
- **Refs cruzados:** al integrar un UI kit a `src/`, traducir los prototipos (inline styles + iconografía por CDN) al stack real (ej: TSX + Tailwind con tokens del DS) · NO copiar el prototipo tal cual.
- **Vacío al boot del pack:** las sub-carpetas de contenido (`handoff/<prp-NNN>/` · `reference/preview/` · `reference/ui_kits/<feature>/`) arrancan vacías · el adopter las llena conforme cada PRP que toca UI pasa por Claude Design.

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`handoff/`](./handoff/) | **Input** para Claude Design · briefs sueltos (`task-NNN-*-brief.md` · `prp-NNN-*-brief.md`) + bundles cerrados de output del proveedor |
| [`reference/`](./reference/) | **Output** curado al repo · UI kits con prototipos + HTML previews del DS en aislamiento + bundles cerrados por PRP · referencia canónica para implementar UI nueva en `src/` |

## Carpetas hermanas

- [`../product/references/`](../product/references/) — docs del bootstrap del producto (PRD · vision · roadmap inicial) + rules del producto · contexto que alimenta los briefs de diseño.
- [`../logs/`](../logs/) — logs cronológicos vivos del proyecto (`technical-debt.md` · `deadlines.md` · etc).

## Reglas firmes asociadas

- [`../../.claude/rules/claude-design-matrix.md`](../../.claude/rules/claude-design-matrix.md) — matriz de decisión sobre cuándo abrir sesión Claude Design vs primitivos directos del DS (regla #28 · define el flujo que esta carpeta materializa).
- [`../../.claude/rules/folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22 · esta carpeta cumple desde el día 1).
- [`../../.claude/rules/heuristica-referente-mercado.md`](../../.claude/rules/heuristica-referente-mercado.md) — el referente del rubro es el anchor de las decisiones de diseño que alimentan los briefs (regla #29).

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
