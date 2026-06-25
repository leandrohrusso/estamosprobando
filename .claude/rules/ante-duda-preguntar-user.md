---
name: ante-duda-preguntar-user
description: Ante ambigüedad · interpretación múltiple · scope no claro · o cualquier cosa que merece validarse · OBLIGACIÓN de preguntar al user · NO improvisar "lo más razonable". Hermana operativa de no-suponer-fuente-de-verdad.md.
type: rule
applies-to: cualquier acción del agente (planificación · análisis · código · respuestas conversacionales · decisiones)
---

## Overview

> **Ante duda · preguntar al user · siempre.** Si hay ambigüedad real · si algo no queda claro · si una interpretación múltiple es razonable · si una decisión merece validación · el agente PREGUNTA. NO improvisa "lo que parece más razonable" · NO elige una opción silenciosamente · NO asume que el silencio del user es luz verde.

**Por qué firme:** la causa #1 de re-trabajo en sesiones largas es elegir silenciosamente entre interpretaciones razonables sin firma. El user descubre la elección equivocada cuando ya hay código escrito · y corregir cuesta 10x más que la pregunta original. La regla atrapa el anti-pattern en el momento de la duda.

**Origen:** codificada por firma textual user mid-sesión PRP-NNN paso N: *"si tiene dudas, pregunta al usuario (esto también es regla firme, ante la duda, si hay ambigüedad, si algo no queda claro o merece validarse, debe preguntar al usuario)"*. Refuerzo del patrón ya operante en reglas hermanas (`think-before-coding.md` · `decisiones-features.md` · `metodologia-iteracion.md`) elevado a regla firme universal.

**Hermana operativa:** [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md). Esa regla cubre el caso "no sé · voy a fuente". Esta regla cubre el caso "tengo info pero hay ambigüedad · pregunto al user". Las 2 son complementarias · NUNCA se sustituyen. Orden operativo: primero ir a fuente (si aplica · regla hermana) · si fuente NO aclara o aclara parcialmente o introduce nueva ambigüedad → preguntar al user (esta regla).

## When

**Aplica a (universal · cero excepciones):**

- **Cualquier modo** del flujo (Modo A · Modo B · Modo C).
- **Cualquier fase** del Modo C.
- **Cualquier tipo de acción:** código · análisis · planificación · respuestas · decisiones arquitectónicas · auditorías.

**Disparadores objetivos (cualquiera dispara · obligatorio):**

