---
name: status-tracker-visible
description: Durante toda sesión Modo C, mantener visible un tracker del estado de los 6 pasos del flujo nuevo al inicio de cada respuesta principal hasta que la sesión cierre
type: rule
applies-to: sesiones del flujo Modo C (PRP + bucle agéntico) · cada respuesta principal hasta cierre del PRP
---

## Overview

> Durante toda sesión que entre en **Modo C** (PRP + bucle agéntico), el agente DEBE mantener visible un tracker del estado de los 6 pasos del flujo nuevo al inicio de cada respuesta principal hasta que la sesión cierre.

**Por qué esta regla existe:** el user NO consume la documentación operativa archivo por archivo. El tracker visible es el único feedback que recibe sobre dónde está el flujo en tiempo real. Sin tracker, queda a ciegas.

**Por qué los 6 pasos:** el flujo (Contexto · Planificación · Implementación · Revisión · Verificación · Entrega) cubre el ciclo end-to-end. Cada paso tiene su skill dedicado en `.claude/skills/` (`/arrancar` · `/planificar` · `/implementar` · `/revisar` · `/validar` · `/entregar`).

**Por qué el paso 6 (Entrega) es parte del flujo:** sin merge a `main`, el código del PRP queda en `dev` y NO llega a producción. Sin este paso oficial, los PRPs "cerrados" pero no entregados se acumulan silenciosamente.

## When

**Aplica a:**

- Sesiones que están ejecutando un PRP del producto vía Modo C.
- Cada respuesta principal del agente hasta que el PRP cierre con paso 6 ejecutado o quede explícitamente diferido con razón documentada.

**NO aplica a:**

- Modo A (tasks triviales sin fases).
- Modo B (skills cerrados con flujo propio).
- Conversaciones puramente exploratorias antes de arrancar el PRP.

## Process

**Formato canónico (los 6 pasos · copiá literal):**

```text
Flujo PRP-NNN:
[✓] 1. /arrancar (Contexto · carga del estado del proyecto + roadmap + modo A/B/C)
[✓] 2. /planificar PRP-NNN → APROBADO (6 preguntas PM hat + bifurcaciones cerradas con tag 🔵 user)
[ ] 3. /implementar (X/N fases · bucle agéntico + tests del DoD por fase + commit local)
[ ] 4. /revisar (multi-agent paralelo · 9 agentes Opus + consolidator con checklist 10 ítems)
[ ] 5. /validar (CSV creado · ejecutado · 100% verde · reporte · regression-first FIRME)
[ ] 6. /entregar (ci:local 6/6 → push único → DECISIÓN user (¿/ultrareview <PR#>?) → camino SIN/CON → CI remoto 1 vez garantizado → merge --squash a main)
```

**Reglas operativas:**

1. El tracker arranca en cada respuesta principal del agente, antes del trabajo de la respuesta.
2. Cada paso completado se marca `[✓]` con la nota relevante (ej: `4. /revisar · 9/9 agentes verde · consolidator OK`).
3. El paso en curso se marca `[ ]` con nota de progreso (ej: `3. /implementar (3/5 fases)`).
4. El tracker se actualiza al cierre de cada paso · el agente no espera al final de la sesión.
5. Cuando el paso 6 cierra (merge ejecutado o diferido con razón) → la sesión termina · tracker no se imprime más.

### SoT del bookkeeping del flujo (firma α upstream)

> **Decisión arquitectónica firmada 🔵 user upstream** sobre cuál SoT prevalece cuando hay 3 canales de bookkeeping del flujo simultáneos (tracker visible · TodoWrite · header del PRP). Sin esta firma, los 3 se desincronizan inevitablemente.

