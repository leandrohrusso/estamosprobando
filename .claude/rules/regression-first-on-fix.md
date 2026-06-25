---
name: regression-first-on-fix
description: Ante un bug descubierto, el caso de regresión se documenta ANTES del fix · 1-2 filas vecinas con mismo root cause
type: rule
applies-to: bugs detectados durante /implementar (paso 3) y filas Falla durante /validar (paso 5)
---

## Overview

> **Ante un bug descubierto, el caso de regresión se documenta ANTES del fix, no después.**

**Por qué esta regla existe:** documentar después del fix es opcional y se omite bajo presión. Documentar antes forza root cause analysis (no fix de síntoma), garantiza que el caso queda en el suite de regresión, y si el fix introduce un bug nuevo el caso original sigue verificable. Cuando un bug se fixea sin caso codificado, vuelve a aparecer meses después en producción (típicamente al refactorear el archivo) porque nada lo bloquea. La regla atrapa el patrón exigiendo el caso antes que el código.

## When

**Aplica a:**

- Bugs detectados durante `/implementar` (paso 3 del Modo C).
- Filas marcadas `Falla` durante `/validar` (paso 5 del Modo C).
- Hallazgos de `/ultrareview` (sub-paso 6.◆).
- Bugs heredados detectados durante pre-validación de regresión (regla `pre-validation-inherited-regression`).

## Process

**Reglas operativas:**

1. **Bug detectado durante el PRP en curso · clasificación binaria:**
   - **(a) Dentro del scope del PRP actual** → documentar el caso ANTES del fix en el canal que aplique al paso del flujo en curso · paso 3 (`/implementar`) → spec en `tests/e2e/regression/` o `tests/sql/` + nota en PRP § Aprendizajes (paridad regla [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md)) · paso 5 (`/validar`) → fila al CSV (paridad regla [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) § Mapping paso del flujo → ítems · CSV es DUEÑO ÚNICO del paso 5 · anti-pattern de un PRP upstream). Después del documentar · fixear con regression-first FIRME ([`always-fix-all-bugs.md`](./always-fix-all-bugs.md)).
   - **(b) Fuera del scope del PRP actual** → **DT obligatoria en el acto** según [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (definición canónica · 8 campos contractuales · sin esperar al cierre). Después · si la deuda incluye patrón replicable · sumar memoria persistente en `feedback/` o `reference/` (paso 3 de esa regla). El fix futuro lo cierra el PRP destino que indique la fila DT.
2. **Fila `Falla` en CSV** (aplica en paso 5 `/validar` donde el CSV es DUEÑO ÚNICO · en paso 3 los casos vecinos van como specs adicionales en `tests/e2e/regression/` o `tests/sql/`) → ANTES del fix agregar 1-2 filas vecinas (casos adyacentes que el root cause podría tocar). Re-test la fila original + las vecinas, no solo la original.
3. **Bug en capa transversal** (RLS, middleware, audit, helpers compartidos) → sumar caso al CSV con marca de "transversal" o test de regresión en archivo apropiado (`tests/sql/` o `tests/e2e/regression/`).

**Heurística de "filas vecinas":**

> 1-2 casos que comparten root cause con el original (mismo path con distinto rol, misma policy con distinta condición, mismo helper con distinto caller).

Ejemplos de filas vecinas correctas:

- Bug original: `softDeleteX` no bloquea con entidad en estado terminal → vecino: `softDeleteY` (mismo patrón en módulo hermano · simetría entre entidades · adaptá a tu dominio).
- Bug original: policy RLS rechaza UPDATE silenciosamente → vecino: misma policy con DELETE + mismo policy en módulo hermano.
- Bug original: helper `<helperA>` con ICU U+202F → vecino: `<helperB>` mismo helper, mismo problema (ej: helpers de formateo de fecha/hora · adaptá a tu dominio).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El fix es trivial, no hace falta el caso de regresión" | NO. Trivial hoy ≠ trivial en 6 meses. Sin caso codificado, el bug puede volver con cualquier refactor que toque el archivo. El costo del caso es ~5 min, el costo de no tenerlo se cobra en producción. |
| "Documentar después es lo mismo que antes" | NO. Documentar después es opcional y se omite bajo presión. Documentar antes forza root cause analysis (fix de causa raíz, no de síntoma) y garantiza que el caso queda en el suite acumulativo. |

## Red flags

- 🚩 Estás escribiendo el fix sin haber añadido fila al CSV o spec en `tests/`.
- 🚩 Una fila Falla del CSV solo cubre el caso original sin filas vecinas evaluadas.
- 🚩 El bug es transversal (RLS, middleware, audit) y NO sumaste caso explícito al suite.
- 🚩 El test no falla pre-fix (no reproduce el bug) y solo "verifica que post-fix funcione" — no es regression-first, es happy-path test.

## Verification

- [ ] `git diff` del fix incluye fila CSV o spec en `tests/e2e/regression/` o `tests/sql/`.
- [ ] Para cada fila Falla, hay 1-2 filas vecinas con mismo root cause evaluadas (incluso si terminan verdes).
- [ ] El test reproduce el bug pre-fix (assertion roja antes del fix, verde después · verificable revirtiendo el fix temporalmente).
- [ ] Si el bug es transversal: caso explícito en suite con marca "transversal" en el CSV o nombre del spec.

**Cross-reference firme:**

- Hermana operativa: [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) (toda detección dentro de scope se fixea · esta regla codifica el cómo · regression-first FIRME).
- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (caso (b) bug fuera de scope · DT en el acto · esta regla detecta la clasificación binaria).
- Hermana operativa: [`pre-validation-inherited-regression.md`](./pre-validation-inherited-regression.md) (bugs heredados pre-Fase 1 · fuente del caso (b) cuando el spec heredado falla).
- Refuerza: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (los casos vecinos terminan en `tests/e2e/regression/` o `tests/sql/`).
- Memoria asociada (cuando tu proyecto la genere): `feedback/regression-first-on-fix.md` con ejemplos concretos del repo · vacío al boot del pack.

> **Banner de complementariedad · QUÉ vs CÓMO del fix.** Esta regla y [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) son hermanas operativas paralelas del bloque "flujo de fix de bugs" pero divergen deliberadamente en rol: **always-fix codifica QUÉ se fixea** (orden por severidad descendente critical → normal → nit · todos antes del merge · cero diferimiento por nivel) · **regression-first codifica CÓMO se fixea** (caso codificado en `tests/` antes del fix · 1-2 filas vecinas · clasificación binaria scope-in vs scope-out). Orden operativo: always-fix decide qué entra al batch · regression-first decide cómo se cierra cada item del batch. La asimetría de § Process (always-fix = orden de severidad · regression-first = antes/durante/después + filas vecinas) refleja esos roles complementarios.
