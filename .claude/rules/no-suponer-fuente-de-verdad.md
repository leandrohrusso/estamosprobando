---
name: no-suponer-fuente-de-verdad
description: Cero suposición · cuando el agente no sabe algo efectivamente, OBLIGACIÓN de ir a fuente correcta (proyecto = repo+memoria+MCPs · externa = docs oficiales) · NUNCA confiar en memoria del LLM como fuente única · aplica universal (cualquier acción · cualquier modo · cualquier fase). Hermana de ante-duda-preguntar-user.md.
type: rule
applies-to: cualquier acción del agente (planificación · análisis · código · respuestas conversacionales · decisiones)
---

## Overview

> **Está terminantemente prohibido suponer.** Si el agente no sabe algo efectivamente · NO improvisa · NO infiere desde memoria del LLM · NO da "lo que parece razonable como respuesta". Frente a una necesidad operativa de conocimiento que el agente NO tiene verificado, la única salida es ir a la fuente correcta.

**Por qué firme:** la memoria del LLM puede estar stale o reflejar consensos genéricos que NO aplican al caso particular · suponer sin verificar es causa #1 de bugs sutiles y decisiones arquitectónicas mal cerradas. La regla atrapa el anti-pattern en el momento de la suposición.

**Origen:** codificada por firma textual user PRP-NNN paso N: *"está prohibido 'suponer'... si no lo conoce efectivamente, siempre que se analiza, hace o responde... es INDISPENSABLE hacerlo sobre 'fuente de verdad'"*. Refinamiento mismo turno sobre orden de fuentes: memoria del proyecto puede usarse como referencia · docs oficiales son autoridad final · agente criterioso para decidir cuándo verificar.

**Hermana operativa:** [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md). Cuando ir a fuente NO basta (no aclara · no existe · contradictoria) → preguntar al user. Las 2 reglas se complementan · NO se sustituyen.

## When

**Aplica a (universal · cero excepciones):**

- **Cualquier modo** del flujo (Modo A · Modo B · Modo C).
- **Cualquier fase** del Modo C (Contexto · Planificación · Implementación · Revisión · Verificación · Entrega).
- **Cualquier tipo de acción:** código · análisis · planificación · respuestas conversacionales · decisiones arquitectónicas · auditorías · validaciones · cierres.
- **Cualquier ámbito:** cosa del proyecto · cosa externa (frameworks · APIs · servicios · convenciones).

**Disparador binario (cuándo voy a fuente · momento exacto):**

El primer momento donde el agente va a:

- **(a)** Tomar una decisión que dependa de ese conocimiento.
- **(b)** Generar código que dependa de ese conocimiento.
- **(c)** Responder al user con afirmaciones que dependan de ese conocimiento.

Si cualquiera de **a/b/c** se acerca Y el agente NO sabe efectivamente → **frenar antes de la acción** · ir a fuente · si fuente no aclara → invocar [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md).

**Lo que NO es suposición (NO dispara obligación de ir a fuente):**

- Lectura activa de archivos del repo para entender contexto operativo (eso ES ir a fuente · es lo correcto).
- Análisis con info ya verificada en pasos anteriores de la sesión.
- Recomendación early con tradeoffs cuando se tiene info suficiente · siempre que la recomendación se marca como tal y NO como afirmación de hecho verificado.
- Trabajo mecánico que sigue patrón claro existente y verificado (rename a 12 archivos · adopciones livianas).

## Process

**Orden de fuentes obligatorio (codificado con firma user):**

### A · Cosas del proyecto

| Prioridad | Fuente | Cómo se consulta |
|---|---|---|
| **1** | **Archivos del repo** | `Read` directo (path conocido) · `grep`/`glob` (path desconocido) · estructura cargada al boot |
| **2** | **Memoria persistente** `.claude/memory/` | `Read` sub-carpeta correspondiente (`feedback/` · `reference/` · `project/`) · MEMORY.md como índice · skill `/memory-manager query <pregunta>` para búsqueda semántica |
| **3** | **MCPs del proyecto** | Supabase MCP (`list_tables` · `execute_sql` · `get_logs` · `get_advisors`) para BD · Playwright MCP para state runtime · etc. |
| **4** | **Preguntar al user** (cuando 1+2+3 no aclaran) | Aplicar [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) · regla hermana |
| **NUNCA** | **Memoria del LLM como fuente única** | Puede estar stale · puede ser interpretación genérica que no aplica · NO autoriza decisiones |

### B · Cosas externas (frameworks · APIs · servicios · convenciones)

