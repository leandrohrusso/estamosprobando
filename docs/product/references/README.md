# `docs/product/references/` · Source of Truth de producto del proyecto

> **Qué es:** carpeta canónica donde viven los docs de referencia del producto (`PRD.md` · `product-vision.md` · `product-roadmap.md`) que el user trae al bootstrap del proyecto. Son la Source of Truth (SoT) del producto a lo largo de toda la vida del proyecto.
>
> **Por qué se creó:** path contractual codificado por regla firme [`product-docs-as-bootstrap-sot.md`](../../../.claude/rules/product-docs-as-bootstrap-sot.md). El skill [`/arrancar`](../../../.claude/skills/arrancar/SKILL.md) detecta estado post-template y solicita los docs explícitamente antes de proponer el llenado mecánico de `BUSINESS_LOGIC.md` + `CLAUDE.md` + `product-roadmap.md`. Sin esta carpeta + sin docs del user, el bootstrap del proyecto queda no auditable.
>
> **Para qué sirve:** (a) alojar los docs de producto inmutables que alimentan los placeholders del template al bootstrap · (b) servir de referencia consultable durante toda la vida del proyecto · cualquier sesión futura del agente que necesite recordar identidad / stack / constraints / features / roadmap lee acá ANTES de preguntar al user.

## Convención

- **Naming:** flexible (el user usa el suyo · `PRD.md` · `product-requirements.md` · `vision.md` · etc).
- **Formato:** markdown `.md` obligatorio · cero binarios (`pdf` · `docx` · `xlsx` · imágenes) · cero textos planos sin formato (`txt`). Si el doc original vive en otro formato (Notion · Google Docs · PDF), exportar a markdown antes de commitear.
- **Inmutabilidad post-bootstrap:** los docs NO se borran ni reescriben en silencio · si el producto pivota, se versiona con commit nuevo y el doc anterior queda en git history accesible (paridad regla #20 [`log-chronology-append-only.md`](../../../.claude/rules/log-chronology-append-only.md)).
- **Path estricto:** `docs/product/references/<doc>.md` · cero docs viviendo en otro lado del repo.

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`rules/`](./rules/) | Reglas firmes del PRODUCTO (no del flujo) · constraints no negociables · vocabulario canónico del rubro · principios del producto. Shape narrativo (NO obliga shape P8). |

## Archivos esperados al cierre del bootstrap

| Archivo | Obligatoriedad | Rol |
|---|---|---|
| `<PRD>.md` (naming flexible) | ✅ Mínimo obligatorio | Product Requirements Document · qué construye el producto · features core · constraints del dominio. |
| `product-vision.md` | Opcional (recomendado) | Visión a largo plazo · narrativa estratégica del producto · magic moment del usuario final. |
| `product-roadmap.md` | Opcional (recomendado) | Roadmap inicial por fases · alimenta `docs/product/product-roadmap.md` (que es el roadmap operativo del proyecto). |

## Carpetas hermanas

- [`docs/product/`](../) — carpeta padre · contiene `product-roadmap.md` operativo (vivo · trackea progreso de tasks) que se nutre del `product-roadmap.md` de referencia que vive acá.
- [`docs/product/references/rules/`](./rules/) — subcarpeta para reglas firmes del producto (shape narrativo · distinto a las reglas del flujo en `.claude/rules/`).

## Cómo agregar docs nuevos (durante el bootstrap)

1. El user trae el(los) doc(s) de producto · mínimo PRD.
2. Convertir a markdown si vienen en otro formato (cero binarios · cero `.txt`).
3. Commitear en este path con commit dedicado · mensaje sugerido: `docs(product): docs de producto del bootstrap · <lista de archivos>`.
4. El skill [`/arrancar`](../../../.claude/skills/arrancar/SKILL.md) (sub-paso 1.b) los lee íntegros · sintetiza al user · espera OK antes de arrancar el llenado mecánico.

## Cómo agregar docs nuevos (post-bootstrap · pivote del producto)

1. NO borrar el doc existente.
2. Crear archivo nuevo con versión (`PRD-v2.md` · `product-vision-2026Q4.md` · etc) O hacer commit nuevo sobre el archivo existente con mensaje explícito del cambio.
3. Sumar entry en `.claude/memory/log.md` tipo `directional` documentando el pivote y referenciando el commit.

---

*README firmado al adoptar regla [`product-docs-as-bootstrap-sot.md`](../../../.claude/rules/product-docs-as-bootstrap-sot.md) (regla #36 · pack `workflow-base`).*
