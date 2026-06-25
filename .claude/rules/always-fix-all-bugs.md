---
name: always-fix-all-bugs
description: TODOS los bugs detectados se fixean SIEMPRE, sin importar severidad · prioridad descendente critical → normal → nit · cero tolerancia a diferimiento · estándar senior aplica a cada fix
type: rule
applies-to: hallazgos /ultrareview (sub-paso 6.◆), bugs durante /validar (paso 5), bugs durante /implementar (paso 3), reportes externos
---

## Overview

> **TODOS los bugs detectados se fixean SIEMPRE, sin importar severidad** (`critical`, `normal`, `nit`). Se prioriza por orden de importancia descendente (`critical` → `normal` → `nit`), pero el merge no avanza hasta que los tres niveles están cerrados. Si una doc dice "los `nit` son fix oportunista" o "los `normal` van a un PRP futuro", esa doc está obsoleta y se actualiza en el mismo commit que descubre la brecha.

**Por qué esta regla existe:** los reportes de `/ultrareview` distinguen severidad para priorizar atención, no para autorizar diferimiento. Mergear con `normal` o `nit` conocidos a `main` deja: (1) deuda invisible que se descubre meses después en producción, (2) bombas latentes (ej: `bug_001` UR-NNN: `softDeleteX` → registro en estado terminal permanentemente stuck sin path UX · adaptá a tu dominio), (3) documentación que miente al equipo (ej: DT-NNN ✅ Resuelta en CLAUDE.md mientras 2/4 endpoints siguen rotos). El costo marginal de fixear todo en 1 iteración del loop CON `/ultrareview` es bajo (typecheck+build+specs de regression-first FIRME ya están corriendo); el costo de no fixear se cobra después con interés compuesto.

**Codificada** durante el cierre de PRP-NNN paso 6 camino CON, después de UR-NNN reportar 0 critical / 3 normal / 0 nit. La regla anterior implícita ("max 1 iteración para critical genuino") se reinterpretó como "max 1 iteración sobre el batch completo de hallazgos, sin filtrar por severidad, con orden de prioridad y estándar senior".

## When

**Aplica a:**

- Hallazgos de `/ultrareview` (sub-paso 6.◆ del Modo C, camino CON).
- Bugs detectados durante `/validar` (paso 5 del Modo C).
- Bugs detectados durante el bucle (paso 3 del Modo C).
- Reportes externos (security review · audit retrospectivo · reportes del cliente/usuario final en producción · ej: en un dominio ticketing serían reportes del owner/tenant sobre comportamiento del flujo de conversión · adaptá a tu dominio).

