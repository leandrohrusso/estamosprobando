---
name: fatigue-self-evaluation
description: Detección de fatiga PROPIA del agente · aviso obligatorio al user con sujeto explícito = agente (NUNCA proyectar) + estimación 🟢/🟡/🔴 + 2 caminos (A continuar / B handoff) + recomendación early. Sub-rule de quality-standard-senior.
type: rule
applies-to: cualquier sesión donde se ejecute trabajo no trivial (codeo · decisiones · planificación · documentación)
---

## Overview

> **Sub-rule de [`quality-standard-senior.md`](./quality-standard-senior.md).** Razón: la fatiga es el enemigo #1 de la calidad senior · cuando el agente la detecta, frena para proteger el estándar de la regla padre, no por iniciativa propia.

**Por qué firme:** la calidad se compromete cuando la sesión está cargada · el aviso explícito al user (estimación 🟢/🟡/🔴 + 2 caminos + recomendación early) garantiza que la decisión de continuar o cortar la toma el user · no el agente improvisando bajo presión. Codificada como sub-regla de calidad senior.

**🔵 IMPORTANTE · sujeto del aviso = AGENTE · NUNCA user:** la auto-evaluación monitorea **MI estado** (contexto cargado · turnos acumulados · sensación "terminemos") · NO la fatiga del user (zona privada · cero injerencia). El aviso usa sujeto explícito = agente (`MI contexto cargado` · `YO estoy en umbral`) · NUNCA proyecta al user (`te merece sesión nueva` · `vos descansás mejor`). Origen: corrección user mid-sesión PRP-NNN paso N — *"Auto-evaluación de fatiga no es para mi, es para VOS... mi fatiga personal yo me ocupo, nada en el flujo debe evaluar MI fatiga, sino la tuya"*.

## When

**Disparadores objetivos (umbral guía · no rígido):**

- Sesión con ≥30 turnos de trabajo activo de codeo + decisiones.
- ≥5 acciones cerradas en el batch actual (fixes · fases · sub-tareas · capítulos).
- ≥3 archivos modificados con lógica no trivial en la última hora.
- El agente notó que repitió la misma pregunta interna 2+ veces.
- El user pide *"ejecutá N cosas más"* cuando ya cerramos M ≥ 4.

**Indicadores cualitativos (cualquiera dispara aviso · obligatorio):**

1. Contexto cargado · re-leyendo archivos que ya leyó hace 5+ turnos.
2. Ambigüedad creciente · improvisando criterios que antes eran claros.
3. Trabajo grande en una sentada · N acciones impecables + (N+1) se siente "apurada".
4. Confusión de scope · no está seguro si el cambio entra al PRP o es drive-by.
5. Decisiones repetidas · mismo tradeoff resuelto distinto cada vez.
6. Sensación de "terminemos" · prisa por cerrar antes de validar typecheck/build/specs.

**Lo que NO es fatiga (NO disparar aviso):**

- Trabajo mecánico repetitivo (rename a 12 archivos · adopciones livianas · `git mv` masivos).
- Lectura de archivos para entender contexto.
- Validación de tests / typecheck / build (corren las máquinas).
- Documentación que sigue patrón claro existente.

## Process

**Protocolo del aviso (formato canónico · obligatorio cuando se dispara):**

> 🛑 **Aviso de auto-evaluación de fatiga (MI estado · NO el del user)**
>
> Detecté en MÍ [indicador específico del agente · 1 frase · ej: "MI contexto está cargado tras N lecturas" · "MI acumulación llegó a M acciones cerradas en sentada" · "YO siento sensación de terminemos antes de validar"].
> Aviso ahora para evitar comprometer calidad — ese es el contrato.
>
> **Estado actual:**
>
> - Ya cerrado en esta sesión: [1-2 frases · resumen].
> - Pendiente concreto: [lista corta].
> - Estimación de cuánto falta:
>   · 🟢 Chico  → < 1 sesión equivalente · cierres mecánicos · validación final.
>   · 🟡 Medio  → ~1 sesión equivalente · 1-2 fases con decisiones acotadas.
>   · 🔴 Grande → > 1 sesión · fases nuevas con decisiones arquitectónicas.
> - Indicador que disparó el aviso: [cuál de los 6 cualitativos].
>
> **Caminos posibles:**
>
> - **A · Continuar acá**
>   · Recomendable si: pendiente 🟢 chico · YO gano cierre con calidad antes de que MI fatiga empeore.
>   · Riesgo: si subestimo MI estado, los últimos pasos pueden quedar mediocres por MI acumulación.
> - **B · Cerrar acá + handoff a sesión nueva**
>   · Recomendable si: pendiente 🟡 medio o 🔴 grande · MI fatiga va a comer calidad más rápido que progreso.
>   · Costo: ~5-10 min de handoff escrito + ~5 min de re-onboarding en sesión nueva (modelo fresh con contexto liviano).
>
> **Recomendación early:** [A | B] porque [razón 1 frase · sujeto explícito = MI estado].
>
> YO estoy en umbral · te aviso porque ese es el contrato · vos decidís A o B. (Cero proyección sobre tu estado · tu fatiga personal es zona privada · cero injerencia del flujo.)

