---
name: documentar
type: skill
description: "Aplicar bajo demanda la REGLA DE ORO docs y memoria (regla firme #18 golden-rule-docs-memory.md) como SoT contractual · re-lee la regla · auto-detecta paso del flujo en curso · mapea estado actual vs checklist 6 ítems · aplica fixes mecánicos en el acto + presenta estructurales al user antes de escribir · reporta qué aplicó y qué quedó pendiente. Activar cuando el usuario dice: documentar, documentá, documenta, regla de oro, REGLA DE ORO, REGLA DE ORO cierre, regla oro, cerrá el paso, cerra el paso, cerrar prolijo, checkeá la regla de oro, checkea la regla de oro, checklist de cierre, checklist cierre, checklist 6 ítems, checklist 6 items, aplicá el cierre, aplica el cierre, documentá el cierre, documenta el cierre, marcá done, marca done, verificá el checklist, verifica el checklist, cierre de paso, cierre del paso, cierre paso, auditá el checklist, audita el checklist."
allowed-tools: Read, Edit, Write, Bash
---

# Skill: `/documentar` — aplicar REGLA DE ORO docs y memoria bajo demanda

> **Skill custom autocontenido.** Trigger explícito que el user invoca para aplicar manualmente el checklist de 6 ítems de la REGLA DE ORO · complementa la regla firme #18 (la regla codifica el checklist + el mapping paso del flujo → ítems aplicables · el skill ejecuta su aplicación bajo demanda).
>
> **Relación con la regla #18:** la regla [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) es **SoT contractual** del checklist (6 ítems: 1 roadmap · 2 PRP · 3 JSDoc · 4 memoria · 4.5 CSV · 4.6 DT · 4.7 ultrareview · 5 canónicos · 6 commit) + § Mapping paso del flujo → ítems aplicables + § Qué SÍ se modifica / NUNCA se modifica para documentar. Este skill **NO duplica** el checklist · solo lo invoca y lo aplica. Si mañana cambia la regla, el skill refleja el cambio automáticamente (Process Paso 1 obliga re-lectura · cero cache). Paridad arquitectónica bidireccional completa con [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) y [`/handoff`](../handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](../../rules/session-handoff.md) · trío canónico cerrado (refinamiento iterativo upstream · cada predecesor cita a este skill como cierre del shape "trigger explícito · re-lectura obligatoria de SoT · cero cache").

## Overview

> **Propósito:** trigger explícito para aplicar la REGLA DE ORO docs y memoria bajo demanda del user · invoca la regla firme #18 como SoT contractual · auto-detecta paso del flujo en curso · mapea estado actual vs checklist · aplica fixes mecánicos en el acto + presenta estructurales al user antes de escribir · reporta al cierre qué aplicó y qué quedó pendiente.

**Qué NO hace:**

