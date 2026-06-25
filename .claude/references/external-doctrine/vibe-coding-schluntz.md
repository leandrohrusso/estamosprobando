# [Snapshot] Vibe Coding en Producción · Erik Schluntz (Anthropic)

> **Fuente original:** charla de Erik Schluntz en el evento **Code with Claude** (Anthropic). Resumen educativo en markdown adjuntado por Leandro a la conversación del 2026-05-05.
> **Formato:** transcript / síntesis (no archivo de repo).
> **SHA capturado:** N/A (no aplica a transcript)
> **Fecha snapshot:** 2026-05-05
> **Por qué está acá:** referencia central del **paradigma Vibe Coding** que entra como input firme. Origen de los principios **P1 (Humano = PM de la IA)**, **P2 (Leaf nodes vs core · vibe-coding agresivo en leaf, review humano en core)**, **P3 (Checkpoints verificables del comportamiento del producto · shift-left)** del análisis fundacional del proyecto upstream. El **paso 6 del documento (checkpoints verificables)** es el insumo principal del checkpoint shift-left del flujo.
> **NO modificar** — snapshot inmutable.

---

# Vibe Coding en Producción: Guía paso a paso

Resumen educativo de la charla de Erik Schluntz (Anthropic) en el evento Code with Claude.

**Objetivo:** entender qué es el "vibe coding", cuándo sirve, cuándo es peligroso, y cómo aplicarlo de forma responsable en un entorno real de trabajo.

## La idea central en una frase

> "No preguntes qué puede hacer Claude por vos, preguntá qué podés hacer vos por Claude."

Tu trabajo deja de ser escribir código y pasa a ser dirigir a la IA como si fueras su Product Manager.

## 1. ¿Qué es el Vibe Coding?

La definición original es de **Andrej Karpathy**: dejarte llevar por la intuición, confiar en la IA para que escriba el código, y olvidarte de que el código existe.

La clave es esa última parte: no se trata solo de usar herramientas como Cursor o Claude Code para autocompletar. Se trata de un cambio de postura:

- **El código no es tu problema. El producto es tu problema.**
- **Vos verificás comportamiento, no líneas.**

### Diferencia rápida

| Coding tradicional con IA | Vibe Coding |
|---|---|
| Humano escribe prompt → IA sugiere → humano revisa cada línea → acepta o modifica | Humano define requisitos → IA implementa → humano verifica el output → se despliega |

## 2. Por qué importa ahora (y no en 5 años)

Según un estudio de METR, la duración de las tareas que una IA puede completar de forma confiable se duplica cada 7 meses. Hoy los modelos de frontera completan tareas de unos 50 minutos de trabajo humano; si la curva sigue, en pocos años manejarán tareas de semanas.

**Moraleja:** dentro de uno o dos años, exigir leer cada línea de código te va a convertir en el cuello de botella de tu equipo. Hay que aprender a delegar bien ahora.

**Analogía útil:** los primeros programadores revisaban el assembly que generaba el compilador. Hoy nadie lo hace. Confiamos en la capa de abstracción. Con la IA va a pasar lo mismo.

## 3. El cambio de mentalidad: sos el PM de la IA

Esta es la parte más importante de toda la charla.

Un CTO no entiende en profundidad cada área técnica de su empresa, pero igual la gestiona. Un CEO no revisa cada cálculo contable, pero igual firma los balances. ¿Cómo lo hacen? Construyen **capas de abstracción verificables**: no controlan el cómo, controlan que el resultado se comporte bien.

Vos tenés que hacer lo mismo con el código que genera Claude.

En vez de preguntarte:

- ❌ "¿Este código está bien escrito?"

Preguntate:

- ✅ "¿Este sistema se comporta como tiene que comportarse?"

## 🛠 El proceso paso a paso

Esta es la parte operativa: el flujo de trabajo concreto para hacer vibe coding sin que se te prenda fuego el proyecto.

### Paso 1 — Elegí bien dónde aplicarlo: "leaf nodes" sí, arquitectura no

No todo el código es igual de riesgoso.

- **Leaf nodes (nodos hoja):** funciones o features que nada más depende de ellos. Son hojas del árbol: si tienen un poco de deuda técnica, no arrastran al resto del sistema. Ejemplo: una feature aislada en una app de React que consume un design system que ya existe.
- **Núcleo / arquitectura base:** el tronco del árbol. Acá la deuda técnica se propaga. Si se rompe, se rompe todo.

**Regla práctica:**

- En leaf nodes → dejá que la IA vuele.
- En el núcleo → revisión humana exhaustiva, línea por línea.

⚠ **Aviso:** a medida que los modelos mejoran, la frontera entre "dejable a la IA" y "revisar a mano" se corre hacia abajo. Revisala cada tanto.

### Paso 2 — Ponete el sombrero de Product Manager (antes de tocar nada)

Esta es la etapa que la mayoría se saltea, y por eso les va mal.

Antes de pedirle a Claude que implemente algo, invertí entre 15 y 20 minutos (a veces horas, a veces días para cambios grandes) armando contexto.

Hacete estas preguntas, como si estuvieras onboardeando a un empleado nuevo:

- ¿Qué hay que construir, exactamente?
- ¿Cuál es el criterio de éxito?
- ¿Qué restricciones hay? (performance, estilo, compatibilidad, seguridad)
- ¿Qué patrones ya usa este codebase y hay que respetar?
- ¿Qué archivos son relevantes? ¿Cuáles hay que tocar y cuáles no?
- ¿Cómo voy a verificar que funciona sin leer toda la implementación?

**Truco concreto que recomienda Schluntz:**

