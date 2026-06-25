---
name: log-chronology-append-only
description: Formato canónico append-only del log cronológico de memoria · 6 tipos de evento · cero backfill · cero modificación retroactiva.
type: rule
source: .claude/references/external-doctrine/karpathy-llm-wiki.md
applies-to: edición de .claude/memory/log.md (cierre de PRP · decisión arquitectónica · incidente · pivot · hito · lint mensual)
---

## Overview

> **`.claude/memory/log.md` es la cronología append-only del proyecto.** Cada entrada es un h2 con prefijo `[YYYY-MM-DD] <op> | <título corto>` + Resumen / Detalle / Refs. Cero modificación retroactiva. Cero backfill.

**Por qué firme:** sin formato fijo, el log se vuelve un cajón heterogéneo que pierde valor de consulta. Con formato canónico, `grep "^## \["` filtra por tipo y por fecha de forma determinística — y el agente puede consultar incidentes, decisiones o cierres pasados sin re-leer todo el archivo. Refinamiento adoptado del gist Karpathy llm-wiki § *"Indexing and logging"* (sección 58 del snapshot · ver [.claude/references/external-doctrine/karpathy-llm-wiki.md](../references/external-doctrine/karpathy-llm-wiki.md)). Adaptado al proyecto con 6 tipos `<op>` específicos del proyecto.

## When

**Aplica a:**

- Cierre de un PRP del producto o del refactor (cualquier modo C · cualquier mini-PRP).
- Decisión arquitectónica firmada con tag 🔵 + justificación 1-frase del user.
- Incidente (bug en producción · regresión detectada · CI roto · bloqueo de flujo).
- Pivote estratégico (rename · rama nueva del flujo · cambio de stack semi-rígido).
- Hito mayor (PR mergeado · primer release · onboarding completo).
- Ejecución del lint de memoria periódico (ver [`lint-memory-periodic.md`](./lint-memory-periodic.md)).

**NO aplica a:**

- Notas de trabajo intermedio · checkpoints técnicos · handoffs (esos van en `.claude/memory/project/`).
- Aprendizajes técnicos genéricos (esos van en `.claude/memory/feedback/` o `reference/`).

## Process

**Definición del formato literal**

Cada entrada del log es un h2 con prefijo de fecha entre corchetes + tipo de evento + título corto, seguido de líneas Resumen + Detalle (opcional) + Refs:

    [encabezado h2 con la sintaxis exacta:] ## [YYYY-MM-DD] <op> | <título corto>

    **Resumen:** 1-2 frases describiendo qué pasó.
    **Detalle:** opcional · 2-5 líneas si el evento amerita.
    **Refs:** commit `<hash>` · PRP-NNN · memoria `<path>` · ticket `<id>` (al menos 1 ref operativa).

> El ejemplo está indentado con 4 espacios (NO fenced code block) para que el `grep "^## \["` no matchee el propio ejemplo. Patrón aplicable también en el log real.

**6 tipos `<op>` válidos:**

| `<op>` | Cuándo usarlo | Ejemplo ilustrativo |
|---|---|---|
| `prp-close` | Cierre de un PRP del producto o del refactor (cualquier modo C · cualquier mini-PRP) | `## [YYYY-MM-DD] prp-close \| PRP-NNN cerrado · descripción corta` |
| `decision` | Decisión arquitectónica firmada con tag 🔵 + justificación 1-frase del user | `## [YYYY-MM-DD] decision \| Skill /refactor dedicado en vez de convención débil · Bif 1 firmada user "A"` |
| `incident` | Bug en producción · regresión detectada · CI roto · bloqueo de flujo | `## [YYYY-MM-DD] incident \| spec prp-NNN-feature.spec.ts:NN timeout Xs en CI remoto · cold-compile · fix timeout Ys` |
| `directional` | Cambio de dirección estratégica del proyecto (pivote · rename · rama nueva del flujo) | `## [YYYY-MM-DD] directional \| Vocabulario español neutro AR-friendly + LATAM-friendly · descarta argentinismos puros` |
| `milestone` | Hito mayor (PR mergeado · primer release · onboarding) | `## [YYYY-MM-DD] milestone \| PR #N PRP-NNN feature mergeado a main · <hash>` |
| `lint` | Ejecución del lint de memoria periódico (ver [`lint-memory-periodic.md`](./lint-memory-periodic.md)) | `## [2026-XX-XX] lint \| run mensual · 3 contradicciones · 2 stale claims · 1 orphan file marginado` |

