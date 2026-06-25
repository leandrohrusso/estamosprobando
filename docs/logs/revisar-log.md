# Revisar Log

> Registro de ejecuciones de **[`/revisar`](../../.claude/skills/revisar/SKILL.md)** (multi-agent local code review · 9 agentes Opus paralelos + consolidator) sobre el producto del adopter.
> **Propósito doble:**
> 1. **Bitácora de auditoría** — qué se revisó · cuándo · qué se encontró · qué se hizo con cada hallazgo.
> 2. **Mapa de cobertura** — qué código YA pasó por revisión local · para detectar áreas sistemáticamente sin revisar y evitar runs redundantes.
>
> **Diferencia con [`docs/logs/ultrareview-log.md`](./ultrareview-log.md) (cloud):**
> - **Cloud (`/ultrareview`)**: 3 agentes en VMs aisladas con verificación independiente · costo en dólares por run · selectivo (decisión user en sub-paso 6.◆ del flujo de 6 pasos · paso 6 [`/entregar`](../../.claude/skills/entregar/SKILL.md)).
> - **Local (`/revisar`)**: 9 agentes Opus en `Explore` subagent_type con verificación cruzada por overlap (≥2 detectores → `verified: true`) · gratis · default SÍ siempre en cada PRP del Modo C.
> - **Calibración**: cuando ambos corren sobre el mismo PRP, comparar outputs en § Calibración cross-reference (vs cloud).
>
> **Diferencia con [`docs/logs/revisar-main-log.md`](./revisar-main-log.md) (hermano holístico):**
> - **`/revisar` (este log · paso 4 del flujo del producto)**: 9 agentes auditan el **diff incremental** vs `main` del PRP en curso · contractual · default SÍ siempre en Modo C · scope acotado al cambio.
> - **`/revisar-main` (lint mensual)**: 9 agentes auditan el estado **completo de `main`** · cero diff · scope holístico por familia técnica con planning automático.
> - **Complementarios** · NO sustitutivos.

---

## Cómo se mantiene este archivo

### Cuándo se actualiza

- **Al lanzar `/revisar`** sobre un PRP en Modo C (paso 4 del flujo de 6 pasos · post-[`/implementar`](../../.claude/skills/implementar/SKILL.md) · pre-[`/validar`](../../.claude/skills/validar/SKILL.md)): el consolidator escribe entrada nueva en § Resumen de runs con metadata del run (LR-NNN · timestamp · base/head SHA · scope · counts por severidad) + filas en § Hallazgos consolidados (1 por bug que pasó el filtro Bif 6 = A).
- **Al fixear** un hallazgo (`🔴 pendiente` → `🟢 fixeado`): actualizar estado en § Hallazgos consolidados con commit SHA + link.
- **Al descartar** un hallazgo conscientemente (`🔴 pendiente` → `⚪ descartado`): actualizar estado con motivo (1 frase).
- **Al cierre de un PRP del producto** que tuvo run de `/revisar`: marcar la fila correspondiente en § Decisiones por PRP con resultado final (cuántos hallazgos cerrados antes del merge).
- **REGLA DE ORO docs y memoria** ([`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.7) aplica a este log con timing bidireccional · paridad con `docs/logs/ultrareview-log.md` cloud y `docs/logs/revisar-main-log.md` hermano holístico.

### Antes de correr `/revisar` nuevamente sobre el mismo scope

Revisar § Cobertura antes de invocar el skill. Reglas:

- **Si el rango propuesto está 100% incluido en un run anterior** sin cambios desde · NO re-ejecutar (cero valor marginal).
- **Si el rango se solapa parcialmente** · preferir limitar el nuevo scope a los commits NO cubiertos.
- **Si es un área sensible** (auth · multi-tenancy · pagos · checkout · validación crítica del dominio) · re-revisión periódica está justificada incluso si ya fue revisada · documentar cadencia en § Política de re-revisión.

---

## Convenciones

### Identificadores

- **Local Run ID:** `LR-NNN` ascendente sin reset (LR-001 · LR-002 · ...). Independiente del namespace `UR-NNN` del cloud y del `RM-NNN` de `/revisar-main`.
- **Bug ID:** `lr_bug_NNN` por run (reset a 001 cada run). Si hay ambigüedad cross-run, prefijar con el Run ID (`LR-001/lr_bug_001`).

### Severidades

| Severidad | Significado | Acción esperada |
|---|---|---|
| `critical` | Falla de seguridad · pérdida de datos · RCE · exposición de secretos · invariante quebrada (auth · multi-tenancy · atomicity · payments según constraints del dominio declarados en [`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md)). | **Fix antes del merge** (prioridad 1). Bloquea el camino al paso 6 [`/entregar`](../../.claude/skills/entregar/SKILL.md). |
| `normal` | Bug funcional · regression latente · gap contra criterio del PRP · asimetría cross-módulo. | **Fix antes del merge** (prioridad 2). |
| `nit` | Inconsistencia menor · code smell · defense-in-depth gap · test que faltaba. | **Fix antes del merge** (prioridad 3) **solo si pasa el filtro Bif 6 = A** (≥2 detectores). |

