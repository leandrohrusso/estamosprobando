# Revisar-Main Log

> Registro de ejecuciones de **[`/revisar-main`](../../.claude/skills/revisar-main/SKILL.md)** (multi-agent local code review **holístico** sobre el estado completo de `main` · 9 agentes Opus paralelos + consolidator) sobre el producto del adopter.
> **Propósito doble:**
> 1. **Bitácora de auditoría holística** — qué área del repo se auditó en cada fase del plan · cuándo · qué se encontró · qué se hizo con cada hallazgo.
> 2. **Mapa de cobertura acumulada** — qué áreas del repo YA pasaron por auditoría holística · para detectar áreas sistemáticamente sin revisar y planificar runs futuros.
>
> **Diferencia con [`docs/logs/revisar-log.md`](./revisar-log.md) (skill hermano `/revisar`):**
> - **`/revisar` (paso 4 del flujo del producto)**: 9 agentes auditan el **diff incremental** vs `main` del PRP en curso · contractual · default SÍ siempre en Modo C · scope acotado al cambio.
> - **`/revisar-main` (este log · lint mensual)**: 9 agentes auditan el estado **completo de `main`** · cero diff · scope holístico por familia técnica con planning automático en Paso 0.5 · cadencia mensual paridad lint memoria.
> - **Complementarios** · NO sustitutivos. `/revisar` atrapa bugs del cambio actual · `/revisar-main` atrapa drift estructural acumulado cross-PRP.

---

## Cómo se mantiene este archivo

### Cuándo se actualiza

- **Al cierre de cada fase de un run de `/revisar-main`** (paridad arquitectónica con `/revisar` consolidator): el consolidator escribe entrada nueva `RM-NNN.X` (X = número de fase del plan firmado en Paso 0.5) en § Resumen de runs + § Hallazgos consolidados + § Cobertura + § Métricas agregadas.
- **Al cierre de la última fase del plan firmado** (X = M): además de la entrada `RM-NNN.M` normal, el consolidator escribe entrada **adicional** `RM-NNN.0` reservada para reporte consolidado cross-fase (síntesis · DTs nuevas · áreas verde).
- **Al fixear** un hallazgo (`🔴 pendiente` → `🟢 fixeado`): actualizar estado en § Hallazgos consolidados con commit SHA + link al PRP nuevo del producto que cerró el bug.
- **Al descartar** un hallazgo conscientemente (`🔴 pendiente` → `⚪ descartado`): actualizar estado con motivo (1 frase).
- **Al cierre de un run completo** (todas las fases del plan firmado ejecutadas): marcar la fila correspondiente en § Decisiones por run con resultado final.
- **REGLA DE ORO docs y memoria** ([`golden-rule-docs-memory.md`](../../.claude/rules/golden-rule-docs-memory.md) ítem 4.7) aplica a este log con timing bidireccional · paridad con `docs/logs/revisar-log.md`.

### Antes de correr `/revisar-main` nuevamente sobre el mismo scope

Revisar § Cobertura antes de invocar el skill. Reglas:

- **Si el área del repo está cubierta por un run reciente** (≤30 días) sin cambios significativos en archivos del área · evaluar si vale re-ejecutar (cero valor marginal si nada drift-eó).
- **Si el rango se solapa parcialmente** · preferir limitar el nuevo scope en el Paso 0.5 a las familias técnicas NO cubiertas recientemente.
- **Cadencia mensual default** (paridad lint memoria · fila en [`docs/logs/deadlines.md`](./deadlines.md)) · cubre el ciclo natural de drift acumulado.

---

## Convenciones

### Identificadores

- **Run ID:** `RM-NNN` ascendente sin reset (RM-001 · RM-002 · ...). Independiente del namespace `LR-NNN` de `/revisar` y del `UR-NNN` del cloud.
- **Fase ID:** `RM-NNN.X` donde `X` = número de fase del plan firmado (1...M). Si modo simple, usar `RM-NNN.1`.
- **Reporte consolidado final:** `RM-NNN.0` reservado para síntesis cross-fase al cierre de la última fase del plan (X = M).
- **Bug ID:** `rm_bug_NNN` por run (reset a 001 cada run · NO reset por fase). Si hay ambigüedad cross-run, prefijar con el Run ID (`RM-001/rm_bug_001`).