- ❌ NO sustituye a la regla firme #18 — esa sigue siendo SoT contractual del checklist · el skill solo lo invoca y lo aplica bajo demanda.
- ❌ NO modifica archivos PROHIBIDOS por la regla #18 § "Qué NUNCA se modifica" (`.claude/skills/**/SKILL.md` · configuración del harness · hooks · MCPs · agents · cualquier archivo bajo `.claude/` que defina cómo trabaja el agente).
- ❌ NO commitea automáticamente — los cambios quedan en working tree para que el user revise + commitee (paridad regla #27 [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) "1 push por PRP en paso 6" · skill NO empuja).
- ❌ NO escribe contenido estructural sin firma explícita del user (sección Aprendizajes del PRP · texto de memoria nueva · severidad de DT · cambios en archivos canónicos).
- ❌ NO ejecuta sub-pasos posteriores del flujo (no corre `/revisar` ni `/validar` ni `/entregar`) — solo aplica el checklist de la regla #18.

## When

| Caso | Aplica `/documentar` |
|---|---|
| User dice *"/documentar"* · *"REGLA DE ORO"* · *"cerrá el paso"* · *"checklist 6 ítems"* · *"aplicá el cierre"* · *"documentá el cierre"* · *"checkeá la regla de oro"* · *"marcá done"* · *"auditá el checklist"* | ✅ SÍ |
| Cierre del paso 3 (`/implementar`) post-fase final · antes del commit local | ✅ SÍ (subset de ítems que aplican al paso 3 · ver § Mapping de la regla #18) |
| Cierre del paso 5 (`/validar`) post-CSV 100% verde | ✅ SÍ (ítem 4.5 CSV + memorias nuevas por bugs detectados + DT abierta/cerrada en sesión) |
| Cierre del paso 6 (`/entregar`) post-merge a `main` · header del PRP `EN PROGRESO` → `COMPLETADO` + entry `prp-close` en `log.md` | ✅ SÍ (todos los ítems pendientes consolidados) |
| Cierre ad-hoc de Modo A · trabajo trivial cerrado · sumar entry rápida a `log.md` o memoria si aplica | ✅ SÍ (subset reducido del checklist) |
| Sesión exploratoria sin scope cerrado · cero trabajo concreto que documentar | ❌ NO (no hay sustancia para aplicar el checklist) |
| User pide modificar archivos PROHIBIDOS por la regla #18 (skills · settings · hooks · agents) | ❌ NO (regla #18 § "Qué NUNCA se modifica" es contractual · skill respeta el veto incluso si el user lo pide) |
| User pide commitear post-aplicación dentro del skill | ❌ NO directamente (skill reporta · user commitea · paridad regla #27) |

## Process

> **Skill autocontenido.** El § Process embebe los 4 pasos canónicos · cero detección runtime · ejecución mecánica.
> **Cita inline de doctrina:** el checklist de 6 ítems · el mapping paso del flujo → ítems aplicables · y qué SÍ/NUNCA se modifica viven en [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (SoT contractual). Este skill **referencia** la regla y **ejecuta** su aplicación bajo demanda.

### Paso 1 · Cargar regla #18 como SoT (obligatorio · cero cache)

`Read .claude/rules/golden-rule-docs-memory.md` cada invocación.

**Por qué obligatorio:** la regla es SoT contractual · puede haber cambiado entre invocaciones (refinamientos del checklist · ajustes del mapping · nuevos ítems). Re-leer cuesta segundos · evita drift entre skill y regla. Cero cache de invocaciones previas.

**Qué cargar de la regla:**

- Los 6 ítems del checklist (1 · 2 · 3 · 4 · 4.5 · 4.6 · 4.7 · 5 · 6).
- § Mapping paso del flujo → ítems aplicables del checklist (qué subset aplica en paso 3 vs 4 vs 5 vs 6).
- § Estado del header del PRP por paso del flujo (paridad simétrica con ownership del CSV · anti-pattern PRP-NNN).
- § Qué SÍ se modifica / Qué NUNCA se modifica para documentar.

### Paso 2 · Auto-detectar paso del flujo en curso

Mapear estado de la sesión para saber qué subset de los 6 ítems aplica:

- **PRP activo:** `ls .claude/PRPs/PRP-*.md` + leer header `> **Estado**:` de cada uno · identificar el que está en `EN PROGRESO` o `APROBADO`.
- **Paso del flujo en curso:** inferir del estado del PRP + último commit + tracker visible de la sesión actual + git log reciente.
- **Subset de ítems aplicables:** cruzar con § Mapping de la regla #18.
- **Modo:** Modo A trivial · Modo B skill cerrado · Modo C PRP (el subset cambia · ver regla).

Reportar inferencia al user en 1-2 líneas antes de continuar: *"Detecté PRP-NNN en paso X · aplicaré subset Y del checklist."* Si la inferencia es ambigua (2+ PRPs activos · paso del flujo no claro · sesión mixta), preguntar al user con A/B antes de seguir (paridad regla #6 [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md)).

### Paso 3 · Mapear estado actual vs checklist · separar mecánicos vs estructurales

Para cada ítem aplicable del subset · evaluar estado actual con tooling read-only:

- **Ítem 1 (roadmap):** grep tasks del PRP en [`docs/product/product-roadmap.md`](../../../docs/product/product-roadmap.md) · ¿están marcadas `[x]` con notas? · ¿faltan tasks?
- **Ítem 2 (PRP):** Read header del PRP · ¿criterios marcados? · ¿sección "Aprendizajes / Self-Annealing" tiene contenido?
- **Ítem 3 (JSDoc):** grep funciones/helpers nuevos del commit · ¿tienen header explicativo?
- **Ítem 4 (memoria):** ls `.claude/memory/feedback/` y `reference/` · ¿memorias nuevas referenciadas en `MEMORY.md`?
- **Ítem 4.5 (CSV):** ls `tests/manual/PRP-NNN_*.csv` · ¿existe? · ¿100% verde?
- **Ítem 4.6 (DT):** grep DT del PRP en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) · ¿abiertas con 8 campos? · ¿cerradas con commit hash + ✅ Resuelta?
- **Ítem 4.7 (Ultrareview log):** si camino CON · grep PRP en [`docs/logs/ultrareview-log.md`](../../../docs/logs/ultrareview-log.md) · ¿entry completa con hallazgos + estado por bug?
- **Ítem 5 (canónicos):** ¿el PRP afecta `BUSINESS_LOGIC.md` · `CLAUDE.md` · `WORKFLOW.md` · `docs/`? · ¿están actualizados?
- **Ítem 6 (commit):** `git log -1 --format="%s%n%b"` · ¿commit local incluye resumen + aprendizajes?

**Clasificar cada hallazgo en 2 grupos:**

- **Mecánicos** (path obvio · acción inequívoca · cero decisión de contenido):
  - Roadmap: `[ ]` → `[x]` cuando el commit cierra la task del PRP · notas inferibles del trabajo de la sesión.
  - `MEMORY.md`: agregar fila índice cuando ya existe archivo en `feedback/` o `reference/` no indexado.
  - DT: mover fila a "Resueltas" con commit hash cuando el PRP cerró la DT explícita.
  - Header del PRP: actualizar estado canónico (`EN PROGRESO` → `EN PROGRESO (paso X cerrado · ...)` o `COMPLETADO` post-merge a `main`) según § Mapping de la regla #18.
  - `log.md`: entry `prp-close` · `decision` · `lint` con shape canónico de regla #20 [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md).
- **Estructurales** (requieren decisión de contenido del user):
  - Sección "Aprendizajes / Self-Annealing" del PRP (qué incluir · qué omitir).
  - Texto de memoria nueva en `feedback/` o `reference/` (qué codificar · qué dejar afuera).
  - Severidad de DT nueva (`critical` · `normal` · `nit`).
  - Cambios en archivos canónicos (`CLAUDE.md` · `BUSINESS_LOGIC.md` · `WORKFLOW.md`) — esos siempre requieren firma user (paridad regla #21 [`documentos-definitivos.md`](../../rules/documentos-definitivos.md)).

### Paso 4 · Aplicar mecánicos · presentar estructurales · reportar al user

**Aplicación mecánica:**

- Para cada hallazgo mecánico · aplicar el fix directo con Edit/Write.
- Cero modificación de archivos PROHIBIDOS por la regla #18 § "Qué NUNCA se modifica".
- Cero commit automático · cambios quedan en working tree (paridad regla #27).

**Presentación de estructurales:**

- Para cada hallazgo estructural · presentar al user con formato canónico (paridad regla [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md)): contexto 1-2 líneas · A/B/C cuando aplica · recomendación early con justificación 1-frase · `¿OK firmás?`.
- Una decisión por vez · cero agrupar 3+ decisiones en un mensaje.
- Aplicar la firma con Edit/Write una vez el user responde.

**Cierre del skill** con párrafo café 3-5 líneas (paridad [`conversation-style.md`](../../rules/conversation-style.md)):

```text
Apliqué N fixes mecánicos del checklist (paths exactos): [resumen 1-2 líneas].
M fixes estructurales presentados arriba · firmaste K · pendientes P para próxima iteración.
Working tree con cambios listos · pendiente commit local cuando estés OK.
```

**Reglas del cierre:**

- Listar fixes mecánicos aplicados con paths exactos · cero dejar archivos modificados en silencio.
- Listar estructurales pendientes (no firmados) · el user sabe qué falta.
- Recordatorio de commit local · paridad regla #27 (cambios docs commitean local · NO push automático).
- **Gate mecánico ítem 6 GR · commit local pendiente:** correr `git status --porcelain` al cierre del Paso 4 · si hay cambios reportar paths + sugerir mensaje commit que cubre resumen + aprendizajes (regla #18 ítem 6 firma user contractual · NO genérico "fix docs") · si limpio reportar explícito *"checklist ya al día · cero commit necesario"* (caso normal cuando se invoca preventivamente).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Skipeo el Paso 1 · ya sé los 6 ítems de memoria" | NO. La regla es SoT contractual · puede haber cambiado (refinamientos del mapping · ajustes del checklist · nuevos ítems). Read cuesta segundos · evita drift entre skill y regla. |
| "Aplico el fix estructural sin firma user porque la decisión parece obvia" | NO. Los estructurales requieren firma user contractualmente · "obvio" es subjetivo · el agente NO decide contenido de Aprendizajes / memoria nueva / severidad DT sin firma. Aplicar sin firma rompe el contrato + introduce contenido que el user no validó. |
| "Modifico SKILL.md / settings.json / hooks porque el ítem 5 dice 'archivos canónicos'" | NO. Regla #9 § "Qué NUNCA se modifica" es contractual · los archivos del agente NUNCA se tocan para documentar aprendizajes del proyecto. Aprendizajes operacionales del agente van a `.claude/memory/feedback/` · NO a skills/settings/hooks. |
| "Aplico todos los fixes y commiteo automático para ahorrar el round-trip" | NO. Skill NO commitea · paridad regla #27 ("1 push por PRP en paso 6" · cambios docs commitean local separado · cero auto-commit). El user revisa working tree y commitea cuando esté OK. |
| "Re-uso la inferencia de paso del flujo de hace 5 turnos sin re-verificar" | NO. Cada invocación obliga re-detectar (Paso 2). El estado cambia turno a turno · re-usar = subset de ítems equivocado aplicado. |
| "El user invoca pero la sesión es trivial · skipeo la auditoría" | OK si genuinamente trivial sin documentación pendiente (verificar When). Pero el push-back tiene que ser explícito y argumentado · cero "asumir que no aplica" silenciosamente. |
| "Aplico mecánicos sin reportar al user · el diff lo cuenta solo" | NO. Cierre formato canónico es contractual · el user merece ver qué se aplicó con paths exactos + qué quedó pendiente · cero dejar el reporte al diff. |
| "Forzaré el ítem 4.5 (CSV) durante paso 3 porque el checklist dice 6 ítems" | NO. Anti-pattern PRP-NNN codificado en regla #18 § Mapping · el ítem 4.5 es exclusivo del paso 5 `/validar` · forzarlo en paso 3 pisa rol de `/validar` y crea CSV prematuro. El subset por paso es contractual. |

## Red flags

- 🚩 Aplicás fixes sin haber leído la regla #18 en esta invocación (Process Paso 1 omitido).
- 🚩 Tu Paso 2 inferencia de paso del flujo es ambigua y NO preguntaste al user antes de aplicar.
- 🚩 Aplicaste un fix estructural (Aprendizajes · memoria nueva · severidad DT · archivos canónicos) sin firma explícita del user.
- 🚩 Tu Edit/Write incluye cambios en archivos PROHIBIDOS por regla #18 § "Qué NUNCA se modifica" (`.claude/skills/**/SKILL.md` · `settings.json` · hooks · agents · MCPs).
- 🚩 Commiteaste automáticamente post-aplicación · skill no commitea · paridad regla #27.
- 🚩 Tu cierre no lista fixes aplicados con paths exactos · usuario tiene que descubrir cambios via `git status`.
- 🚩 El subset de ítems que aplicaste NO matchea el paso del flujo detectado en Paso 2 (ej: forzaste ítem 4.5 CSV en paso 3 · anti-pattern PRP-NNN).
- 🚩 Agrupaste 3+ decisiones estructurales en un mensaje · viola "una decisión por vez" (paridad regla #2 metodologia-iteracion).

## Verification

- [ ] Paso 1 ejecutado · regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) leída en esta invocación (cero cache previo).
- [ ] Paso 2 ejecutado · paso del flujo en curso detectado + subset de ítems aplicables identificado · ambigüedad presentada al user con A/B cuando aplica.
- [ ] Paso 3 ejecutado · cada ítem del subset evaluado con tooling read-only · hallazgos clasificados en mecánicos vs estructurales.
- [ ] Paso 4 ejecutado · mecánicos aplicados con Edit/Write · estructurales presentados con firma · reporte final con paths exactos.
- [ ] Cero modificación de archivos PROHIBIDOS por regla #18 § "Qué NUNCA se modifica".
- [ ] Cero auto-commit · working tree listo para que el user commitee.
- [ ] Gate mecánico ítem 6 GR aplicado al cierre · `git status --porcelain` corrido · si hay cambios mensaje commit sugerido con resumen + aprendizajes (regla #18 ítem 6) · si limpio reportado explícito "cero commit necesario".
- [ ] Cierre formato canónico (3-5 líneas estilo café · fixes aplicados + estructurales pendientes + recordatorio commit).

**Cross-reference firme:**

- SoT contractual: [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) (regla firme #18 · checklist 6 ítems + § Mapping paso del flujo → ítems aplicables + § Qué SÍ/NUNCA se modifica).
- Hermana arquitectónica: skill [`/fatiga`](../fatiga/SKILL.md) ↔ regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (mismo patrón skill ↔ regla SoT · cero duplicación · read-only porque la regla #9 emite aviso conversacional).
- Hermana arquitectónica: skill [`/handoff`](../handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](../../rules/session-handoff.md) (mismo patrón skill ↔ regla SoT · cero duplicación · write porque la regla #26 genera archivo material).
- Refuerza: [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (regla #20 · entry `prp-close` · `decision` · `lint` con shape canónico cuando paso del flujo lo amerita).
- Refuerza: [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (regla #24 · DT abierta en el acto · skill verifica al cierre que la fila tenga 8 campos contractuales).
- Refuerza: [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) (regla #27 · skill NO commitea · paridad "1 push por PRP en paso 6").
- Refuerza: [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) (formato de presentación de estructurales · una decisión por mensaje · recomendación early con justificación 1-frase).
- Refuerza: [`conversation-style.md`](../../rules/conversation-style.md) (cierre con párrafo café 3-5 líneas · paths exactos · cero verbosidad).
- Refuerza: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (Paso 2 ambigüedad de inferencia · A/B antes de seguir).