> **Regla FIRME del proyecto** ([`always-fix-all-bugs.md`](../../.claude/rules/always-fix-all-bugs.md)): `critical`, `normal` y `nit` (que pasaron el filtro) se fixean SIEMPRE antes del merge a `main`, en orden de prioridad descendente, con estándar senior y regression-first FIRME (spec antes del fix · ver [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)).

### Marcado `verified` (proxy del "independent verification" del cloud)

- Bug detectado por **≥2 agentes** del run → `verified: true` en metadata.
- El cloud `/ultrareview` reproduce cada bug en VM fresh (verificación independiente real). El local logra señal equivalente vía overlap cross-agent · NO es idéntico pero reduce falsos positivos drásticamente.
- Si solo 1 agente lo detectó y la severidad es `nit` → DESCARTADO (Bif 6 = A · § 4 del consolidator).

### Estados de hallazgo

| Símbolo | Estado | Significado |
|---|---|---|
| 🔴 | `pendiente` | No abordado · sin owner ni PRP asignado. |
| 🟡 | `trackeado` | Incorporado a scope de un PRP/task futuro · linkear PRP. |
| 🟠 | `en progreso` | Fix en desarrollo activo · linkear branch o PRP. |
| 🟢 | `fixeado` | Resuelto · linkear commit SHA + run que verificó (si aplica). |
| ⚪ | `descartado` | Decisión consciente de no fixear · incluir motivo (1 frase). |
| 🟤 | `backlog` | Nit con ≥2 detectores que pasó filtro pero queda diferido (poco frecuente · regla FIRME prefiere fixear todo · usar solo con justificación explícita). |
| ⚫ | `obsoleto` | Quedó sin sentido por refactor / feature removida. |

### Tipos de scope

Cómo se invocó `/revisar`:

- `branch:<rama>` — diff entre rama y `main` (típico · default del skill).
- `pr:<número>` — PR de GitHub (`/revisar 123`).
- `range:<base-sha>..<head-sha>` — rango explícito de commits.

---

## Política de re-revisión

> **Tabla vacía al boot del template.** El adopter llena las filas conforme define áreas sensibles del producto que merecen re-revisión periódica (paridad regla [`pre-validation-inherited-regression.md`](../../.claude/rules/pre-validation-inherited-regression.md) · ejemplos típicos: pagos · auth · multi-tenancy · validación crítica del dominio).

| Área | Cadencia esperada | Justificación |
|---|---|---|
| _(agregar fila cuando el adopter defina área sensible · paridad ejemplos del docstring arriba)_ | — | — |

---

## Decisiones por PRP

