---
name: pre-validation-inherited-regression
description: Antes de la primera fase del bucle, verificar que el PRP no quiebra invariantes de PRPs previos · specs heredados verdes pre-cambio
type: rule
applies-to: inicio del paso 3 en Modo C
---

## Overview

> **Antes de la primera fase del bucle agéntico, el agente verifica que el PRP en curso no quiebra invariantes de PRPs previos.**

**Por qué esta regla existe:** sin esto, los specs codificados acumulativos quedan reactivos (CI los corre después del push, demasiado tarde). Con esto, el agente los corre proactivamente antes de tocar código. Si un spec heredado falla pre-fase, es bug introducido en commits previos no cubiertos por CI — confundirlo con bug de tu PRP te hace debuggear el lugar equivocado durante horas.

## When

**Aplica a:**

- Inicio del paso 3 (Modo C) · antes de arrancar Fase 1 del bucle.
- Cuando un PRP toca archivos compartidos con PRPs previos (regla aplica casi siempre).

**NO aplica a:**

- PRPs de infra pura (CI/seed/refactor de gobierno) sin código de aplicación tocado.
- Modo A (sin fases) o Modo B (skills cerrados).

## Process

**Procedimiento (5 pasos · ~30s total):**

1. `git diff main --name-only` para listar archivos / tablas que el PRP va a tocar.
2. Cruzar contra `tests/<carpeta-de-regresión>/COVERAGE.md` (mapa archivo/tabla → spec heredado · tu proyecto genera este índice cuando acumula suite de regresión).
3. Para cada match, ejecutar el spec heredado localmente con `npm run test:e2e -- tests/e2e/regression/<spec>.spec.ts`.
4. Si alguno falla **antes** de tocar el código del PRP nuevo → alguien rompió código heredado en commits anteriores no cubiertos por CI. Como el bug está fuera del scope técnico del PRP en curso → aplicar [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (regla #24 · DT en el acto · 8 campos contractuales · disparador "próximo PRP que toque el archivo heredado") + abrir incidente al inicio del bucle. NO mezclar con trabajo del PRP. Excepción: si el user firma explícitamente que el fix entra al scope actual (paridad [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) → documentar el caso vecino como spec en `tests/e2e/regression/` o `tests/sql/` + nota en PRP § Aprendizajes (paridad regla [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md)) + fix con regression-first FIRME · cero fila al CSV en este momento (CSV es DUEÑO ÚNICO del paso 5 `/validar` · paridad [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) § Mapping · anti-pattern de un PRP upstream).
5. Si todos pasan → arrancar Fase 1.

### Matriz "escenarios → gate level" (refinamiento upstream · firma 🔵 user)

Antes de aplicar los 5 pasos canónicos, el agente clasifica el contexto en uno de 4 escenarios. NO siempre se corre el suite E2E completo (~6-10 min) · la heurística determina el gate apropiado sin perder rigor.

| # | Escenario | Gate level | Acción |
|---|---|---|---|
| **A** | Último merge a `main` pasó CI verde reciente (≤24h) **Y** commits intermedios sobre `dev` son **docs-only** (cero `src/` · cero `db/migrations/` · cero `tests/`) | 🟢 ligero | Skip suite E2E · documentar 1 línea en el PRP que aplica escenario A + ref al SHA del último merge verde · arrancar Fase 1. |
| **B** | Commits intermedios tocan código de producción **Y** `COVERAGE.md` tiene entradas para esos archivos | 🟡 específico | Aplicar 5 pasos canónicos · correr solo los specs heredados que matchean los archivos del diff (no suite completo). |
| **C** | PRP de **infra pura** (CI · seed · refactor de gobierno textual) sin código de aplicación tocado | 🟢 skip documentado | Skip Paso 0 · documentar 1 línea en el PRP que aplica escenario C · arrancar Fase 1. |
| **D** | Cualquier otro caso (suite stale >24h · `COVERAGE.md` sin entradas para los archivos del scope · duda genuina) | 🔴 completo | Aplicar 5 pasos canónicos full · correr suite E2E completo (`npm run test:e2e -- tests/e2e/regression/`) · gate bloqueante hasta verde. |

**Criterio firme para "docs-only" (escenario A):** `git diff <last-merge>..HEAD --name-only` retorna solo paths en `docs/` · `.claude/` · `*.md` raíz. Si toca cualquier archivo bajo `src/` · `db/` · `tests/` · `scripts/` · `.github/` → NO es docs-only · cae en B o D.

**Origen:** anti-pattern detectado durante un PRP upstream · el skill `/implementar` Paso 0 NO tenía la matriz explícita · el agente improvisó la heurística válida pero no codificada · este refinamiento la formaliza como SoT.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Mi PRP no toca código heredado, salto la pre-validación" | NO. La pre-validación es barata (~30s) y atrapa rotura silenciosa de commits previos no cubiertos por CI. Saltarla normaliza el ruido en CI y deja al agente sin baseline confiable para distinguir bugs propios de heredados. |
| "Si los specs heredados están rotos, los arreglo después junto con el PRP" | NO. Un spec roto antes de tocar tu código es señal de bug heredado, no de tu trabajo. Mezclarlo con tu PRP confunde el root cause y te hace debuggear el lugar equivocado. Abrir incidente separado y dejar el spec heredado en el log al inicio del bucle. |

## Red flags

- 🚩 Arrancaste Fase 1 sin haber corrido los specs heredados de los archivos que vas a tocar.
- 🚩 Un spec heredado falla durante tu Fase 1 y "asumís" que tu cambio es la causa sin verificar `git stash` + re-correr.
- 🚩 No existe `tests/e2e/regression/COVERAGE.md` para mapear archivo → spec (ese mapa es prerequisito de la regla).
- 🚩 El git diff main..HEAD del PRP toca 5+ archivos y solo corriste 1 spec heredado.

## Verification

- [ ] `git diff main --name-only` corrido + cruzado contra COVERAGE.md.
- [ ] Cada spec heredado matcheado corre verde antes de tocar código del PRP nuevo.
- [ ] Si algún spec falla pre-fase: incidente abierto al inicio del bucle (NO mezclar con trabajo del PRP).
- [ ] El commit de Fase 1 NO incluye fix de spec heredado roto (eso va en commit separado del incidente).

**Cross-reference firme:**

- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (regla #24 · si el spec heredado falla pre-Fase 1 · DT en el acto · 8 campos contractuales · disparador "próximo PRP que toque el archivo heredado").
- Hermana operativa: [`regression-first-on-fix.md`](./regression-first-on-fix.md) (caso (b) bug heredado fuera de scope · clasificación binaria del bug detectado durante el bucle).
- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (si el user decide adoptar el fix al scope actual · firma explícita).
- Refuerza: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (suite acumulativo · spec heredado verde = baseline confiable).