### Severidades (paridad `/revisar`)

| Severidad | Significado | Acción esperada |
|---|---|---|
| `critical` | Falla de seguridad · pérdida de datos · RCE · exposición de secretos · invariante quebrada (auth · multi-tenancy · atomicity · payments según constraints del dominio declarados en [`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md)). | **Fix vía PRP nuevo del producto** (prioridad 1) · regla FIRME [`always-fix-all-bugs.md`](../../.claude/rules/always-fix-all-bugs.md). |
| `normal` | Bug funcional · regression latente · drift acumulado · asimetría cross-módulo. | **Fix vía PRP nuevo del producto** (prioridad 2). |
| `nit` | Inconsistencia menor · code smell · defense-in-depth gap · test que faltaba. | **Fix vía PRP nuevo del producto** (prioridad 3) **solo si pasa el filtro Bif 6 = A** (≥2 detectores). |

> **Regla FIRME del proyecto** ([`always-fix-all-bugs.md`](../../.claude/rules/always-fix-all-bugs.md)): `critical`, `normal` y `nit` (que pasaron el filtro) se fixean SIEMPRE con estándar senior y regression-first FIRME. Los fixes pueden distribuirse en PRPs nuevos del producto que consuman cada finding del log entry · el ciclo completo del lint mensual se cierra cuando todos los findings están en estado terminal.

### Marcado `verified` (proxy del "independent verification" del cloud)

- Bug detectado por **≥2 agentes** del run → `verified: true` en metadata.
- Si solo 1 agente lo detectó y la severidad es `nit` → DESCARTADO (Bif 6 = A · § 4 del consolidator).

### Estados de hallazgo (paridad `/revisar`)

| Símbolo | Estado | Significado |
|---|---|---|
| 🔴 | `pendiente` | No abordado · sin owner ni PRP nuevo asignado. |
| 🟡 | `trackeado` | Incorporado a scope de un PRP/task futuro · linkear PRP. |
| 🟠 | `en progreso` | Fix en desarrollo activo · linkear branch o PRP. |
| 🟢 | `fixeado` | Resuelto · linkear commit SHA + PRP que cerró el bug. |
| ⚪ | `descartado` | Decisión consciente de no fixear · incluir motivo (1 frase). |
| 🟤 | `backlog` | Nit con ≥2 detectores que pasó filtro pero queda diferido (poco frecuente). |
| ⚫ | `obsoleto` | Quedó sin sentido por refactor / feature removida. |

### Modos del Paso 0.5 (planning automático)

- **Modo simple:** 1 fase única · cardinalidad <umbral · 1 corrida holística de 9 agentes sobre el repo completo.
- **Modo por fases:** M fases · cardinalidad >umbral · agrupar agentes por afinidad técnica · cardinalidad variable según inventario del repo. Detalle del umbral y heurística de agrupación en [`.claude/skills/revisar-main/SKILL.md § Paso 0.5`](../../.claude/skills/revisar-main/SKILL.md).

---

## Política de re-revisión

> **Tabla base al boot del template** (cadencia mensual default paridad lint memoria). El adopter puede sumar filas para áreas sensibles del producto que merecen cadencia adicional (paridad ejemplos típicos: pagos · auth · multi-tenancy).

| Área | Cadencia esperada | Justificación |
|---|---|---|
| **Mensual completa** (todas las familias técnicas) | 1ro de cada mes | Drift acumulado cross-PRP detectable solo holísticamente · paridad operativa con lint memoria. |
| **Pre-release / hito mayor** | Ad-hoc | Baseline holístico antes de release significativo. |
| **Sospecha de drift** (user lo invoca explícitamente) | Ad-hoc | Cuando hay indicios concretos de bugs estructurales no detectados. |
| **Docs / memoria / PRPs / gobierno** | Nunca | No es código ejecutable · cubierto por `bash scripts/lint-memory.sh` para memoria + `/auditar-dt` para DTs. |
| _(agregar fila cuando el adopter defina área sensible adicional)_ | — | — |

---

## Decisiones por run

> Una fila por run completo del lint mensual (o ad-hoc) · paridad con § "Decisiones por PRP" de `/revisar` adaptada al modo holístico.

| Run | Fecha | Modo | Plan firmado (cardinalidad) | Fases ejecutadas | Resultado final |
|---|---|---|---|---|---|
| _(agregar fila al cierre del primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — | — |

### Convenciones de la tabla

- **Modo:** `simple` (1 fase) o `por fases` (M fases).
- **Plan firmado:** breve descripción del plan firmado 🔵 user en Paso 0.5 (familias técnicas asignadas + cardinalidad).
- **Fases ejecutadas:** X/M (cuántas se cerraron · si <M, indicar si fue por handoff a sesión nueva o cancelación).
- **Resultado final:** counts agregados de findings cross-fase + estado (cuántos `fixeados` · `pendientes` · `descartados`).

---

## Resumen de runs

> 1 fila por fase del plan firmado (`RM-NNN.X`) · más fila final `RM-NNN.0` con reporte consolidado cuando el run termina.

| Run.Fase | Fecha | Familia técnica auditada | Archivos cubiertos | Bugs (C/N/Nit-bl) | Descartados (filtro Bif 6) | Costo est. | Duración | Status |
|---|---|---|---|---|---|---|---|---|
| _(agregar fila al cierre de cada fase del primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — | — | — | — | — |

---

## Cobertura

### Por familia técnica del repo

> El adopter define las familias técnicas según la estructura de su producto. Ejemplos típicos: RPCs+atomicity · RLS+multi-tenant+audit · render+correctness · UI+routing+i18n+tests · etc. Adaptar a las capas reales del stack del adopter.

| Familia técnica | Último run | Fecha | Notas |
|---|---|---|---|
| _(agregar fila al cierre del primer run · consolidator del skill la escribe automáticamente según familias firmadas 🔵 user en Paso 0.5)_ | — | — | — |

### Por run

| Run | SHA cubierto | Modo | Status |
|---|---|---|---|
| _(agregar fila al cierre del primer run)_ | — | — | — |

---

## Hallazgos consolidados

> 1 fila por bug que pasó el filtro Bif 6 = A del consolidator (`critical` y `normal` siempre · `nit` solo con ≥2 detectores). Los descartados por filtro NO entran a esta tabla pero se contabilizan en § Resumen de runs columna "Descartados".

| Bug ID | Run.Fase | Severidad | Verified | Detectores | Archivo:línea | Resumen | Estado | Owner/PRP |
|---|---|---|---|---|---|---|---|---|
| _(agregar fila al cierre de cada fase del primer run · consolidator del skill la escribe automáticamente)_ | — | — | — | — | — | — | — | — |

---

## Apéndice · entradas detalladas por run / fase

> El consolidator del skill agrega sub-secciones `## RM-NNN.X · YYYY-MM-DD · <familia técnica>` al final del archivo conforme se ejecutan las fases del plan firmado (paridad shape upstream del pack · cada sub-sección incluye Cobertura de agentes + Filtrado Bif 6 + Hallazgos consolidados detalle por bug + Próxima acción recomendada). La última fase del run (X = M) dispara entrada adicional `RM-NNN.0` con reporte consolidado cross-fase.
>
> **Al boot del template no hay sub-secciones** · la primera fase del primer run las inaugura.

---

*Log file inaugurado al boot del template · cero entradas reales hasta el primer run del skill `/revisar-main` en este proyecto. Shape canónico documentado en este header · cero refs proyecto-specific al boot.*