> Una fila por PRP del producto que pasa por el paso 4 del flujo de 6 pasos. Default SÍ siempre en Modo C · si se decide NO, justificar en columna "Justificación".

| PRP | Fecha decisión | Decisión | Justificación (1 frase) | Run asociado |
|---|---|---|---|---|
| _(agregar fila al tomar la decisión SÍ/NO en paso 4 de cada PRP del producto)_ | — | — | — | — |

### Convenciones de la tabla

- **Decisión:** `SÍ` (camino CON `/revisar`) o `NO` (camino SIN). Default SÍ siempre en Modo C.
- **Justificación:** 1 frase. Si SÍ, qué área sensible disparó. Si NO, por qué se evaluó innecesario (ej: "PRP UI polish · sin BD/auth/dinero" · "área cubierta por LR-NNN sin cambios desde").
- **Run asociado:** LR-NNN si decisión = SÍ. Vacío o `—` si decisión = NO.

---

## Resumen de runs

> 1 fila por run de `/revisar` ejecutado.

| Run | Fecha | PRP | Scope | Base SHA | Head SHA | Archivos | LoC (+/−) | Bugs (C/N/Nit-bl) | Descartados (filtro Bif 6) | Costo est. | Duración | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| _(agregar fila al ejecutar primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — | — | — | — | — | — | — | — | — |

---

## Cobertura

### Por área del repo

> Mapa acumulado de qué áreas del repo YA pasaron por revisión local. El adopter define las filas según la estructura de su producto (típicamente paths bajo `src/` · `db/migrations/` · `tests/` · etc).

| Área | Último LR | Fecha | SHA cubierto | Notas |
|---|---|---|---|---|
| _(agregar fila al ejecutar primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — |

### Por PRP

| PRP | Último LR | SHA cubierto | Status |
|---|---|---|---|
| _(agregar fila al ejecutar primer run sobre un PRP)_ | — | — | — |

### Por rango de commits

| Rango cubierto | Run | Cobertura | Notas |
|---|---|---|---|
| _(agregar fila al ejecutar primer run · consolidator del skill la escribe automáticamente)_ | — | — | — |

---

## Hallazgos consolidados

> 1 fila por bug que pasó el filtro Bif 6 = A del consolidator (`critical` y `normal` siempre · `nit` solo con ≥2 detectores). Los descartados por filtro NO entran a esta tabla pero se contabilizan en § Resumen de runs columna "Descartados".

| Bug ID | Run | Severidad | Verified | Detectores | Archivo:línea | Resumen | Estado | Owner/PRP |
|---|---|---|---|---|---|---|---|---|
| _(agregar fila al ejecutar primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — | — | — | — | — |

---

## Calibración cross-reference (vs cloud)

> Cuando un mismo PRP del producto tiene tanto run local (`/revisar`) como run cloud (`/ultrareview`), comparar outputs acá para calibrar overlap detection vs independent verification.

| PRP | Local Run (LR-NNN) | Cloud Run (UR-NNN) | Hallazgos coincidentes | Hallazgos solo-local | Hallazgos solo-cloud | Notas |
|---|---|---|---|---|---|---|
| _(agregar fila cuando un PRP tenga ambos runs simultáneos)_ | — | — | — | — | — | — |

---

## Apéndice · entradas detalladas por run

> El consolidator del skill agrega sub-secciones `## LR-NNN · YYYY-MM-DD · PRP-NNN` al final del archivo conforme se ejecutan los runs (paridad shape upstream del pack · cada sub-sección incluye Cobertura de agentes + Filtrado Bif 6 + Hallazgos consolidados detalle por bug + Próxima acción recomendada).
>
> **Al boot del template no hay sub-secciones** · el primer run las inaugura.

---

*Log file inaugurado al boot del template · cero entradas reales hasta el primer run del skill `/revisar` en este proyecto. Shape canónico documentado en este header · cero refs proyecto-specific al boot.*