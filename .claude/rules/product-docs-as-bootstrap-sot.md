---
name: product-docs-as-bootstrap-sot
description: Los docs de producto (PRD mínimo · opcional product-vision + product-roadmap) son SoT del bootstrap · viven en docs/product/references/ · alimentan BUSINESS_LOGIC.md + CLAUDE.md + product-roadmap.md al inicio + siguen consultables en sesiones futuras.
type: rule
applies-to: estado post-template (sesión 1 · BUSINESS_LOGIC.md con placeholders · cero PRPs · 1 commit) · /arrancar los solicita antes del llenado mecánico
---

## Overview

> **Todo proyecto creado desde el template `workflow-base` arranca con docs de producto del user como Source of Truth del bootstrap.** Mínimo 1 PRD · opcional `product-vision.md` + `product-roadmap.md` · viven en `docs/product/references/` · `/arrancar` los solicita antes de proponer el llenado de BUSINESS_LOGIC.md + CLAUDE.md + product-roadmap.md + demás placeholders. Los docs son **inmutables post-bootstrap** · sesiones futuras los consultan cuando necesitan recordar identidad / stack / constraints / roadmap del producto.

**Por qué firme:** sin docs fuente, el bootstrap del proyecto queda no auditable · las decisiones de identidad / stack / constraints viven solo en BUSINESS_LOGIC.md (destilado) sin rastro de dónde salieron. El user siempre llega con al menos PRD pensado · el flujo lo respeta como contrato. Path canónico `docs/product/references/` es contractual: cero docs viviendo solo en Notion · cero Google Docs · cero memoria del LLM · todo versionado en git para que cualquier sesión futura los consulte sin credenciales externas.

## When

**Aplica a:**