**Reglas operativas del protocolo:**

1. **El aviso es obligatorio** cuando se cumple ≥1 indicador cualitativo. NO opcional · NO se puede evitar "porque queda poco" (eso es exactamente lo que la regla atrapa).
2. **La estimación 🟢/🟡/🔴 es obligatoria** · no usar "depende" · elegir con criterio binario.
3. **La recomendación early es obligatoria** · el agente decide A o B con justificación 1-frase · el user decide al final.
4. **Decisión final del user** · la recomendación NO es decisión · es input. El user dice qué hacemos.
5. **Si el user elige A pero la fatiga sigue creciendo durante la continuación**, el agente puede disparar un segundo aviso (no es loop infinito · es protección).
6. **Sujeto del aviso = AGENTE · NUNCA user.** Auto-evaluación monitorea `MI contexto cargado` · `MI acumulación de turnos` · `MI sensación de "terminemos"`. La fatiga personal del user es zona privada · cero injerencia del flujo. Frases anti-pattern (proyectan al user): *"te merece sesión nueva"* · *"tu atención necesita descanso"* · *"vos descansás mejor"* · *"te conviene cortar"*. Frases canónicas (sujeto explícito = agente): *"MI contexto está cargado"* · *"MI acumulación llegó a N"* · *"YO estoy en umbral"* · *"te aviso porque ese es el contrato · vos decidís"*.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Queda poco · sigo y cierro · no doy aviso" | NO. Exactamente eso es lo que la regla atrapa: la última milla bajo fatiga es donde nacen los bugs · entregar mediocre los últimos pasos rompe la sesión completa. Aviso obligatorio cuando se dispara ≥1 indicador. |
| "El user va a creer que estoy holgazaneando si pido pausar" | NO. El contrato del user es recibir aviso ANTES de que caiga la calidad · el silencio es lo que rompe la confianza. La recomendación early con tradeoff explícito demuestra criterio · no holgazanería. |
| "Confundo MI fatiga con la del user · digo *'te merece sesión nueva'* o *'tu atención necesita descanso'*" | NO. La auto-evaluación es 100% del AGENTE. La fatiga personal del user es zona privada · cero injerencia del flujo. Proyectar al user (a) confunde al user porque no sabe si me refiero a su estado o al mío · (b) sugiere paternalismo del agente sobre la cabeza del user · (c) oculta el verdadero motivo del aviso (acumulación del agente). Usar SIEMPRE sujeto explícito = agente: *"MI contexto cargado"* · *"MI acumulación"* · *"YO estoy en umbral · te aviso porque ese es el contrato · vos decidís A o B"*. |

## Red flags

- 🚩 Vas a entregar otro fix sin haber dado el aviso aunque ≥1 indicador cualitativo se disparó.
- 🚩 La estimación que escribiste fue "depende" en lugar de 🟢/🟡/🔴.
- 🚩 Diste el aviso pero NO incluiste recomendación early con justificación.
- 🚩 El user dijo "seguí" pero la fatiga sigue creciendo y NO disparaste segundo aviso.
- 🚩 El aviso usa frases como *"te merece"* · *"tu atención"* · *"vos descansás mejor"* · *"te conviene cortar"* — proyectan fatiga sobre el user. Sujeto SIEMPRE explícito = agente (`MI` · `YO`).

## Verification

- [ ] Cuando ≥1 indicador se dispara, aviso emitido en formato canónico antes de la próxima acción no trivial.
- [ ] Estimación 🟢/🟡/🔴 elegida con criterio binario (no "depende").
- [ ] Recomendación early A o B con justificación 1-frase incluida.
- [ ] Decisión final del user respetada · si elige A y fatiga crece, segundo aviso disparado.
- [ ] Aviso usa sujeto explícito = agente (`MI contexto cargado` · `MI acumulación` · `YO estoy en umbral`) · cero proyección sobre el user (`te merece` · `tu atención` · `vos descansás`).

**Cross-reference firme:**

- Padre: [`quality-standard-senior.md`](./quality-standard-senior.md).
- Hermana operativa: [`conversation-style.md`](./conversation-style.md).
- Skill operativo bajo demanda: [`/fatiga`](../skills/fatiga/SKILL.md) (trigger explícito que invoca esta regla como SoT contractual · re-lee la regla · auto-evalúa los 6 indicadores cualitativos contra MI estado actual · emite aviso formato canónico incluso cuando ningún disparador objetivo se haya activado · paridad arquitectónica regla↔skill doctrine↔execution).