**Reglas operativas firmes:**

- ✅ **Append-only** · cero modificación retroactiva · cero borrado de entradas pasadas.
- ✅ **Orden cronológico estricto** · entradas nuevas se agregan al final del archivo.
- ✅ **1 entrada por evento** · cada `prp-close` · `decision` · etc. genera 1 sola entrada · NO duplicar.
- ❌ **NO backfill** · el pasado pre-YYYY-MM-DD NO se reconstruye · queda en `git log` + `.claude/memory/project/*.md` + banner CLAUDE.md.
- ❌ **NO modificar** entradas pasadas (excepto fix de typo dentro del mismo commit que las creó · NO post-hoc).

**Tip operativo de consulta:**

```bash
# Últimas 5 entradas
grep "^## \[" .claude/memory/log.md | tail -5

# Todas las decisiones arquitectónicas
grep "^## \[.*\] decision" .claude/memory/log.md

# Eventos de un mes específico
grep "^## \[2026-05" .claude/memory/log.md

# Todos los incidentes en producción
grep "^## \[.*\] incident" .claude/memory/log.md
```

## Archivado periódico (cada 14 días)

> **Pieza de gobierno firmada (Modo A consolidado · firma 🔵 user) que cierra el riesgo de crecimiento indefinido del log.** Karpathy llm-wiki NO propone threshold cuantitativo (verificado en snapshot inmutable `karpathy-llm-wiki.md` § "Indexing and logging"); esta sección extrapola prudentemente el espíritu *"helps the LLM understand what's been done recently"* — solo lo reciente queda en `log.md` activo · el resto se preserva en [`_archive/log-YYYY-MM-DD.md`](../memory/_archive/) con cross-ref.

**Convención firme:**

- **Disparador:** fila en [`docs/logs/deadlines.md`](../../docs/logs/deadlines.md) con fecha disparador cada 14 días (paridad operativa con DT-NNN lint memoria · DT-NNN lint código).
- **Detección:** [`/arrancar`](../skills/arrancar/SKILL.md) Paso 5 lee `deadlines.md` al boot · output template § Deadlines emite aviso cuando la fecha está vencida o ≤7 días.
- **Auto-propuesta contractual del agente:** cuando el deadline tiene comando ejecutable (`bash scripts/archive-log.sh`) y está vencido o ≤7 días, el agente DEBE proponer la ejecución al user al inicio de la respuesta · cero "esperar a que el user lo pida" · cero "lo dejo para otra sesión". El user firma SÍ/NO y el agente ejecuta.
- **Ejecución:** [`scripts/archive-log.sh`](../../scripts/archive-log.sh) materializa los 6 pasos del procedimiento (idempotente · revertible con `git revert`).
- **Entry de cierre:** post-archivado, el script agrega 1 entry tipo `lint` al `log.md` raíz auto-documentando qué se archivó (paridad con cómo el lint de memoria mensual usa `lint` como op).

**Los 6 pasos del procedimiento (los ejecuta el script):**

1. **Pre-condición · working tree limpio:** `git status --porcelain` retorna vacío. ABORT si hay cambios sin commitear (la operación toca 3 archivos · necesita atomicidad).
2. **Snapshot del `log.md`:** copiar el archivo entero a `.claude/memory/_archive/log-YYYY-MM-DD.md` (donde `YYYY-MM-DD` es la fecha del día del archivado · NO la fecha de las entries archivadas).
3. **Truncar `log.md`:** dejar solo (a) frontmatter YAML + heading + intro blockquote + sección "Cómo usar este archivo" (todo el header pre-entries · líneas 1 hasta antes del primer `## [`) + (b) 1 línea de cross-ref *"entries pre-YYYY-MM-DD viven en `_archive/log-YYYY-MM-DD.md`"* + (c) 1 entry tipo `lint` auto-documentando el archivado.
4. **Actualizar `docs/logs/deadlines.md`:** mover la fila actual a § Histórico (con resultado *"archivado ejecutado · `_archive/log-YYYY-MM-DD.md`"*) + agregar fila nueva en § Activos con fecha +14 días.
5. **Output al user:** reportar los 3 archivos modificados/creados + sugerir mensaje de commit canónico. **NO commitea automáticamente** · el user revisa diff y commitea (paridad con `lint-memory.sh` · safety contractual).
6. **Verificación post-script:** `wc -l .claude/memory/log.md` confirma reducción · `ls .claude/memory/_archive/log-YYYY-MM-DD.md` confirma archivo nuevo · `grep "YYYY-MM-DD+14" docs/logs/deadlines.md § Activos` confirma deadline renovado.

