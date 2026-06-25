---
name: golden-rule-docs-memory
description: Documentación y memoria son INDISPENSABLES de cada task · checklist obligatorio antes de marcar done · cero diferimiento
type: rule
applies-to: cierre de cualquier task / fase / PRP en Modo A, B, o C
---

## Overview

> **La documentación y la memoria son parte INDISPENSABLE de cada task.** Cerrar/commitear una task sin documentarla NO es cerrarla — es deuda técnica y de contexto que se paga después con re-trabajo y errores que se repiten.

**Por qué esta regla existe:** sin documentación, los aprendizajes mueren con la sesión. La próxima sesión entra sin memoria del bug cerrado ayer · repite el mismo anti-pattern · y 3 meses después redescubre que la solución ya existía pero se perdió. La memoria persistente es el único canal donde el conocimiento sobrevive a la sesión y viaja con el repo. La regla "antes de marcar done" garantiza que el cierre incluya el aprendizaje · no solo el código.

## When

**Trigger del checklist:** cuando aparezca "esto está listo, ¿commit?" / "cierro la task" / "pasamos a la siguiente" / equivalente. Antes de cualquier "yes" a esas frases, ejecutar el checklist completo. Si algún punto está incompleto, NO cerrar — completarlo primero.

**Aplica a:**

- Cierre de tasks individuales del roadmap.
- Cierre de fases del bucle agéntico (paso 3 del Modo C).
- Cierre de PRPs completos (paso 4 + paso 5 del Modo C).
- Cierre de fixes ad-hoc en Modo A/B.

## Process

**Checklist obligatorio antes de marcar cualquier task / fase / PRP como `done`:**

1. **Roadmap** ([`docs/product/product-roadmap.md`](../../docs/product/product-roadmap.md)): entrada de la task pasa de `[ ]` a `[x]` con notas de qué se hizo, archivos creados/modificados, decisiones tomadas y aprendizajes específicos.
2. **PRP** (si aplica): criterios de éxito marcados; sección "Aprendizajes / Self-Annealing" con cualquier gotcha encontrado.
3. **JSDoc / comentarios**: helpers nuevos llevan header explicando qué hacen, por qué existen y cuándo usarlos.
4. **Memoria persistente** ([`.claude/memory/`](../memory/)):
   - `feedback/` — patrones que afectan código futuro (anti-patterns, gotchas universales).
   - `reference/` — punteros a recursos para que futuras sesiones los reusen.
   - `project/` — decisiones arquitectónicas o estado activo.
   - **`MEMORY.md` (index) actualizado** con cada entry nueva.
4.5. **CSV de validación** (si el PRP entregó código): `tests/manual/PRP-NNN_*.csv` existe, está 100% verde (`Funciona` o `Diferido` justificado en todas las filas), y el reporte final del paso 5 está archivado. Sin esto, el PRP no está cerrado.
4.6. **Deuda técnica** ([`docs/logs/technical-debt.md`](../../docs/logs/technical-debt.md)) — VERIFICACIÓN, no creación:
   - (a) Toda deuda nueva detectada durante la sesión tiene su fila en `docs/logs/technical-debt.md` (la fila se crea **inmediatamente** al documentar la deuda en `feedback/` u otro canal, NO al cierre). **Proceso completo del "inmediatamente" para bugs/hallazgos out-of-scope: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (definición canónica · 4 pasos · 8 campos contractuales).**
   - (b) Toda deuda cerrada durante la sesión está marcada como `✅ Resuelta` con el commit hash (la marca se hace **en el mismo commit** que cierra la deuda, NO al cierre de sesión).
   - Si A o B fallaron en su momento inmediato, este checklist los atrapa: completar lo que falte ahora.
4.7. **Ultrareview log** ([`docs/logs/ultrareview-log.md`](../../docs/logs/ultrareview-log.md)) — timing bidireccional:
   - (a0) En sub-paso 6.◆, AL TOMARSE la decisión SÍ o NO: agregar fila en § Decisiones por PRP.
   - (a) Al lanzar `/ultrareview` (camino CON): agregar entrada `UR-NNN` con `status: en curso`.
   - (b) Al recibir `<task-notification>` de completado: completar entrada con hallazgos por severidad + estado `🔴 pendiente` por bug.
   - (c) Al fixear / descartar un hallazgo: actualizar estado en § Hallazgos consolidados con commit SHA.
   - Verificación al cierre: si A0/A/B/C fallaron, completar acá.
5. **Archivos canónicos**: si afecta el resumen ejecutivo o identidad del proyecto, actualizar `BUSINESS_LOGIC.md`, `CLAUDE.md`, etc.
6. **Commit local** con resumen del cambio + aprendizajes en el mensaje. **Push a `origin/dev` solo en paso 6** del flujo Modo C (1 push por PRP).

### Mapping paso del flujo → ítems aplicables del checklist

