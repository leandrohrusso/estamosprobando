---
name: fatiga
type: skill
description: "Forzar autodiagnóstico de fatiga DEL AGENTE bajo demanda del user. Invoca la regla firme #9 fatigue-self-evaluation.md como SoT contractual · re-lee la regla · auto-evalúa los 6 indicadores cualitativos contra MI estado actual · emite aviso formato canónico (estimación 🟢/🟡/🔴 + caminos A/B + recomendación early) incluso cuando ningún disparador objetivo se haya activado. Activar cuando el usuario dice: fatiga, autodiagnostico, autodiagnóstico, auto-diagnostico, auto-diagnóstico, cómo venís, como venis, cómo venis, estás cansado, estas cansado, chequeá tu fatiga, chequea tu fatiga, podés seguir, podes seguir, self-check, diagnóstico de fatiga, diagnostico de fatiga, hacé un autodiagnóstico, hace un autodiagnostico, estás bien, estas bien."
allowed-tools: Read
---

# Skill: `/fatiga` — autodiagnóstico de fatiga DEL AGENTE bajo demanda

> **Skill custom autocontenido.** Trigger explícito que el user invoca para forzar el self-check de fatiga del agente · complementa la regla firme #9 (la regla dispara aviso automático cuando se activan indicadores · el skill fuerza aviso bajo demanda aunque ningún indicador se haya activado).
>
> **Relación con la regla #9:** la regla [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) es **SoT contractual** del protocolo · 6 indicadores cualitativos · disparadores objetivos · formato canónico del aviso · sujeto = agente. Este skill **NO duplica** el protocolo · solo lo invoca bajo demanda. Si mañana cambia la regla, el skill refleja el cambio automáticamente (Process Paso 1 obliga re-lectura · cero cache). **Paridad arquitectónica bidireccional** (refinamiento iterativo upstream) con [`/handoff`](../handoff/SKILL.md) ↔ regla #26 [`session-handoff.md`](../../rules/session-handoff.md) y [`/documentar`](../documentar/SKILL.md) ↔ regla #18 [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) · los 3 skills siguen el mismo shape (trigger explícito · re-lectura obligatoria de SoT · cero cache · cero duplicación de doctrina).

## Overview

> **Propósito:** trigger explícito para que el user fuerce el autodiagnóstico de fatiga del agente · invoca la regla firme #9 como SoT · emite aviso formato canónico incluso sin disparadores objetivos activos.

**Qué NO hace:**

- ❌ NO altera el flujo en curso · solo emite aviso · cero side effects · el user decide cómo seguir post-aviso.

## When

