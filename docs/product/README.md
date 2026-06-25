# `docs/product/` · Producto del proyecto · roadmap operativo + backing material

> **Qué es:** carpeta agrupadora del producto del proyecto. Contiene el `product-roadmap.md` operativo (vivo · trackea progreso de tasks por fase) + la sub-carpeta [`references/`](./references/) con los docs de bootstrap del producto (PRD · vision · roadmap inicial) y las rules del producto (constraints · vocabulario · principios). Es el corazón conceptual de "qué construimos" del proyecto.
>
> **Por qué se creó:** convención del pack `workflow-base` · materializa la regla #36 [`product-docs-as-bootstrap-sot.md`](../../.claude/rules/product-docs-as-bootstrap-sot.md) (docs de producto del user como SoT del bootstrap) + la regla #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 1 (roadmap activo del proyecto). Carpeta dedicada vs dumping en raíz de `docs/` por separación clara entre "qué construimos" (acá) vs "cómo trabajamos" (`.claude/`) vs "logs vivos" ([`docs/logs/`](../logs/)).
>
> **Para qué sirve:** (a) alojar el roadmap operativo del proyecto (vivo · trackea progreso de tasks por fase) · (b) servir de entry point para construir el producto (el adopter lee los docs de bootstrap en `references/` en orden vision → PRD → roadmap inicial) · (c) preservar las reglas firmes del producto (constraints no negociables · vocabulario del rubro · principios del producto · viven en `references/rules/`).

## Convención

- **Naming:** kebab-case en inglés para archivos primarios y sub-carpetas.
- **Vocabulario del producto:** el adopter define el vocabulario canónico del rubro en [`BUSINESS_LOGIC.md`](../../BUSINESS_LOGIC.md) + opcionalmente en `references/rules/vocabulario.md` si el rubro lo amerita. UI / copy en idioma del producto (español · português · inglés · etc según el adopter). Naming técnico (tablas · campos · endpoints · path segments) en inglés industria-estándar (regla #31 [`routing-paths-in-english.md`](../../.claude/rules/routing-paths-in-english.md)).
- **Frescura:** `product-roadmap.md` se actualiza en cada cierre de task / fase / PRP (regla #18 [`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 1). Los docs de bootstrap en [`references/`](./references/) son inmutables post-bootstrap (regla #36 · si el producto pivota · versionar con commit nuevo · cero borrado).
- **Backing material vive en `references/`:** PRD · vision · roadmap inicial · rules del producto. NO duplicar contenido entre primarios raíz y references · `product-roadmap.md` consolida progreso operativo · `references/` documenta el blueprint y constraints originales del bootstrap.

## Punto de entrada

**Si arrancás un proyecto nuevo desde el template** (estado post-template detectado por `/arrancar` sub-paso 1.b):

1. El skill [`/arrancar`](../../.claude/skills/arrancar/SKILL.md) solicita docs del producto al user antes del llenado mecánico de placeholders.
2. El user trae mínimo PRD (opcional `product-vision.md` + `product-roadmap.md` inicial) · los coloca en [`references/`](./references/) (path estricto · regla #36).
3. `/arrancar` lee los docs íntegros · sintetiza al user · espera OK · llena placeholders de [`BUSINESS_LOGIC.md`](../../BUSINESS_LOGIC.md) + [`CLAUDE.md`](../../CLAUDE.md) + [`product-roadmap.md`](./product-roadmap.md) raíz.

**Si vas a construir o iterar el producto** en cualquier sesión post-bootstrap, leé en este orden:

1. [`references/<PRD>.md`](./references/) — blueprint del producto · features core · constraints del dominio.
2. [`references/product-vision.md`](./references/) — narrativa estratégica (si existe).
3. [`product-roadmap.md`](./product-roadmap.md) — tasks priorizadas por fase con progreso `[ ]` / `[x]`.

## Archivos primarios (raíz)

| Archivo | Rol |
|---|---|
| [`product-roadmap.md`](./product-roadmap.md) | Roadmap operativo vivo · tasks por fase con `[ ]` / `[x]` · notas + archivos creados/modificados + decisiones + aprendizajes por cierre (regla #18 ítem 1) |

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`references/`](./references/) | Source of Truth del producto · docs del bootstrap (PRD · vision · roadmap inicial) + sub-carpeta [`rules/`](./references/rules/) con reglas firmes del producto (regla #36) |

## Cuándo consultar `references/`

| Situación | Carpeta / archivo |
|---|---|
| *"¿Qué construye el producto · features core · constraints del dominio?"* | [`references/<PRD>.md`](./references/) |
| *"¿Cuál es la visión a largo plazo · magic moment del usuario final?"* | [`references/product-vision.md`](./references/) (si existe) |
| *"¿Cuál fue el roadmap inicial del bootstrap antes de empezar a trackear progreso?"* | [`references/product-roadmap.md`](./references/) (si existe · distinto del roadmap operativo vivo raíz) |
| *"¿Qué reglas firmes del producto aplican al build?"* | [`references/rules/`](./references/rules/) |

## Carpetas hermanas

- [`../logs/`](../logs/) — logs cronológicos vivos del proyecto · timing bidireccional inmediato (`technical-debt.md` · `ultrareview-log.md` · `deadlines.md`).

## Reglas firmes asociadas

- [`../../.claude/rules/folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22 · esta carpeta cumple desde el día 1).
- [`../../.claude/rules/product-docs-as-bootstrap-sot.md`](../../.claude/rules/product-docs-as-bootstrap-sot.md) — docs de producto del user como SoT del bootstrap (regla #36).
- [`../../.claude/rules/golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) — checklist 6 ítems al cierre · ítem 1 actualiza `product-roadmap.md` en cada task / fase / PRP cerrado.

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