Abrí una conversación aparte con Claude solo para explorar el codebase, identificar archivos relevantes, y armar un plan. Después, con ese plan ya consolidado, arrancás la sesión de implementación con un único prompt detallado.

### Paso 3 — Pasá a Claude el contexto completo, no goteado

El error típico es mandar un prompt vago y después ir corrigiendo a los tirones ("no, así no... ahora cambiá esto... ahora lo otro").

En vez de eso:

- Juntá toda la guía, requisitos, especificaciones y restricciones en un solo prompt rico.
- Incluí ejemplos si tenés.
- Señalá los archivos y patrones clave.
- Dejá claro qué no hay que tocar.

Pensalo así: si un compañero junior leyera solo ese prompt, ¿podría hacer bien el trabajo? Si la respuesta es no, expandilo.

### Paso 4 — Diseñá checkpoints verificables, no revisiones de código

**Acá está el truco que hace que todo esto sea seguro.**

En vez de auditar el código, armá mecanismos que te digan si el sistema se comporta bien:

- **Inputs y outputs legibles por humanos.** Si ves el antes/después, ¿entendés qué pasó?
- **Stress tests de estabilidad** pensados para correr en el tiempo.
- **Tests end-to-end mínimos** centrados en comportamiento observable, no en detalles internos.
- **Validaciones a nivel sistema**, no a nivel función.

La pregunta que tenés que poder responder con datos es:

> 🎯 "¿Este sistema sigue haciendo lo que tiene que hacer, bajo carga y en casos borde?"

### Paso 5 — Dejá a Claude implementar, vos verificás el comportamiento

Ahora sí, ejecutás:

- Claude hace la implementación siguiendo el plan.
- Vos corrés los checkpoints del Paso 4.
- Si los checkpoints pasan → el cambio es válido.
- Si no pasan → volvés con feedback concreto (no "esto está mal", sino "falló el test X con input Y").

Lo que ya no hacés: leer línea por línea.
Lo que sí hacés: confirmar que el producto funciona.

### Paso 6 — Reservá revisión humana profunda para lo crítico

Aunque el 80–90% del código pueda ir por la vía rápida, siempre hay partes que exigen ojo humano:

- Lógica central del negocio.
- Código que otros módulos van a extender en el futuro.
- Seguridad, manejo de credenciales, permisos.
- Cualquier cosa que toque datos sensibles o dinero.

**Regla:** cuanto más profundo en el árbol del sistema, más manual el review.

## 4. Caso real: 22.000 líneas fusionadas en producción

El equipo de Schluntz mergeó un cambio de 22.000 líneas al codebase de Reinforcement Learning de Anthropic, mayoritariamente escrito por Claude. Lo hicieron siguiendo exactamente el proceso de arriba:

| Estrategia | Qué hicieron |
|---|---|
| PM humano profundo | Varios días de planificación manual y levantamiento de requisitos antes de pedirle a Claude que escribiera algo. |
| Alcance acotado a leaf nodes | Los cambios se concentraron en zonas donde un poco de deuda técnica era aceptable. |
| Revisión humana del core | La lógica crítica y extensible se revisó línea por línea a mano. |
| Checkpoints verificables | Stress tests de estabilidad diseñados a propósito, con inputs y outputs chequeables por humanos. |

**Resultado:** el mismo nivel de confianza que cualquier otro merge grande, pero en una fracción del tiempo. Lo que habría sido dos semanas de trabajo humano, se comprimió en aproximadamente un día.

## 5. Errores comunes (y cómo evitarlos)

- **Prompts vagos → resultados vagos.** Si el input es "hacé la feature X", la IA rellena los huecos con suposiciones. Invertí tiempo en el prompt.
- **Querer vibe coding en el núcleo del sistema.** Ahí la deuda técnica se propaga. No.
- **Revisar código en vez de comportamiento.** Vuelve lento el proceso y no te da más seguridad. Confiá en los tests de sistema.
- **Saltarse los checkpoints porque "se ve que anda".** Sin verificación, no hay vibe coding responsable; hay solo rezar.
- **Vibe codear sin experiencia previa en el dominio.** Si no podés distinguir qué es peligroso y qué es seguro, todavía no es para vos.

## 6. ¿Y si dejo de aprender por no escribir código?

Una preocupación honesta. La respuesta de Schluntz es optimista:

- Los programadores de hoy ya no escriben assembly, y no se volvieron peores ingenieros.
- Con la IA como pair programmer permanente, aprendés más rápido, no menos.
- Te libera tiempo para decisiones de arquitectura y diseño de sistemas, que es donde está el valor.
- Te permite experimentar mucho más: probar ideas que antes no valían el costo de implementarlas.

Los que no crezcan serán los que se dejen estar. Los motivados, van a aprender más rápido que nunca.

## ✅ Checklist rápido para aplicar mañana

1. Identificá si lo que vas a hacer es un **leaf node** o parte del **núcleo**.
2. Abrí una conversación exploratoria con Claude para mapear el codebase y armar el plan.
3. Escribí un prompt único, rico y completo con requisitos, restricciones y patrones.
4. Diseñá **checkpoints verificables** antes de implementar.
5. Dejá implementar, corré los checkpoints, iterá con feedback específico.
6. Reservá revisión línea por línea solo para el código crítico.
7. Después del merge, observá el comportamiento en producción con los stress tests definidos.

## 🎯 Takeaway final

El vibe coding no es "abandonar la responsabilidad". Es **cambiar de rol**: pasás de escribir código a diseñar y verificar sistemas.

> Olvidate de que el código existe. Pero nunca te olvides de que el producto existe.