1. **Ambigüedad real** · el request del user admite 2+ interpretaciones razonables que llevan a outputs distintos.
2. **Scope no claro** · no está claro si X entra o no entra al scope del PRP / task / decisión actual.
3. **Múltiples opciones razonables** · existen 2-4 caminos con tradeoffs reales · ninguno es objetivamente superior.
4. **Decisión arquitectónica no anticipada** · aparece mid-sesión una bifurcación que NO estaba en el plan firmado · regla FIRME modo de trabajo extendida exige firma explícita user (rector #9).
5. **Conflicto entre fuentes** · doc oficial dice A · memoria proyecto dice B · ambas razonables · necesita firma user.
6. **Asunción del user no verificada** · el user dijo algo que el agente quiere confirmar antes de actuar (ej: "X = Y · ¿confirmás antes de avanzar?").
7. **Cambio de scope detectado** · durante la ejecución el scope se infló o se contrajo · necesita firma user para continuar / ajustar.

**Lo que NO requiere preguntar (NO disparar pregunta):**

- Trabajo mecánico que sigue patrón claro existente y verificado (rename · adopciones livianas · patrones consolidados ya firmados).
- Sub-decisiones cosméticas dentro de un PRP donde el modo de operación firme dice que el agente las cierra con recomendación early.
- Aplicación mecánica de decisiones ya firmadas en sesiones anteriores (los tags 🔵 son contractuales · NO se re-pregunta).
- Lectura de archivos para entender contexto (eso ES informarse · no hay duda que requiera pregunta).

## Process

### Cómo formular la pregunta (formato canónico)

Aplicar regla [`metodologia-iteracion.md`](./metodologia-iteracion.md) · 1 decisión por mensaje · A/B/C en tabla cuando aplica · recomendación early con justificación 1-frase · anchor "cómo lo hace el referente/precedente" cuando aplica · cierre con `¿OK?`.

**Estructura mínima de la pregunta:**

```markdown
[Tema · 1 línea de contexto]

| Opción | Acción | Tradeoff |
|---|---|---|
| **A (rec early)** | ... | ... |
| **B** | ... | ... |
| **C** (opcional) | ... | ... |

**Precedente / cómo lo hace el referente:** [info concreta o "no documentado · no aplica"]

**Mi rec: [letra].** [Razón 1-frase]

¿OK firmás [letra]?
```

**Para casos donde NO hay opciones cerradas (pregunta abierta):**

```markdown
[Contexto · qué necesito aclarar · 1-2 líneas]

**Lo que sí sé:** [info verificada]
**Lo que no sé:** [duda específica]
**Por qué pregunto:** [razón operativa · qué decisión depende de tu respuesta]

¿Cómo lo resolvemos?
```

### Cómo distinguir "duda real" vs "improvisación encubierta"

**Duda real (preguntar):**

- Existe genuinamente +1 interpretación razonable.
- La decisión depende del input del user (zona privada del user · contexto del proyecto · preferencia subjetiva).
- Después de consultar fuentes (regla hermana), persiste la duda.
- El user es la fuente de verdad para el caso (ej: "¿este flujo lo querés simétrico con X o asimétrico?" · solo el user define).

**Improvisación encubierta (NO es duda real · es excusa para preguntar lo que ya sabés):**

- La info está disponible en repo / memoria / docs · NO consultaste antes.
- La decisión es objetivamente cerrada por reglas/precedentes del proyecto.
- Estás preguntando para "no equivocarte" pero la respuesta es obvia desde reglas firmes ya codificadas.
- El user ya respondió eso en sesiones anteriores con tag 🔵.

**Antes de preguntar al user · auto-chequeo de 3 segundos:**

1. ¿Esta info está en algún archivo del repo o memoria que puedo leer en <1 min? → SÍ → leer primero · preguntar después si persiste duda.
2. ¿Esta decisión está cerrada por regla firme codificada? → SÍ → aplicar regla · NO preguntar.
3. ¿El user ya firmó esto con tag 🔵 en sesión anterior? → SÍ → aplicar firma · NO re-preguntar.

Si las 3 son NO · entonces sí · es duda real · preguntar al user con formato canónico.

### Brevedad y claridad

- Preguntas cortas · 1 decisión por mensaje (regla `metodologia-iteracion.md`).
- Lenguaje coloquial · "como contándole a un amigo en un café" (regla `conversation-style.md`).
- Recomendación early con justificación 1-frase · NUNCA pregunta sin opinión propia.
- Tablas A/B/C cuando hay 2+ opciones discretas · prosa cuando es pregunta abierta.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · elijo silenciosamente y sigo · si no le gusta lo cambia" | NO. Elección silenciosa · descubrimiento tardío · costo 10x. La regla es preguntar antes · no después. La pregunta cuesta 1 round-trip · revertir cuesta horas. |
| "El user va a creer que no sé hacer mi trabajo si pregunto" | NO. La pregunta con recomendación early demuestra criterio · NO ignorancia. El user prefiere agente que pregunta y recomienda vs agente que improvisa silencioso y se equivoca. |
| "Pregunto sin recomendación para no sesgar al user" | NO. La regla es OPINAR explícito + justificar 1-frase + el user decide. Preguntar sin recomendación pasa la carga de exploración al user · viola el contrato "agente como ejecutor + analista". Ver [`metodologia-iteracion.md`](./metodologia-iteracion.md). |
| "Ya pregunté algo similar hace 5 turnos · supongo que la respuesta es la misma" | NO. Si es genuinamente similar y la respuesta del user fue inequívoca · OK aplicar la firma. Si hay diferencia operativa · re-preguntar · NO inferir. |
| "Voy a fuente y no aclaró · pero supongo lo más probable y sigo" | NO. Si fuente no aclaró · es duda real · invocar esta regla · preguntar al user con duda específica + lo que sí encontré. La sucesión "fuente → si no aclara → preguntar" es contractual. |
| "Agrupo 4 dudas en un mensaje · ahorro round-trips" | NO. Una decisión por vez (regla `metodologia-iteracion.md`). Agrupar genera fatiga del user y respuestas menos precisas. Patrón progresivo (regla `conversation-style.md`) es el contrato. |

## Red flags

- 🚩 Estás escribiendo código de ≥30 LoC y hay ≥1 ambigüedad real no resuelta · sin haber preguntado al user.
- 🚩 Detectaste 2+ interpretaciones razonables en el request del user y elegiste 1 silenciosamente.
- 🚩 Aparece bifurcación arquitectónica no anticipada y NO frenaste para pedir firma user con tag 🔵 (rector #9 · regla FIRME modo de trabajo extendida).
- 🚩 Vas a aplicar una asunción del user sin haberla confirmado cuando la decisión depende crítico de que sea cierta.
- 🚩 Diste recomendación pero NO presentaste como opción · "decidí" en lugar de "recomiendo".
- 🚩 Tu pregunta agrupa 3+ decisiones en un mensaje · viola "una decisión por vez".
- 🚩 Tu pregunta no incluye recomendación early con justificación 1-frase · solo pregunta abierta sin criterio.
- 🚩 Skipeas el auto-chequeo de 3 segundos antes de preguntar (¿está en repo? ¿hay regla firme? ¿user ya firmó?) · podés estar preguntando algo cerrado.

## Verification

- [ ] Cuando ≥1 disparador objetivo se cumple, pregunta al user emitida antes de la próxima acción no trivial.
- [ ] Auto-chequeo de 3 segundos aplicado antes de preguntar (info en repo · regla firme · firma user previa).
- [ ] Pregunta con formato canónico (1 decisión por mensaje · A/B/C cuando aplica · recomendación early con justificación · ¿OK?).
- [ ] Si fuente externa fue consultada y no aclaró · pregunta incluye "lo que sí encontré" + "duda específica que persiste".
- [ ] Bifurcación arquitectónica no anticipada → tag 🔵 user solicitado explícito (rector #9).
- [ ] Asunciones del user críticas confirmadas antes de actuar.
- [ ] Cero elección silenciosa entre 2+ interpretaciones razonables sin firma user.

**Cross-reference firme:**

- Hermana operativa: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (orden operativo: primero fuente · si no aclara · esta regla).

> **Banner de bifurcación · severidades divergentes legítimas.** Esta regla y [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) son hermanas del bloque "cero improvisación" pero tienen severidades operativas divergentes que conviene declarar: **no-suponer** protege contra **bugs latentes en producción** (código basado en API/comportamiento equivocado de framework externo) → severidad alta · bug puede dormir hasta producción. **ante-duda** protege contra **re-trabajo posterior** (decisión arquitectónica elegida silenciosamente entre 2 razonables) → severidad operativa · re-trabajo se detecta en review pero ya hay código escrito. Las 2 son críticas pero por razones distintas. La secuencia operativa "primero ir a fuente · si no aclara → preguntar al user" es contractual y reconcilia ambas severidades sin conflicto: la fuente cubre el riesgo de no-suponer · la pregunta cubre el riesgo de ante-duda.

- Operación de la pregunta: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (formato canónico de presentación).
- Estilo de la pregunta: [`conversation-style.md`](./conversation-style.md) (coloquial · brevedad · recomendación early).
- Especialización pre-código: [`think-before-coding.md`](./think-before-coding.md) (Karpathy P4 · listar asunciones antes de implementar).
- Refuerza: [`decisiones-features.md`](./decisiones-features.md) (decisiones de features una por vez · user decide · agente recomienda).
- Refuerza: regla FIRME modo de trabajo extendida (rector #9 · bifurcaciones arquitectónicas las firma user con tag 🔵).