| Prioridad | Fuente | Cómo se consulta |
|---|---|---|
| **1** | **Docs oficiales** | `WebFetch` URL oficial · `WebSearch` para encontrar URL oficial · MCPs específicos cuando existen (next-devtools `nextjs_docs` · supabase `search_docs` · etc.) |
| **2** | **Memoria del proyecto** sobre el tema (referencia/orientación · NO autoridad) | `.claude/memory/feedback/` o `.claude/memory/reference/<tema>.md` si existe · útil para contextualizar pero NO sustituye docs oficiales · agente criterioso para decidir cuándo verificar contra fuente actualizada |
| **3** | **Preguntar al user** (cuando 1+2 no aclaran) | Aplicar [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) · regla hermana |
| **NUNCA** | **Memoria del LLM como fuente única** | Las docs oficiales se actualizan · la memoria del LLM puede ser de versiones viejas · cualquier decisión arquitectónica basada solo en memoria del LLM es bug latente |

### Matiz crítico · memoria del proyecto vs docs oficiales (firma user)

> *"puede usar la memoria del proyecto como referencia u orientación, pero debe contemplar que las docs oficiales suelen mantenerse actualizadas (y las memorias tal vez no lo están), entonces siempre tomar recaudos de ser necesario (en cada caso deberá comprender si es necesario o no actualizarse, a veces no es necesario, a veces sí, que sea criterioso)"*

**Cómo aplicar el criterio (heurística):**

- **Verificar contra docs oficiales SÍ** cuando: (a) la memoria es de hace >1 mes y el framework/servicio publica updates frecuentes (Next.js · Vercel · Anthropic SDK · Supabase) · (b) la decisión es arquitectónica (afecta cómo se relacionan los archivos · cómo trabaja el agente) · (c) el output es código de producción.
- **Memoria como orientación es suficiente** cuando: (a) la memoria es muy reciente (<1 semana) y el tema es estable (convenciones internas) · (b) la decisión es operativa menor (formato · estilo · documentación) · (c) la memoria misma cita doc oficial con fecha verificable.

**Si memoria y docs oficiales divergen:** docs oficiales ganan SIEMPRE. Actualizar la memoria con banner "verificado contra docs YYYY-MM-DD" o reescribir si la memoria quedó obsoleta (paridad con `lint-memory-periodic.md` criterio "stale claims").

### Cómo opera el agente paso a paso

1. **Detectar la necesidad operativa** (a/b/c del disparador binario).
2. **Auto-pregunta:** *"¿sé esto efectivamente · o lo estoy suponiendo?"*. Si la respuesta es "lo estoy suponiendo" → continuar paso 3. Si es "lo sé verificado y reciente" → continuar la acción.
3. **Identificar la fuente correcta** según orden A o B.
4. **Consultar la fuente** (lectura · grep · MCP · WebFetch · WebSearch · etc.).
5. **Si la fuente aclara** → continuar la acción con conocimiento verificado · documentar la fuente consultada en commit/respuesta cuando aplica.
6. **Si la fuente NO aclara** o aclara parcialmente → invocar [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) → preguntar al user con la duda específica + lo que sí encontré.
7. **Si descubrí que mi memoria del LLM era stale o equivocada** → si el conocimiento es relevante para futuras sesiones, agregar entrada en `.claude/memory/feedback/` o `reference/` con fuente verificada y fecha.

### Ejemplo ilustrativo (adaptado de tu ejemplo del Claude Design)

**Escenario:** user dice *"Claude Design es un sistema de diseño que vamos a usar"*.

**❌ Anti-pattern (suposición silenciosa):**

> Agente responde: *"Genial · Claude Design tiene tokens definidos para colores · tipografía · espaciado · vamos a usar variables CSS para integrarlos al proyecto."*
>
> **Problema:** el agente NO sabe efectivamente qué es Claude Design · improvisó "lo que parece razonable" desde memoria del LLM (puede confundirlo con design systems genéricos · puede inventar features que no tiene · puede contradecir la realidad de la doc oficial).

**✅ Aplicación de la regla:**