**Excepción operativa única (declarada upfront · NO escondida):** bugs genuinamente fuera del scope técnico del PRP/sesión actual (ej: bug en el servicio de pagos externo cuando todavía corremos en modo simulado local · bug en el servicio de email transaccional cuando todavía no está integrado). En ese caso, **escalada obligatoria al user** (regla #6 [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) que firma entre **(a)** negociar entrada al scope actual con regression-first FIRME · **O (b)** DT en el acto según [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (regla hermana · 8 campos contractuales · sin esperar al cierre). **Cero auto-DT silenciosa · el agente NO decide solo si abre DT.** **NO es diferir el fix** · es trazar el fix a su scope correcto (camino b) o expandir el scope con firma user (camino a). Detalle operativo + 2da excepción (bug obsoleto por refactor en curso) en § Process abajo.

**Nota sobre estándar:** el cómo (con qué calidad) de cada fix vive en [`quality-standard-senior.md`](./quality-standard-senior.md) (los 6 puntos · sin duplicar acá). Esta regla cubre la **política operativa** (qué se fixea y cuándo); el estándar cubre el **cómo**.

## Process

**Reglas operativas:**

- **Orden de fix por severidad descendente.** Empezar por `critical` (bloquean merge per se), después `normal`, después `nit`. La prioridad operativa NO es justificación para saltarse niveles — es para garantizar que si el contexto se agota a mitad de un batch grande, lo más serio quedó cerrado primero. **Todos los niveles se cierran antes del `gh pr ready`.**
- **No diferir por severidad.** Un `nit` con fix de 3 líneas se fixea ahora. Un `normal` que requiere refactor más amplio se fixea ahora con regression-first FIRME (spec antes del fix). Un `critical` se fixea ahora y bloquea cualquier merge.
- **No diferir por "está fuera del scope del PRP".** Si el bug fue detectado durante un PRP, el PRP es responsable de cerrarlo. Si el agente juzga que el bug es genuinamente de otro PRP futuro (ej: servicio externo no integrado aún cuando hoy corremos en modo simulado local), **escalada obligatoria al user** (regla #6 [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) que firma entre **(a)** negociar entrada al scope actual con regression-first FIRME · **O (b)** DT en el acto según [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (8 campos contractuales · sin esperar al cierre). **Cero auto-DT silenciosa · el agente NO decide solo.**
- **No diferir por "es solo defense-in-depth".** Si la regla del proyecto dice "defensa en capas", todas las capas se fixean — no se elige cuál.
- **Loop de fix acotado a 1 iteración.** Si un fix introduce un bug nuevo, se documenta como gap del flujo en una memoria nueva y se fixea en el mismo commit. No abrimos loop infinito sobre el mismo PR draft.
- **Regression-first FIRME aplica siempre.** Cada fix necesita su caso codificado en `tests/e2e/regression/` o `tests/sql/` ANTES del fix (ver [`regression-first-on-fix.md`](./regression-first-on-fix.md)).
- **Documentación que diga lo contrario se actualiza en el mismo commit.** Si una memoria, un PRP, o un README implica que algún tipo de bug es diferible, se reescribe a "siempre se fixea". Cero tolerancia a documentación obsoleta que normalice el diferimiento.

**Excepciones reales (las únicas):**

1. **Bug detectado fuera del scope original del PRP/sesión actual.** El default firme es **FIXEAR TODO**. Si el agente juzga que el bug es genuinamente out-of-scope (ej: bug en el servicio de pagos externo cuando todavía corremos en modo simulado local · bug en el servicio de email transaccional cuando todavía no está integrado), **escalada al user obligatoria** (regla #6 [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) · **cero auto-DT silenciosa** · el agente NO decide solo si abre DT. El user firma uno de los dos caminos:
   - **(a) Negociar entrada al scope actual** · el bug entra al scope del PRP/sesión actual + fix con regression-first FIRME (regla [`regression-first-on-fix.md`](./regression-first-on-fix.md) · spec ANTES del fix). NO es diferimiento · es expansión firmada del scope. Paridad anti-rationalization regla #24 [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (excusa *"Voy a fixearlo igual aunque sea out-of-scope · no hace falta DT"* → rebuttal: **o (a) negociar entrada al scope · O (b) DT · NUNCA fixear silenciosamente**).
   - **(b) DT en el acto** · si el user firma que NO entra al scope actual · aplicar [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md): 8 campos contractuales (ID · síntoma · archivo · PRP destino · severidad · mitigación temporal · disparador · sesión) · sin esperar al cierre · sin esperar a confirmación adicional. El PRP destino consume esa DT y la cierra cuando llegue.
2. **Bug obsoleto por refactor en curso** (ej: el archivo va a desaparecer en este mismo PRP). Marcar como `🔵 obsoleto` en el reporte con commit de la remoción que lo cierra.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es solo un nit, lo dejo para el próximo PR" | NO. La regla es "siempre fixear todo, sin importar severidad". El nit de hoy se vuelve la asimetría que mañana es bug normal en otro módulo (ej: 2/3 bugs de un run de `/ultrareview` fueron asimetrías entre módulos hermanos · adaptá a tu dominio). Costo marginal de fixearlo ahora: minutos. Costo de diferirlo: interés compuesto. |
| "Es scope de otro PRP, no del mío" | NO. Si fue detectado durante TU PRP, TU PRP lo cierra. Excepción real: bug en servicio externo no integrado aún cuando estás en modo simulado local → **escalada al user** (regla #6 [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) que firma **(a)** negociar entrada al scope con regression-first FIRME · **O (b)** DT con disparador y mitigación temporal aplicada hoy. **Cero auto-DT silenciosa · el agente NO decide solo.** La excusa de "otro PRP" sin escalada al user es diferimiento encubierto. |

## Red flags

- 🚩 Reporte de `/ultrareview` tiene `nit` y estás por mergear sin fixearlo.
- 🚩 Documentación dice "este tipo de bug es diferible" — está obsoleta, hay que actualizarla en el mismo commit que descubre la brecha.
- 🚩 El batch tiene N bugs y para el último estás cortando esquinas para "terminar" — disparador de `fatigue-self-evaluation`, no de diferimiento.
- 🚩 Marcaste DT como ✅ Resuelta en CLAUDE.md o status banner pero solo 2/4 endpoints aplican el fix (anti-pattern: DT-NNN marcada resuelta con fix parcial).

## Verification

- [ ] Todos los bugs del reporte (`critical` + `normal` + `nit`) tienen fix aplicado · O escalada al user (regla #6 [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) firmada **(a)** entrada al scope con regression-first FIRME · **O (b)** DT con disparador documentado. **Cero auto-DT silenciosa.**
- [ ] Cada fix tiene su caso codificado en `tests/e2e/regression/` o `tests/sql/` (regression-first FIRME).
- [ ] Documentación que decía lo contrario se actualizó en el mismo commit (grep de "diferible" / "fix oportunista" / "para próximo PR" en docs tocadas).
- [ ] El estándar senior aplicó a cada fix (ver `quality-standard-senior.md` · cero hardcode, cero copy-paste, cero código basura, simetría entre módulos hermanos).
- [ ] Si DT cerrada: `docs/logs/technical-debt.md` movió la fila a Resueltas con commit hash.

**Cross-reference firme:**

- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (única excepción operativa · bug out-of-scope → escalada user firma (a) entrada al scope · O (b) DT en el acto · NO se difiere el fix · se difiere a otro PRP/contexto con trazabilidad · cero auto-DT silenciosa).
- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (regla #6 · escalada obligatoria al user cuando el agente juzga out-of-scope · cero auto-decisión silenciosa · user firma (a) negociar entrada al scope · O (b) autorizar DT).
- Hermana operativa: [`regression-first-on-fix.md`](./regression-first-on-fix.md) (esta regla codifica QUÉ se fixea · regression-first codifica CÓMO se fixea · spec antes del fix · regression-first FIRME).
- Hermana operativa: [`push-and-ci-policy.md`](./push-and-ci-policy.md) (excepción operativa +1 push al PR draft en camino CON `/ultrareview` cuando hay fixes consolidados de hallazgos del run).
- Hermana operativa: [`surgical-changes.md`](./surgical-changes.md) (la decisión binaria scope-in vs scope-out se materializa con cero drive-by · si está fuera de scope se registra como DT en lugar de fixear silenciosamente).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (cada fix con los 6 puntos del estándar · cero atajos).
- Refuerza: [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) (si el batch de fixes dispara fatiga, parar y aplicar sub-rule · NO entregar fixes mediocres por terminar).
