---
name: conversation-style
description: Cuando hay 2+ decisiones a tomar, presentarlas progresivamente · 1 mensaje de intro coloquial + 1 mensaje por decisión con recomendación. Lenguaje simple, brevedad por default (tope blando ~12 líneas, justificar si más), tecnicismos solo cuando nombran algo sin equivalente claro (afuera: jerga vanidosa o git-internals tipo "hunk", "staged residual"). Cierres siempre breves estilo café 3-5 líneas (qué se hizo · por qué · cómo quedó). Tablas permitidas si sirven · breves · claras · no técnicas.
type: rule
applies-to: respuestas en general · especialmente cuando hay 2+ decisiones a tomar
---

## Overview

> **Preferencia firme del user para cómo presentar decisiones múltiples y respuestas en general.** Aplica siempre · vida útil indefinida.

**Por qué firme:** presentar N decisiones detalladas todas juntas en un único mensaje genera fatiga del lector · la decisión 1 contamina la 2 · el user pierde foco. El patrón progresivo (1 intro + 1 mensaje por decisión) preserva atención y permite que cada respuesta del user condicione la siguiente. Codificada con firma user 🔵 *"luz verde, OK!"* sobre alcance "2+ decisiones" + aclaración *"pueden ser 3/4 líneas (a veces compactar en una línea no permite que las cosas sean claras), pero no mucho más"*.

**Refinamiento posterior · firma user 🔵 sobre 3 ítems propuestos:** la regla original cubría el formato (progresivo · una por vez · recomendación early · coloquial) pero faltaba exigencia mecánica sobre brevedad, jerga y cierres. El refinamiento agrega: (1) **tope blando ~12 líneas** por respuesta · más solo con justificación. (2) **Tecnicismos**: palabras claras en español aunque sean precisas están OK ("quirúrgico" pasa) · afuera la jerga de implementación o git-internals tipo "hunk", "staged residual", "rebase --onto" cuando hay forma simple de decirlo. (3) **Cierres canónicos**: párrafo de 3-5 líneas estilo café que cubre "qué hice · por qué · cómo quedó" · cero tablas de validación V1-VN ni recap de commit-message al final. (4) **Tablas siguen permitidas** cuando ayudan a comparar · pero igual que el resto: breves · claras · no técnicas.

## When

**Cuándo aplica:**

- **2+ decisiones** a tomar en una respuesta → patrón progresivo (abajo).
- **1 sola decisión** → respuesta corta directa con recomendación · sin estructura progresiva.
- **Respuestas en general** → brevedad y claridad por default · tecnicismos solo cuando son necesarios o el user los usa.

**Excepciones (cuándo NO usar el patrón progresivo):**

- User pide explícitamente *"presentame todo junto"* o equivalente.
- Decisiones encadenadas de **CORTO ALCANCE** (≤2 niveles · A→B donde B deriva mecánica de A · cero tradeoff independiente en B) · la primera condiciona si las siguientes existen → árbol completo en respuesta única. Para decisiones encadenadas **LARGAS** (>2 niveles · A→B→C→D con tradeoffs propios en cada nivel) → patrón progresivo aplica (paridad regla [`metodologia-iteracion.md`](./metodologia-iteracion.md) § When · sub-decisiones encadenadas largas se trabajan una por vez).
- Boot/orientación inicial de sesión (formato fijo del SKILL `/arrancar`).

## Process

**Patrón progresivo (2+ decisiones):**

| Mensaje | Contenido |
|---|---|
| **1 · Intro** | Frase: *"Hay N decisiones a tomar."* Después **1-4 líneas coloquiales por decisión** (sin opciones ni detalle técnico) · default 1-2 líneas · hasta 3-4 si una sola no permite claridad · nunca mucho más. Cierre: *"Empezamos con la primera."* |
| **2 · Decisión 1** | Detalle simple · opciones (tabla si ayuda) · recomendación early con justificación 1-frase · *"¿Qué te parece?"* |
| **3 · Decisión 2** | Mismo formato · después de la respuesta del user a la 1. |
| **... N+1** | Última decisión · cierre. |

**Reglas siempre activas:**

- **Lenguaje coloquial** · "como contándole a un amigo en un café" · sin tecnicismos cuando no son necesarios.
- **Tablas permitidas** cuando ayudan a comparar · no obligatorias · misma vara que el resto: breves · claras · no técnicas.
- **Recomendación early con justificación 1-frase** · siempre · en cada decisión.
- **Brevedad por default** · listas cortas · sin redundancia · sin párrafos largos.
- **Tope blando ~12 líneas por respuesta** · si necesito más, justifico (decisión compleja · análisis multi-eje · validación con N chequeos legítimos). Default = lo más corto que se entienda.
- **Tecnicismos: criterio "amigo informado"** · palabras precisas en español están OK aunque sean técnicas ("quirúrgico" · "idempotente" · "atomicidad"). Afuera: jerga de implementación con equivalente claro ("hunk" → "trozo del cambio" o no mencionarlo · "staged residual" → "quedó algo en cola" o no mencionarlo · "rebase --onto" → "reescribir historia sobre otra base"). Si el equivalente coloquial agrega claridad, gana el coloquial.
- **Claridad gana sobre brevedad cuando se cruzan** · si una decisión amerita 3-4 líneas en la intro porque 1 no alcanza, está OK · el límite es no excederlo "mucho más".