- **Estado post-template detectado por `/arrancar`** (las 5 condiciones del disparador binario abajo).
- **Re-bootstrap explícito:** el user pivota el producto y reinicia identidad · los docs nuevos se commitean en `docs/product/references/` con commit dedicado · NO se borran los anteriores (paridad cronología append-only de regla #20).

**NO aplica a:**

- Sesiones post-bootstrap del proyecto en curso (BUSINESS_LOGIC.md ya llenado · PRPs activos · roadmap real).
- Modificaciones menores al PRD (typo · clarificación · adición de feature) · esas son commits puntuales sobre el doc existente · no disparan re-bootstrap.

**Disparador binario (5 condiciones · todas deben cumplirse):**

1. `grep "<PROYECTO>" CLAUDE.md` retorna match (CLAUDE.md línea 1 sin reemplazar).
2. `grep -cE "<ej:|TODO|placeholder" BUSINESS_LOGIC.md` retorna ≥3 (placeholders sin llenar).
3. `find .claude/PRPs -name "PRP-*.md" | wc -l` retorna 0 (matchea solo archivos con prefijo `PRP-` · ignora `README.md` de la carpeta y `_template.md`).
4. `git log --oneline | wc -l` retorna ≤ 5.
5. `find docs/product/references -maxdepth 1 -type f -name "*.md" -not -name "README.md" | wc -l` retorna 0.

## Process

**Procedimiento del bootstrap (5 pasos · orden firme):**

1. `/arrancar` detecta estado post-template via sub-paso 1.b del Paso 1 (los 5 chequeos del disparador binario).
2. Antes de proponer el orden mecánico de Pasos 1-7 del README, **pedir docs al user** con las 3 variantes válidas:
   - **Mínimo (siempre obligatorio):** 1 archivo PRD · naming flexible (`PRD.md` · `product-requirements.md` · etc).
   - **Medio:** PRD + 1 de (`product-vision.md` OR `product-roadmap.md`).
   - **Máximo:** PRD + `product-vision.md` + `product-roadmap.md`.
3. El user coloca los archivos en `docs/product/references/` (paste-y-create vía agente · O drop manual del user · cualquier camino).
4. `/arrancar` lee íntegros · sintetiza al user con resumen 5-7 bullets (identidad · stack · constraints · features · roadmap · referente de mercado) · espera OK explícito. **Si la lectura revela una tensión entre un doc de producto y una regla firme del flujo → aplicar la regla operativa de tensiones abajo (DT en el acto · cero dejarla solo en el chat).**
5. Con OK firmado, `/arrancar` arranca los Pasos 1-7 del README usando los docs como input · cada llenado de placeholder trazable a contenido del doc fuente.
6. Al cierre de los Pasos 1-7 · el user commitea + ejecuta el **push fundacional del bootstrap-commit** a `origin/dev` + `origin/dev:dev-backup` (única excepción documentada a regla [`push-and-ci-policy.md`](./push-and-ci-policy.md) § Excepción · bootstrap fundacional · 1 push por proyecto en toda su vida · cero PR · cero CI). Sin este push, el work del bootstrap queda solo local · las 3 ramas remotas no reflejan el bootstrap · cero backup automático posible (hooks Husky dormidos hasta `npm install` de TASK-002).

**Reglas operativas firmes:**

- Los docs son **inmutables post-lectura del bootstrap**. Si el producto pivota, se versiona con commit nuevo · NUNCA se borran ni reescriben en silencio (paridad regla #20 log-chronology-append-only).
- **Naming flexible** (el user usa el que prefiera) · **path canónico estricto** (`docs/product/references/`).
- Si el user trae los docs en formato distinto (`txt` · `pdf` · etc), convertirlos a `.md` antes de commitear · cero binarios en `references/`.
- **Tensión doc-de-producto ↔ regla firme del flujo detectada durante la lectura (paso 4) → registro durable EN EL ACTO.** Si al leer el PRD/docs de producto detectás una tensión entre un doc de producto y una regla firme del flujo (ej: PRD con rutas en español vs regla #31 [`routing-paths-in-english`](./routing-paths-in-english.md) · 15 KPIs en un dashboard vs principio de poca-carga de [`principios-desarrollo-flujo`](./principios-desarrollo-flujo.md) #30 · feature que huele a complejidad ALTA vs regla #13 [`complejidad`](./complejidad.md)), registrala durable en el acto siguiendo regla #24 [`register-out-of-scope-as-dt`](./register-out-of-scope-as-dt.md): el bootstrap **NO es un PRP**, así que la tensión es un hallazgo out-of-scope → DT con disparador objetivo *"al planificar el módulo afectado"* + los 8 campos contractuales que define esa regla (ID · síntoma · archivo/área · PRP destino · severidad · mitigación · disparador · sesión). **Cero dejarla solo en el chat:** anotarla solo en el chat la evapora al cambiar de sesión · la próxima sesión re-lee el PRD con la tensión sin resolver y puede implementarla mal o re-descubrirla de cero. El PRD/doc de producto NO se edita para "resolver" la tensión (los docs son inmutables post-bootstrap · arriba) · la DT preserva el contexto hasta que el PRP del módulo afectado decida cómo reconciliarla.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Tengo la idea del producto clara · improviso BUSINESS_LOGIC.md sin doc fuente" | NO. Sin doc fuente las decisiones del bootstrap no son auditables · el destilado BUSINESS_LOGIC.md queda sin trazabilidad. El user siempre tiene al menos PRD · pedirlo es contractual · no opcional. |
| "El doc vive en Notion / Google Docs · referencio desde BUSINESS_LOGIC.md y listo" | NO. Path canónico `docs/product/references/` es contractual · los docs deben estar versionados con git para sesiones futuras sin credenciales externas. Si el original vive en Notion, exportar a markdown y commitear acá. |
| "Lo leo del Notion del user y lleno BUSINESS_LOGIC.md sin commitear el doc fuente" | NO. Paridad informativa fuente↔destilado solo es verificable si AMBOS están en el repo · sin doc commiteado, *"¿de dónde salió esto?"* queda sin respuesta. |
| "El user trajo solo PRD · pero necesito más info · le pido roadmap igual" | NO. Mínimo válido es PRD · el resto es opcional. Si el PRD no cubre algo crítico (ej: stack), pedirlo como decisión puntual via regla `metodologia-iteracion` · NO bloquear bootstrap por falta de docs opcionales. |

## Red flags

- 🚩 `/arrancar` en estado post-template propone llenar BUSINESS_LOGIC.md sin haber pedido docs primero.
- 🚩 Cierre del bootstrap con `docs/product/references/` sin docs del user (solo `README.md` + `rules/`).
- 🚩 El primer commit del proyecto ya tiene BUSINESS_LOGIC.md llenado pero `docs/product/references/` sin docs fuente · sin trazabilidad.
- 🚩 Sesiones futuras preguntan al user cosas que viven en `docs/product/references/PRD.md` (no consultaron la fuente).
- 🚩 El agente sugiere borrar/reescribir un doc de producto post-bootstrap · cero · son inmutables · pivote = commit nuevo.
- 🚩 Detectaste durante la lectura del PRD una tensión con una regla firme del flujo (ruta en español · KPIs en exceso · complejidad ALTA · etc) y la dejaste solo anotada en el chat · cero fila DT en `docs/logs/technical-debt.md` (se evapora al cambiar de sesión · regla #24).

## Verification

- [ ] Al cierre del bootstrap (post-Pasos 1-7 del README), `ls docs/product/references/*.md` muestra ≥1 archivo del user (PRD mínimo).
- [ ] Los docs están commiteados (no untracked en `git status`).
- [ ] BUSINESS_LOGIC.md llenado tiene paridad informativa con el contenido de los docs fuente.
- [ ] El primer entry tipo `milestone` en `.claude/memory/log.md` referencia los docs commiteados como fuente del bootstrap.
- [ ] Sesiones posteriores que necesitan contexto de producto consultan `docs/product/references/` ANTES de preguntar al user.
- [ ] Toda tensión doc-de-producto ↔ regla firme del flujo detectada durante la lectura quedó registrada como DT en `docs/logs/technical-debt.md` con disparador *"al planificar el módulo afectado"* (regla #24) · cero tensión viviendo solo en el chat.

**Cross-reference firme:**

- Hermana operativa: [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (carpeta `docs/product/references/` tiene README que explica su rol · lectura previa antes de actuar).
- Hermana operativa: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (los docs de producto son fuente prioridad 1 del proyecto · cero suponer · ir a fuente).
- Hermana operativa: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (docs y memoria son parte indispensable de cada task · el bootstrap es la primera task del proyecto · no se cierra sin docs commiteados).
- Hermana operativa: [`documentos-definitivos.md`](./documentos-definitivos.md) (el user trae el PRD ya formado · esta regla NO genera el PRD desde cero · si llegás sin PRD, regla #21 dice avisar antes de armar uno).
- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (regla #24 · **SoT del mecanismo DT** · una tensión doc-de-producto ↔ regla firme detectada durante la lectura del bootstrap es un hallazgo out-of-scope · DT en el acto con disparador *"al planificar el módulo afectado"* · los 8 campos contractuales viven en esa regla · cross-reference, NO copia).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye trazabilidad de decisiones · docs de producto son el rastro auditable del bootstrap).
- Aplicada por: skill [`/arrancar`](../skills/arrancar/SKILL.md) sub-paso 1.b (detección de estado post-template + solicitud de docs antes del orden mecánico).