> **Crítico:** los 6 ítems del checklist NO aplican uniformemente a cada paso del flujo de 6 pasos. Algunos ítems se cumplen en pasos posteriores · al cierre de cada paso solo se verifica lo que aplica en ese momento. Mezclar pasos genera el anti-pattern PRP-NNN (cierre prematuro · ítem 4 CSV creado en paso 3 cuando pertenece a paso 5).

| Paso del flujo | Skill | Ítems del checklist aplicables | Ítems pendientes |
|---|---|---|---|
| **3** | `/implementar` | 1 (roadmap) · 2 (PRP criterios + Aprendizajes) · 3 (JSDoc) · 4 (memoria) · 4.6 (DT bidireccional) · 5 (canónicos) · 6 (commit) | **4.5 (CSV)** pendiente del paso 5 · **4.7 (Ultrareview log)** pendiente del paso 6 sub-paso 6.◆ |
| **4** | `/revisar` | Verificación de ítems del paso 3 + correcciones identificadas por el multi-agent review | 4.5 (CSV) sigue pendiente del paso 5 · 4.7 sigue pendiente del paso 6 |
| **5** | `/validar` | **4.5 (CSV)** se cumple acá (DUEÑO ÚNICO · crea + ejecuta + 100% verde) · 1 (roadmap actualizado si CSV detectó algo) · 4 (memoria nueva por bugs detectados) · 4.6 (DT nueva por gaps detectados) · 6 (commit) | 4.7 (Ultrareview log) sigue pendiente del paso 6 |
| **6** | `/entregar` | **4.7 (Ultrareview log)** se cumple acá (sub-paso 6.◆ · decisión SÍ/NO · si SÍ entrada UR-NNN) · ci:local 6/6 verde + push único + merge `--squash` a main · **header del PRP pasa a `COMPLETADO`** (post-merge a `main`) | Todos cumplidos al cierre del paso 6 |

**Estado del header del PRP por paso del flujo** (paridad simétrica con ownership del CSV · evita cierre prematuro detectado en PRP-NNN):

| Paso cerrado | Estado canónico del header |
|---|---|
| Paso 2 (`/planificar`) | `APROBADO` (4 bifurcaciones firmadas 🔵 user · listo para implementar) |
| Paso 3 (`/implementar`) | `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)` |
| Paso 4 (`/revisar`) | `EN PROGRESO (paso 4 cerrado · 5 + 6 pendientes)` |
| Paso 5 (`/validar`) | `EN PROGRESO (paso 5 cerrado · 6 pendiente)` |
| Paso 6 (`/entregar`) | `COMPLETADO` (post-merge a `main` · O `DIFERIDO con razón documentada` si quedó bloqueado) |

**Anti-pattern crítico evitado por este mapping:** el agente al cierre del paso 3 puede leer *"REGLA DE ORO 6 ítems"* y asumir que TODOS los 6 ítems se cumplen acá · crear CSV prematuro con filas "Funciona" auto-asignadas pisa el rol de `/validar` paso 5. **Vector hermano** también posible: el mismo cierre marca el header del PRP como `COMPLETADO` cuando faltan pasos 4 + 5 + 6. El mapping por paso de la tabla anterior atrapa ambos. Cuando tu proyecto detecte este caso, codificarlo como memoria en `.claude/memory/feedback/csv-is-validar-not-implementar.md` (vacío al boot del pack).