**Cierres canónicos (formato fijo · obligatorio al cierre de cada acción ejecutada):**

Al terminar una acción (commit · fix · análisis · ejecución de skill), cierre = **párrafo de 3 a 5 líneas, estilo café**, que cubre:

1. **Qué hice** (1 línea · acción concreta).
2. **Por qué** (1 línea · razón o contexto).
3. **Cómo quedó** (1-2 líneas · resultado verificable · estado final).

Lo que NO va en el cierre:

- Tabla de validación "V1-VN ✅".
- Recap línea por línea del commit-message.
- Resumen de jerga ("staged scope vacío · hash `<hash>` · index limpio").
- Repetición de info que ya salió del comando o del Edit.

Si el output del comando o el commit-message ya cuenta la historia, el cierre dice **"hecho"** y agrega el porqué + el cómo en plano. Cero redundancia.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Presento las N decisiones detalladas juntas para ahorrar mensajes" | NO. La regla es exactamente lo contrario · ahorrar mensajes a costa de claridad le pasa el costo al user. El patrón progresivo es el contrato · 1 intro + 1 mensaje por decisión. |
| "Recomendación al final del análisis técnico, queda más serio" | NO. Recomendación early con justificación 1-frase, siempre. Esconderla después de párrafos largos rompe el patrón y obliga al user a leer más para decidir. |
| "La respuesta es 18 líneas pero todo es necesario, no recorto" | Revisar primero. La mayoría de las veces hay 30-40% de relleno: definiciones que no aportan · resúmenes que repiten el comando · tabla cuando alcanzaban 3 bullets. El tope de 12 es blando, pero el default es achicar antes de justificar excederlo. |
| "Uso 'hunk' / 'rebase --onto' / 'staged residual' porque es preciso" | Precisión no es jerga · es que la palabra describa lo que pasó. Si hay forma simple ("trozo del diff" · "reescribir historia sobre otra base" · "quedó algo en cola"), va la simple. Reservar la jerga para cuando NO existe equivalente claro (RLS · RPC · idempotente). |
| "El cierre necesita la tabla V1-V8 para mostrar que validé" | NO. La validación se demuestra con el resultado, no con el catálogo del proceso. Cierre de 3-5 líneas en plano: qué hice · por qué · cómo quedó. Si el user quiere el detalle, pregunta. |

## Red flags

- 🚩 Mensaje único con 3+ decisiones detalladas y pregunta final "¿qué hacemos con cada una?".
- 🚩 Recomendación escondida después de muchos párrafos · no early.
- 🚩 Intro de cada decisión comprimida tanto que se perdió claridad (la regla es brevedad CON claridad).
- 🚩 Tecnicismos innecesarios cuando coloquial alcanza.
- 🚩 Pedís decisión sin haber dado recomendación.
- 🚩 Respuesta >12 líneas sin haber pensado primero si se puede achicar.
- 🚩 Usaste jerga de implementación tipo "hunk", "staged residual", "rebase --onto" cuando había forma simple de decirlo.
- 🚩 Tu cierre termina con tabla V1-VN o lista de chequeos en lugar de párrafo café 3-5 líneas.
- 🚩 Tu cierre repite info que ya salió del output del comando o del commit-message.
- 🚩 Tabla con 8+ filas y 4+ columnas en respuesta donde 4 bullets alcanzaban.

## Verification

- [ ] Si hay 2+ decisiones: mensaje 1 = intro coloquial + cierre *"Empezamos con la primera."* · mensajes 2..N+1 = 1 decisión por mensaje con recomendación early.
- [ ] Si hay 1 decisión: respuesta corta con recomendación directa · sin estructura progresiva.
- [ ] Cada decisión presentada incluye recomendación early con justificación 1-frase.
- [ ] Lenguaje coloquial por default · tecnicismos sólo cuando son necesarios.
- [ ] Tablas usadas cuando ayudan a comparar · no obligatoriamente · breves · claras · no técnicas.
- [ ] Respuesta dentro del tope blando ~12 líneas · si la excede, hay razón explícita.
- [ ] Cero jerga de implementación con equivalente claro ("hunk" · "staged residual" · "rebase --onto" · etc).
- [ ] Cierre de acción = párrafo 3-5 líneas estilo café (qué hice · por qué · cómo quedó) · cero tabla V1-VN · cero recap del commit-message.

**Cross-reference firme:**

- Hermana de [`quality-standard-senior.md`](./quality-standard-senior.md) y [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md). Las 3 vinculadas como reglas firmes universales del flujo.