| Canal | Rol | Cuándo se actualiza |
|---|---|---|
| **Tracker visible** (este formato canónico) | **SoT operativo para el user** · única señal visual completa del estado del flujo de 6 pasos | Al inicio de cada respuesta principal · al cierre de cada paso completo (no fase intermedia) |
| **TodoWrite** | Tracking granular de **tasks dentro de una fase del paso 3** (subtareas de una fase del `/implementar`) · NO mapea las fases del flujo de 6 pasos | Durante el bucle del paso 3 · cero al boot del paso 1/2/4/5/6 si esos pasos son atómicos |
| **Header del PRP** (`> **Estado**:` + `> **Progreso del flujo de 6 pasos:**`) | **Snapshot al cierre del paso completo** · trazabilidad histórica del PRP en git | Al cierre del paso completo (paso 3 cerrado → header a `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)` · paso 6 cerrado post-merge → `COMPLETADO`) · NO al cierre de cada fase intermedia del paso 3 |

**Anti-pattern que esta sección atrapa (origen de un PRP upstream):**

- Mantener TodoWrite con 4 fases del paso 3 + tracker visible + header del PRP marcando fases → 3 SoTs del mismo estado · uno se desincroniza inevitablemente · system-reminders de TodoWrite generan ruido cuando se usa para fases largas que ya tienen tracker propio.

**Fix codificado:**

1. Tracker visible = SoT operativo (lo que el user ve y consume).
2. TodoWrite SOLO para tasks granulares dentro de una fase (ej: 5 subtareas técnicas de Fase 2 del `/implementar`) · NO para mapear las fases del paso 3 · esas viven en el tracker.
3. Header del PRP se toca al cierre del paso completo (paso 3 cerrado · NO Fase 1 cerrada · NO Fase 2 cerrada).

**Cómo aplicar al escribir un skill nuevo del flujo:** referenciar esta sección + usar tracker como SoT externo + TodoWrite solo si la fase tiene subtareas mecánicas trackeables. Cero duplicación del estado del flujo en 2+ canales.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es muy verboso, lo pongo solo cuando avanzo" | NO. El tracker es la única señal visual del estado del flujo para el user. Sin él, queda a ciegas y se pierde la oportunidad de course-corregir. La verbosidad es el feedback, no un costo. |
| "Esta respuesta es chica, no hace falta el tracker" | NO. La regla dice "al inicio de cada respuesta principal". Conversacional puro (sin trabajo de PRP) sí puede omitir; respuesta con cualquier acción del flujo, no. |
| "Imprimo el tracker viejo de 10 pasos por costumbre" | NO. El flujo canónico del pack tiene 6 pasos · el tracker es 6 ítems · cero excepción. Si encontrás referencias residuales a "paso 10/9/8/7/4" inline en CLAUDE.md u otros docs operativos, fixearlas in-line en el momento. |

## Red flags

- 🚩 Llevás 3+ respuestas en Modo C sin tracker.
- 🚩 El tracker no está actualizado (paso ya cerrado sigue `[ ]`).
- 🚩 El tracker imprime 10 ítems en lugar de los 6 canónicos del flujo nuevo (residuo del flujo viejo · fixear el momento de detectarlo).
- 🚩 La sesión arrancó en Modo C y la primera respuesta del agente no incluyó el tracker.

## Verification

- [ ] Cada respuesta principal de Modo C arranca con el bloque ` ```Flujo PRP-NNN: ... ``` ` con los 6 ítems canónicos.
- [ ] Cada paso cerrado está marcado `[✓]` con nota relevante.
- [ ] Cada paso pendiente está marcado `[ ]` con descripción.
- [ ] El tracker termina con el paso 6 (Entrega · merge a main o diferido con razón documentada).
- [ ] Si el PRP se difirió, el último tracker incluye la razón documentada.

**Cross-reference firme:**

- Hermana operativa: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (la sección § SoT del bookkeeping del flujo firmada α upstream codifica al tracker como SoT operativo para el user · TodoWrite SOLO para tasks granulares dentro de una fase · header del PRP para snapshot al cierre del paso completo).
- Hermana operativa: [`conversation-style.md`](./conversation-style.md) (tracker es feedback obligatorio en Modo C · paridad con brevedad por default en respuestas conversacionales · la verbosidad del tracker es el contrato).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (transparencia operativa hacia el user · estándar senior exige feedback visible del estado del flujo).
- Refuerza: [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) (al disparar aviso de fatiga · el tracker visible da contexto inmediato de en qué paso estamos y cuánto falta para estimar 🟢/🟡/🔴).