**Cuándo se actualiza el header del PRP** (firma α): SOLO al cierre del paso completo · NO al cierre de cada fase intermedia del paso 3. Las fases del bucle agéntico viven en el **tracker visible** (regla #25 [`status-tracker-visible.md`](./status-tracker-visible.md) § SoT del bookkeeping del flujo) que es SoT operativo para el user · el header del PRP es snapshot histórico al cierre del paso completo.

### Qué SÍ se modifica / crea para documentar

Documentar siempre se hace dentro de estos canales del proyecto, sin tocar infraestructura compartida:

- **Memoria persistente** (`.claude/memory/`): editar entries existentes O crear archivos nuevos en `feedback/` / `reference/` / `project/`. Actualizar `MEMORY.md` (index).
- **Registro de deuda técnica** (`docs/logs/technical-debt.md`) — apertura inmediata + cierre inmediato + verificación al cierre.
- **Ultrareview log** (`docs/logs/ultrareview-log.md`) — decisión inmediata + apertura + cierre + estado de hallazgo + verificación al cierre.
- **PRPs** (`.claude/PRPs/`): actualizar criterios de éxito + sección "Aprendizajes / Self-Annealing".
- **Roadmap** (`docs/product/product-roadmap.md`): notas inline en cada task, marcando `[x]` cuando se cierra.
- **JSDoc / comentarios en código**: headers, convenciones inline, decisiones que vivan al lado del código que las aplica.
- **Archivos canónicos del repo** (`BUSINESS_LOGIC.md`, `CLAUDE.md`, `WORKFLOW.md`, `docs/`): solo si el cambio afecta identidad / estado / decisiones globales del proyecto.

### Qué NUNCA se modifica para documentar (PROHIBIDO)

**Los archivos de estructura del agente NO se tocan jamás para documentar aprendizajes del proyecto.** Son infraestructura compartida y reusable across projects.

- ❌ `.claude/skills/**/SKILL.md` y cualquier archivo dentro de un skill.
- ❌ Configuración del harness (`settings.json`, hooks, plugins, agents).
- ❌ Tools / MCPs registrados.
- ❌ Cualquier archivo bajo `.claude/` que defina **cómo trabaja el agente**, no **qué construye este proyecto**.

Si un aprendizaje parece "tan importante que debería estar en el skill", la respuesta correcta es:

1. Capturarlo en `.claude/memory/feedback/` (o `reference/`).
2. Si afecta TODO el proyecto, sumarlo a la sección el proyecto de `CLAUDE.md` (no al skill).
3. Si tiene que ser inevitable durante un flujo específico, agregar el recordatorio al **PRP** del flujo, no al skill que ejecuta el flujo.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El commit es chico, no hace falta actualizar memoria" | NO. La memoria es donde el aprendizaje sobrevive a la sesión. Sin esa fila, en 3 meses el agente repite el bug porque "no se acordaba". Costo de la fila: 30 segundos. Costo de no tenerla: re-debuggear el mismo problema. |
| "Lo documento en la sesión que viene cuando tenga más tiempo" | NO. La sesión que viene NO va a tener más tiempo. Y el contexto exacto del aprendizaje se va a haber perdido. La doc se escribe AHORA, mientras el contexto está fresco. |

## Red flags

- 🚩 Vas a marcar una task como `[x]` sin haber actualizado roadmap con notas de qué se hizo.
- 🚩 Encontraste un anti-pattern y NO está en `.claude/memory/feedback/` ni MEMORY.md.
- 🚩 Cerraste una DT en el commit pero `docs/logs/technical-debt.md` NO está actualizado.
- 🚩 Lanzaste `/ultrareview` y `docs/logs/ultrareview-log.md` NO tiene la entrada UR-NNN.
- 🚩 Estás por commitear con mensaje "fix bug" sin aprendizaje en el mensaje del commit.

## Verification

- [ ] Roadmap actualizado con `[x]` + notas + archivos creados/modificados.
- [ ] PRP con criterios marcados + sección Aprendizajes con gotchas.
- [ ] Memoria persistente actualizada (feedback / reference / project según corresponda) + MEMORY.md sub-secciones.
- [ ] Si CSV: 100% verde + reporte archivado.
- [ ] Si DT abierta o cerrada: `docs/logs/technical-debt.md` refleja el estado con commit hash.
- [ ] Si `/ultrareview` corrió: `docs/logs/ultrareview-log.md` tiene la entrada con hallazgos + estado por bug.
- [ ] Commit local con resumen + aprendizajes en mensaje (no solo "fix").

**Cross-reference firme:**

- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (ítem 4.6.a · timing inmediato bidireccional · 8 campos contractuales · fuente canónica del "inmediatamente" que esta regla verifica al cierre).
- Hermana operativa: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (ítem 4.5 CSV se cumple en paso 5 con tests del DoD acumulativos).
- Hermana operativa: [`log-chronology-append-only.md`](./log-chronology-append-only.md) (ítem 6 commit local + cronología `log.md` append-only · 6 tipos `<op>`).
- Hermana operativa: [`lint-memory-periodic.md`](./lint-memory-periodic.md) (auditoría periódica de la memoria que esta regla mantiene viva al cierre · 6 criterios · cadencia mensual).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye documentar aprendizajes · cero atajos).

> **Stack de documentación · 3 reglas paralelas del ciclo doc/memoria.** Esta regla forma el bloque "documentación y memoria" junto a [`lint-memory-periodic.md`](./lint-memory-periodic.md) y [`log-chronology-append-only.md`](./log-chronology-append-only.md). Roles complementarios sin solapamiento: (1) **golden-rule (esta)** = CUÁNDO documentar · sincrónica al cierre de task/fase/PRP · checklist 6 ítems obligatorios bloqueante de cierre. (2) **lint-memory** = AUDITAR memoria periódicamente · asincrónica cadencia mensual · read-only · user decide qué fixear. (3) **log-chronology** = FORMATO canónico de la cronología · contractual append-only · 6 tipos de evento · cero modificación retroactiva. Las 3 severidades divergen legítimamente (bloqueante · preventiva · de integridad) porque protegen distintas capas del mismo stack: golden-rule protege la documentación operativa en tiempo real · lint atrapa drift acumulado · log preserva la cronología histórica.

- Skill operativo bajo demanda: [`/documentar`](../skills/documentar/SKILL.md) (trigger explícito que re-lee esta regla como SoT contractual · auto-detecta paso del flujo en curso · aplica fixes mecánicos del checklist en el acto + presenta estructurales al user antes de escribir · paridad arquitectónica con [`/fatiga`](../skills/fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) y [`/handoff`](../skills/handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](./session-handoff.md)).