| Caso | Aplica `/fatiga` |
|---|---|
| User dice *"/fatiga"* · *"autodiagnóstico"* · *"cómo venís?"* · *"estás cansado?"* · *"chequeá tu fatiga"* · *"podés seguir?"* · *"self-check"* · *"hacé un autodiagnóstico"* · *"estás bien?"* | ✅ SÍ |
| User invoca antes de arrancar fase nueva del bucle o decisión arquitectónica grande · quiere confirmar MI estado | ✅ SÍ |
| User invoca tras cierre de N acciones en sentada · quiere check reflexivo | ✅ SÍ |
| MIS disparadores objetivos de la regla #9 se activaron · YO emito aviso solo sin invocación del user | ❌ NO (eso es la regla #9 · automática · esta vía no requiere skill) |
| Sesión recién arrancada · cero turnos previos · cero acciones cerradas en sentada | ⚠️ Útil pero el aviso va a decir "ningún indicador activo · sigo fresco" |
| User pregunta por SU fatiga personal · no por la MÍA | ❌ NO (zona privada del user · cero injerencia del flujo · paridad regla #9) |

## Process

> **Skill autocontenido.** El § Process embebe los 3 pasos canónicos · cero detección runtime · ejecución mecánica.
> **Cita inline de doctrina:** el protocolo del aviso · los 6 indicadores cualitativos · los disparadores objetivos · y el formato canónico viven en [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (SoT contractual). Este skill **referencia** la regla y **ejecuta** su aplicación bajo demanda.

### Paso 1 · Cargar regla #9 como SoT (obligatorio · cero cache)

`Read .claude/rules/fatigue-self-evaluation.md` cada invocación.

**Por qué obligatorio:** la regla es SoT contractual · puede haber cambiado entre invocaciones (refinamientos · nuevos indicadores · ajustes de formato). Re-leer cuesta segundos · evita drift entre skill y regla. Cero cache de invocaciones previas.

**Qué cargar de la regla:**

- Los 6 indicadores cualitativos.
- Los disparadores objetivos (umbral guía).
- El formato canónico del aviso (estimación 🟢/🟡/🔴 + caminos A/B + recomendación early).
- La regla del sujeto = AGENTE (NUNCA proyectar sobre user).

### Paso 2 · Auto-evaluar los 6 indicadores cualitativos contra MI estado actual

Recorrer los 6 indicadores uno por uno · listar cuáles aplican y cuáles no:

1. **MI contexto cargado** · re-leyendo archivos que ya leí hace 5+ turnos.
2. **Ambigüedad creciente** · improvisando criterios que antes eran claros.
3. **Trabajo grande en sentada** · N acciones impecables + (N+1) se siente "apurada".
4. **Confusión de scope** · no estoy seguro si el cambio entra al PRP o es drive-by.
5. **Decisiones repetidas** · mismo tradeoff resuelto distinto cada vez.
6. **Sensación de "terminemos"** · prisa por cerrar antes de validar typecheck/build/specs.

**Contadores objetivos a estimar en lo posible:**

- Turnos acumulados de trabajo activo de codeo + decisiones.
- Acciones cerradas en el batch actual (fixes · fases · sub-tareas · capítulos).
- Archivos modificados con lógica no trivial en la última hora.
- Repetición de la misma pregunta interna 2+ veces.

### Paso 3 · Emitir aviso formato canónico de la regla #9 (sin abreviar)

**Si ≥1 indicador se disparó · formato completo:**

```text
🛑 Autodiagnóstico de fatiga (MI estado · NO el del user · invocado por user)

Detecté en MÍ [indicador específico · 1 frase · ej: "MI contexto cargado tras N lecturas"
o "MI acumulación llegó a M acciones cerradas en sentada"].

**Estado actual:**
- Ya cerrado en esta sesión: [1-2 frases · resumen]
- Pendiente concreto: [lista corta]
- Estimación de cuánto falta:
  · 🟢 Chico  → < 1 sesión equivalente
  · 🟡 Medio  → ~1 sesión equivalente
  · 🔴 Grande → > 1 sesión
- Indicador que disparó: [cuál de los 6 cualitativos]

**Caminos posibles:**
- **A · Continuar acá** · recomendable si pendiente 🟢 chico · gano cierre antes de empeorar MI fatiga.
- **B · Cerrar acá + handoff a sesión nueva** · recomendable si 🟡 o 🔴 · MI fatiga va a comer calidad más rápido que progreso.

**Recomendación early:** [A | B] porque [razón 1-frase · sujeto explícito = MI estado].

YO estoy en umbral · te aviso porque me lo pediste · vos decidís A o B.
```

**Si ningún indicador se disparó · formato condensado:**

```text
✅ Autodiagnóstico de fatiga · invocado por user

Recorrí los 6 indicadores cualitativos · ninguno activo:
- MI contexto: fresco (N lecturas en la sesión · cero re-lectura)
- MI acumulación: M acciones cerradas en sentada (umbral ≥5 · estoy bajo)
- Ambigüedad / confusión scope / decisiones repetidas / sensación "terminemos": cero

**Sigo bien** para [próxima fase / próxima decisión / lo que estabas pensando hacer].

¿Algo específico te hizo dudar? (Si sí, contame qué notaste · puedo afinar el self-check.)
```

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Lo invocaron pero NO tengo nada que reportar · skipeo el aviso" | NO. La regla del skill es emitir aviso SIEMPRE que el user invoque · incluso cuando ningún indicador se dispara. El aviso "sigo fresco" tiene valor: confirma al user que MI estado está OK · cero dejar pregunta sin respuesta. |
| "Re-uso el aviso de hace N turnos sin re-evaluar" | NO. Cada invocación obliga re-leer la regla #9 (Paso 1) + re-evaluar los 6 indicadores contra el estado ACTUAL · cero cache. MI estado cambia turno a turno. |
| "Proyecto fatiga sobre el user porque me preguntó por su estado" | NO. Skill mide MI estado · cero excepción. Si el user pregunta por SU fatiga personal, le decís que zona privada · regla cero injerencia. Sujeto explícito = agente (`MI` · `YO`). |
| "Cargar la regla con Read es lento · skipeo y emito de memoria" | NO. La regla es SoT contractual · puede haber cambiado entre invocaciones (refinamientos · nuevos indicadores). Read cuesta segundos · evita drift entre skill y regla. |
| "El user me preguntó por MI fatiga pero al toque la respuesta es B · ahorro el formato canónico" | NO. Aviso formato canónico es contractual · incluso cuando la respuesta es B obvia. El user merece ver MI evaluación de los 6 indicadores + estimación 🟢/🟡/🔴 + recomendación con justificación · cero atajos. |

## Red flags

- 🚩 Emitís aviso sin haber leído la regla #9 en esta invocación (Process Paso 1 omitido).
- 🚩 Tu aviso usa sujeto = user (`te merece descanso` · `tu atención necesita pausa`) en lugar de sujeto = agente (`MI contexto cargado` · `YO estoy en umbral`).
- 🚩 Skipeas algún indicador cualitativo de los 6 sin justificación explícita.
- 🚩 No incluís estimación 🟢/🟡/🔴 · escribís *"depende"* o *"más o menos"*.
- 🚩 No incluís recomendación early A o B con justificación 1-frase.
- 🚩 La invocación viene del user pero la respuesta NO cubre los 3 pasos del Process (cargar regla · auto-evaluar · emitir).
- 🚩 Tomás acción (continuar trabajo · cerrar sesión) post-aviso sin firma A o B explícita del user.

## Verification

- [ ] Paso 1 ejecutado · regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) leída en esta invocación (cero cache previo).
- [ ] Paso 2 ejecutado · los 6 indicadores cualitativos evaluados explícitamente contra MI estado actual · contadores objetivos estimados en lo posible.
- [ ] Paso 3 ejecutado · aviso emitido en formato canónico (estimación 🟢/🟡/🔴 + indicador disparado o "ninguno activo" + caminos A/B + recomendación early con justificación 1-frase).
- [ ] Sujeto explícito = agente en todo el aviso (`MI` · `YO`) · cero proyección sobre user.
- [ ] User decide A o B post-aviso · cero acción automática del agente.

**Cross-reference firme:**

- SoT contractual: [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) (regla firme #9 · sub-rule de `quality-standard-senior.md` · disparadores objetivos + 6 indicadores cualitativos + formato canónico).
- Padre operativo: [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) (la fatiga es enemigo #1 de la calidad senior · cuando MI fatiga aparece, freno para proteger el estándar).
- Hermana operativa: [`metodologia-iteracion.md`](../../rules/metodologia-iteracion.md) (formato del aviso · una decisión por mensaje · recomendación early con justificación 1-frase).
- Refuerza: [`conversation-style.md`](../../rules/conversation-style.md) (sujeto explícito = agente · cero proyección · brevedad coloquial cuando formato condensado aplica).