**Garantías:**

| Riesgo | Mitigación |
|---|---|
| Agente olvida el deadline | `/arrancar` Paso 5 lee `deadlines.md` al boot · output template emite aviso cada sesión hasta que se ejecute. Auto-propuesta contractual del agente (NO depende de recuerdo humano). |
| Se archiva mal (entries equivocadas) | Script idempotente · pre-condición working tree limpio · todo en 1 batch revertible con `git revert <hash>` post-commit del user. |
| Olvida actualizar el deadline post-archivado | Paso 4 del script es contractual · sin actualizar `deadlines.md` el script ABORTA antes del output. |
| Deadline vencido y sesión no trabaja ese día | Sin problema · siguiente sesión `/arrancar` ve el aviso y dispara auto-propuesta. |
| Script falla mid-ejecución | Working tree dirty post-fail · operación NO commiteada (el user no commiteó aún) · `git restore .` revierte y se relanza el script. |

**Tipo `<op>` para la entry de cierre:** `lint` (reusa el tipo existente · paridad con lint de memoria mensual que también usa `lint`). NO se agrega tipo nuevo `archive` para evitar inflar el set canónico de 6 tipos.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Modifico la entrada de ayer · agregué nueva info que apareció hoy" | NO. Append-only es contractual · agregar entrada nueva con cross-reference a la anterior. Modificar una entrada pasada rompe la confianza del log como fuente cronológica. |
| "Este evento no encaja en los 6 tipos · invento uno nuevo" | NO. Los 6 tipos cubren el grueso de eventos relevantes. Si genuinamente falta uno, abrir decisión arquitectónica firmada (con tag 🔵) y agregar tipo nuevo a esta regla — no improvisar `<op>` sobre la marcha. |

## Red flags

- 🚩 Estás editando una entrada pasada del log para "agregar contexto que apareció después".
- 🚩 La entrada nueva usa un `<op>` que no está en los 6 oficiales (typo · convención propia · improvisación).
- 🚩 El h2 tiene la fecha en otro formato (`2026/05/07` · `7-may-2026`) — debe ser `[YYYY-MM-DD]` exacto.
- 🚩 Falta sección `**Refs:**` con al menos 1 ref operativa (commit · PRP · memoria · ticket).

## Verification

- [ ] Entrada nueva agregada al final del archivo (cronológico estricto).
- [ ] H2 cumple sintaxis exacta `## [YYYY-MM-DD] <op> | <título corto>` con uno de los 6 tipos válidos.
- [ ] Resumen + (Detalle opcional) + Refs presentes y coherentes con el evento.
- [ ] Cero modificación de entradas pasadas (verificable con `git diff`).
- [ ] `grep "^## \[" log.md` retorna las entradas nuevas sin matchear ejemplos indentados.

**Cross-reference firme:**

- Hermana: [`lint-memory-periodic.md`](./lint-memory-periodic.md) (lint mensual genera entradas tipo `lint`).
- Hermana operativa: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) ítem 6 (commit local con resumen + aprendizajes · esta regla canoniza el formato del log que la golden-rule alimenta).

> **Stack de documentación · 3 reglas paralelas del ciclo doc/memoria.** Esta regla forma parte del bloque "documentación y memoria" junto a [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) y [`lint-memory-periodic.md`](./lint-memory-periodic.md). Roles complementarios sin solapamiento: (1) **golden-rule** = CUÁNDO documentar (sincrónica al cierre · bloqueante). (2) **lint-memory** = AUDITAR memoria periódicamente (asincrónica cadencia mensual). (3) **log-chronology (esta)** = FORMATO canónico de la cronología (append-only · 6 tipos de evento · cero modificación retroactiva). Las 3 severidades divergen legítimamente (bloqueante · preventiva · de integridad) porque protegen distintas capas del mismo stack.
