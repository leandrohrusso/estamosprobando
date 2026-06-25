# `.claude/skills/revisar-main/` · Skill `/revisar-main` · auditoría holística del estado completo de `main`

> **Qué es:** skill invocable que materializa la auditoría holística del estado completo de `main` (no diff vs main). Carpeta contiene `SKILL.md` parseable por el harness Claude Code + 9 agentes Opus adaptados al modo holístico + consolidator general-purpose. Paridad arquitectónica con `/revisar` (skill hermano · paso 4 del flujo del producto sobre diff vs main · contractual).
>
> **Por qué se creó:** PRP-NNN · firma 🔵 user upstream sobre 6 bifurcaciones + N SD-cos + 3 SKIPs. Cierra el gap detectado upstream: hay bugs estructurales históricos (asimetrías cross-PRP · invariantes acumulativos · render snapshot mal aplicado · audit gaps) que ningún diff de PRP individual atrapó y que `/revisar` no puede detectar porque audita por diff. `/revisar-main` cierra esa red de seguridad como lint mensual de código · paridad operativa con `scripts/lint-memory.sh` (lint mensual de memoria · DT-NNN).
>
> **Para qué sirve:** invocar `/revisar-main` en cadencia mensual (fila en `docs/logs/deadlines.md` · `/arrancar` avisa al boot) o ad-hoc cuando se sospecha drift acumulado. **Novedad arquitectónica:** Paso 0.5 planning automático del scope decide modo simple (1 pasada · cuando repo entra) vs modo por fases (M pasadas según inventario · con handoff automático entre fases vía regla #26 [`session-handoff.md`](../../rules/session-handoff.md)). Atrapa proactivamente bugs estructurales que ningún PRP individual vio (paridad arquitectónica con UR-NNN retro que detectó asimetrías cross-módulo después de varios PRPs).

---

## Convención

- **Naming:** kebab-case en inglés · `<archivo>.md` paridad estricta con `/revisar` (`SKILL.md` · `consolidator.md` · `agents/<nombre>.md`).
- **Shape P8 obligatorio para `SKILL.md`:** 6 H2 (Overview · When · Process · Anti-rationalization · Red flags · Verification) + frontmatter `name + description + allowed-tools` (paridad estricta con los 6 skills del flujo).
- **Frontmatter `allowed-tools`:** `Read, Write, Edit, Grep, Glob, Bash, Task` (paridad `/revisar` · `Task` necesario para spawneear los 9 agentes en paralelo + consolidator).
- **Agentes Opus** en `agents/<nombre>.md` (9 archivos · 1 por familia técnica · copia adaptada de `/revisar/agents/*` con § Role + § Input + § Output modificados al modo holístico · Bif N = A 🔵 user upstream).
- **Consolidator general-purpose** en `consolidator.md` (1 archivo · copia adaptada de `/revisar/consolidator.md` con IDs `RM-NNN.X` por fase + escribir en `docs/logs/revisar-main-log.md` · paridad SD-cos-N).
- **Cero coupling con `/revisar` actual** (contractual paso 4 del flujo del producto · Bif N = A) · cualquier mejora del modo holístico vive SOLO acá.
- **Cero auditoría sobre gobierno/skills/memoria/docs** (los 9 agentes calibrados son para código de producto · refactor histórico cerrado PRP-NNN NO se audita).

---

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`agents/`](./agents/) | 9 agentes Opus adaptados al modo holístico (architect · security · multi-tenant · atomicity · tests · correctness · a11y · i18n · migration-safety) · 1 archivo por familia técnica · paridad estructural con `/revisar/agents/` |

---

## Archivos actuales

