---
name: decisiones-features
description: Las decisiones de features se toman UNA POR UNA, en conjunto con el user. NO proponer set cerrado y pedir confirmación masiva.
type: rule
applies-to: armado de PRD · roadmap · planificación de features · cualquier discusión de scope
---

## Overview

> **Las features del producto se deciden UNA POR UNA, en conjunto con el user. NO proponerle un set cerrado de features y pedir confirmación masiva.**

**Por qué firme:** el user tiene experiencia directa en el dominio del producto — su criterio sobre alcance vale más que el del agente. Cita textual: *"Después vamos a analizar una por una las funcionalidades; no las vas a elegir tú, las elegiré yo contigo en conjunto. Repasaremos cada una y diremos: esta sí, esta no, una por una."* Confiar en su criterio · NO consolidar features sin su firma explícita por cada una.

## When

**Aplica a:**

- Armado del PRD inicial.
- Roadmap consolidado.
- Cualquier sesión de "qué features entran al MVP / a V1.5 / a V2".
- Discusión de scope al arrancar un PRP nuevo.
- Cualquier turno donde aparezca una feature potencial nueva.

**NO aplica a:**

- Implementación dentro de un PRP ya aprobado (esas decisiones se cierran via `/planificar` o el flujo del PRP).
- Sub-decisiones cosméticas de UX dentro de un Claude Design handoff (esas siguen el flujo de la matriz Claude Design).

## Process

**Reglas operativas:**

1. **Para cada módulo / feature potencial:** presentar el "qué es" + "cómo lo resuelven las referencias (ej: el referente)" + "trade-off" + recomendación early con justificación 1-frase + esperar decisión explícita del user.
2. **Para módulos grandes** (ej: membresías, marketplace): descomponer en sub-features y revisar cada una individualmente · NO mergear "membresías = SÍ/NO" en una sola decisión.
3. **Recomendación opinada** está OK · pero la decisión final es del user.
4. **Si el user da un OK conjunto a varias** (ej: *"esas 3 las dejamos para V2"*), confirmarlo una sola vez en el resumen y avanzar — no insistir con la regla cuando él activamente dijo lo contrario.

**Patrón canónico de presentación de cada feature:**

> Feature X — [descripción 1-línea]
>
> **Qué resuelve:** [problema · 1 frase]
> **Cómo la hace el referente** (o referencia): [resumen · 1-2 frases · o "no documentado públicamente"]
> **Trade-off:** [costo vs beneficio · 1 frase]
>
> **Mi recomendación: [SÍ a MVP / NO / V1.5+].** [Razón · 1 frase]
>
> ¿Qué te parece?

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Tengo claras las 12 features · las presento juntas para ahorrar tiempo" | NO. Presentarlas juntas le pasa el costo cognitivo al user · pierde foco · responde menos preciso. La regla es UNA POR UNA · iterar es el contrato. |
| "El user es experimentado · puede decidir 5 a la vez" | NO. La regla no es sobre capacidad del user · es sobre calidad de la decisión. UNA POR UNA permite que cada decisión condicione la siguiente. |

## Red flags

- 🚩 Tu mensaje tiene 4+ features detalladas con pregunta final *"¿qué hacemos con cada una?"*.
- 🚩 Estás cerrando un PRD/roadmap con features que el user nunca aprobó individualmente.
- 🚩 La sesión avanzó y agrupaste 3 features sin que el user firmara cada una.
- 🚩 Recomendación al final · escondida después de párrafos largos · sin firma early.

## Verification

- [ ] Cada feature del PRD/roadmap tiene registro explícito de la decisión del user (mensaje o memoria).
- [ ] Cero "consolidaciones masivas" donde 5+ features pasaron sin firma individual (excepto OK conjunto explícito del user).
- [ ] Recomendación early en cada decisión · justificación 1-frase.
- [ ] Trade-off presentado antes de pedir decisión.

**Cross-reference firme:**

- Refuerza: [`conversation-style.md`](./conversation-style.md) (patrón progresivo cuando hay 2+ decisiones).
- Refuerza: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (formato canónico de presentación).