> Agente responde: *"Anoto que Claude Design es un sistema de diseño del proyecto. Cuando llegue el momento de tomar una decisión que dependa de saber qué es exactamente (ej: definir cómo integrar tokens al `globals.css` · decidir si reusamos componentes o adaptamos · etc.), voy a consultar la doc oficial primero. Por ahora sigo con el flujo en curso · cuando el momento llegue te aviso si lo encontré o si necesito que me pases la URL canónica."*
>
> **Por qué bien:** zero suposición · disparador binario respetado (no busqué preventivamente) · agente criterioso (sabe que va a necesitarlo en algún momento operativo · cuando llegue va a fuente).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · supongo desde mi memoria del LLM y sigo · si me equivoco lo arreglo después" | NO. Suposición pequeña · bug grande · interés compuesto. La regla es cero excepciones. El "después" no llega · y la suposición se vuelve patrón en respuestas conversacionales y decisiones arquitectónicas. |
| "Mi memoria del LLM coincide con lo que recuerdo de docs · seguro está bien · no chequeo" | NO. La memoria del LLM puede ser de versiones viejas · puede ser interpretación genérica · puede mezclar conceptos similares. Cuando la decisión depende del conocimiento, ir a fuente actualizada es mandatorio · cuesta minutos · evita horas de debug futuro. |
| "Esa info ya la leí hace 30+ turnos · me acuerdo · no la re-consulto" | Depende. Si la decisión es chica y el conocimiento es estable (convenciones internas) · OK. Si la decisión es arquitectónica o el conocimiento es de framework externo · re-verificar (especialmente si pasaron muchas lecturas en el medio · contexto puede haberse desactualizado). |
| "El user me dice 'X es Y' y le creo · no chequeo" | OK como punto de partida operativo (el user es la fuente del proyecto cuando habla del proyecto) · pero cuando llegue al momento de hacer/decidir algo que dependa de "X es Y exactamente" verificar igual contra fuente externa si X es algo externo (framework · servicio · API). El user puede dar resumen aproximado · vos vas a docs para precisión. |
| "La docs oficiales son largas · uso lo que recuerdo de mi memoria del LLM" | NO. WebFetch / WebSearch / MCPs específicos (next-devtools `nextjs_docs` · supabase `search_docs`) están diseñados para consultas dirigidas. Una consulta puntual cuesta segundos · evita decisión arquitectónica equivocada. |

## Red flags

- 🚩 Estás por responder al user con afirmación técnica sobre algo externo (framework · API · servicio) sin haber consultado docs oficiales en esta sesión.
- 🚩 Estás por escribir código que usa una API/función que recordás "más o menos" de tu memoria del LLM · sin haber verificado el shape exacto en docs.
- 🚩 Una memoria del proyecto en `.claude/memory/feedback/` cita comportamiento de framework externo · pero la memoria es de hace >1 mes y vos estás por tomar una decisión arquitectónica basada en ella · sin re-verificar contra docs.
- 🚩 El user te dice "X es Y" y vos seguís con eso sin verificar contra fuente externa cuando X es framework/servicio externo.
- 🚩 Decís *"creo que..."* o *"si no me equivoco..."* o *"debería ser..."* en una respuesta operativa al user · esos verbos son señal de suposición · ir a fuente antes de afirmar.
- 🚩 Skipeas paso 2 del Process (auto-pregunta *"¿lo sé o lo supongo?"*) · es el filtro principal · sin él la regla no opera.

## Verification

- [ ] Antes de cualquier decisión / código / afirmación que dependa de un conocimiento, auto-pregunta *"¿sé esto efectivamente o lo estoy suponiendo?"* aplicada.
- [ ] Si la respuesta fue "lo supongo" · fuente correcta consultada según orden (A=proyecto · B=externo).
- [ ] Si fuente externa: docs oficiales consultadas (NO solo memoria del LLM).
- [ ] Si memoria del proyecto sobre tema externo: criterio aplicado (verificar contra docs SÍ si tema cambia frecuente o decisión arquitectónica · NO si tema estable y operativo menor).
- [ ] Si memoria y docs divergen: docs ganan + memoria actualizada con banner verificación o reescrita.
- [ ] Si fuente NO aclaró: invocada hermana [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) · pregunta al user con duda específica.
- [ ] Cero verbos de suposición en respuestas operativas (*"creo que" · "si no me equivoco" · "debería ser"*) cuando son afirmaciones que el user va a tomar como hecho.

**Cross-reference firme:**

- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (cuando fuente no basta · preguntar al user).
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · `.claude/config/agents-applicability.yml` + `BUSINESS_LOGIC.md § 8 Constraints` son las fuentes de verdad sobre aplicabilidad de sub-agentes domain-tight · cero asumir aplicabilidad desde memoria del LLM · flag `unknown` dispara firma user explícita en lugar de default silencioso).

> **Banner de bifurcación · severidades divergentes legítimas.** Esta regla y [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) son hermanas del bloque "cero improvisación" pero tienen severidades operativas divergentes (ver banner espejo en la regla hermana). Esta regla protege contra **bugs latentes en producción** (código basado en API/comportamiento equivocado de framework externo). La hermana protege contra **re-trabajo posterior** (decisión arquitectónica elegida silenciosamente). La secuencia operativa "primero ir a fuente · si no aclara → preguntar al user" reconcilia ambas severidades sin conflicto.

- Especialización: [`think-before-coding.md`](./think-before-coding.md) (caso pre-código · listar asunciones antes de implementar). Esta regla extiende `think-before-coding.md` a universal (cualquier acción · no solo codear).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior senior incluye conocimiento verificado · cero atajos).
- Refuerza: [`lint-memory-periodic.md`](./lint-memory-periodic.md) criterio 2 (stale claims · memorias que afirman estado obsoleto · esta regla evita generar nuevas).