| Archivo | Rol |
|---|---|
| `SKILL.md` | Skill entry point · shape P8 + frontmatter · 6 pasos del Process (Paso 0 pre-condiciones · Paso 0.5 planning automático · Paso 1 preflight · Paso 2 spawn 9 agentes · Paso 3 recolección · Paso 4 consolidator · Paso 5 reporte ejecutivo + handoff automático si quedan fases) |
| `consolidator.md` | Consolidator `general-purpose` · 7 tareas en orden (parse → dedupe → re-clasificar → filtrar señal débil → IDs `RM-NNN.X` → priorizar+escribir log → output ejecutivo) · escribe en `docs/logs/revisar-main-log.md` |
| `agents/<nombre>.md` | 9 agentes Opus paralelos · scope acotado por familia técnica de la fase · output bloque markdown shape SD-cos-N |

---

## Carpetas hermanas

- [`../revisar/`](../revisar/) — skill hermano · paso 4 del flujo del producto sobre diff vs main · contractual · `/revisar-main` reusa shape estructural + 9 agentes (copia adaptada · Bif N = A) pero scope holístico.
- [`../implementar/`](../implementar/) · [`../planificar/`](../planificar/) · [`../arrancar/`](../arrancar/) · [`../validar/`](../validar/) · [`../entregar/`](../entregar/) — 6 skills del flujo del producto · paridad estructural P8 + frontmatter · `/revisar-main` NO es paso del flujo (es lint mensual hermano).
- [`../fatiga/`](../fatiga/) · [`../handoff/`](../handoff/) — skills auxiliares · `/revisar-main` invoca `/fatiga` opcional pre-Paso 0.5 (regla #9) e invoca regla #26 vía `/handoff` automático entre fases (Bif N = A).
- [`../../rules/`](../../rules/) — satélites de reglas firmes · `/revisar-main` cita inline 6 reglas en su § Process (folder-creation-with-readme · session-handoff · surgical-changes · simplicity-first · quality-standard-senior · always-fix-all-bugs).
- [`../../../docs/logs/`](../../../docs/logs/) — `/revisar-main` escribe entradas en `revisar-main-log.md` (nuevo · paridad `revisar-log.md`) y consume `deadlines.md` para cadencia mensual.

---

## Cómo invocar el skill

1. **Cadencia mensual:** `/arrancar` lee `docs/logs/deadlines.md` al boot · avisa cuando se acerca (≤7 días) o vence el disparador mensual de `/revisar-main` · user invoca el skill.
2. **Ad-hoc por sospecha de drift:** user dice *"revisar main"* · *"auditoría holística"* · *"lint mensual de código"* · *"drift acumulado"* · *"asimetrías cross-PRP"* · etc (triggers AR/LATAM-friendly · ver frontmatter `description` del `SKILL.md`).
3. **Pre-release / hito:** antes de un milestone mayor corre `/revisar-main` para baseline holístico.

El skill ejecuta los 6 pasos canónicos del Process (Paso 0 + Paso 0.5 + Paso 1-5) · pide firma 🔵 user al cierre del Paso 0.5 con el plan del scope · gasta tokens solo después de firma · invoca handoff automático entre fases si modo por fases con pendientes.

---

## Cómo agregar un agente nuevo (caso futuro)

Solo aplica si se justifica una familia técnica nueva NO cubierta por los 9 agentes actuales. Proceso:

1. **Validar duplicado:** confirmar que ningún agente existente cubre el foco propuesto (regla #22 [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) Paso 1).
2. **Firma user explícita** con justificación 1-frase (regla #6 [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md)).
3. **Crear `agents/<nombre>.md`** con shape paralelo a los 9 existentes (§ Role · § Input · § Output · § Verification checklist).
4. **Wirear el agente nuevo en `SKILL.md § Paso 2`** (tabla canónica de 9 → 10 agentes).
5. **Wirear el agente nuevo en `consolidator.md § Procedure`** (parse del bloque `## Agent: <nuevo>`).
6. **Commit local** con mensaje `feat(/revisar-main): agente nuevo <nombre> · <justificación 1-frase>`.

---

*Convención de README firmada upstream (regla [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md)) · skill creado vía PRP-NNN.*
