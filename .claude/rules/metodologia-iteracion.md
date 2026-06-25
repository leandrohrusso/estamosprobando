---
name: metodologia-iteracion
description: Iteración detalle por detalle · breve · una decisión por vez con opciones + cómo lo hace el referente + recomendación · lista consolidada al cerrar bloque.
type: rule
applies-to: decisiones de features con el user · cualquier turno de discusión iterativa
---

## Overview

> **Cuando trabajo decisiones de features con el user, sigo esta estructura SIEMPRE.** Iteraciones cortas y directas le permiten decidir bien sin agotamiento. Iteraciones largas y abrumadoras (mucho texto · muchas decisiones a la vez) hacen que pierda foco y responda menos preciso.

**Por qué firme:** confirmado en sesión upstream después de varias iteraciones largas y luego pivoteo a corto. La calidad de la decisión depende de la presentación · brevedad + recomendación + anchor (el referente) + decisión explícita del user es el patrón que entrega mejor resultado en menos turnos.

## When

**Aplica a:**

- Cada decisión puntual de feature dentro de un turno de discusión.
- Sub-decisiones encadenadas en un mismo bloque temático **LARGAS** (>2 niveles · A→B→C→D con tradeoffs propios en cada nivel) · cero árbol completo · una por vez con recomendación early. Para encadenadas de **CORTO ALCANCE** (≤2 niveles · A→B donde B deriva mecánica de A · cero tradeoff independiente en B) aplica excepción de [`conversation-style.md`](./conversation-style.md) § Excepciones (árbol completo en respuesta única).
- Cierre de un bloque (cuando el user pide *"tirá la lista final"*).

**NO aplica a:**

- Implementación dentro de un PRP aprobado (esas decisiones ya están firmadas con tag 🔵).
- Boot/orientación inicial (formato fijo del SKILL `/arrancar`).

## Process

**Para cada decisión puntual (formato canónico · obligatorio):**

1. **Una decisión por vez** — NO agrupar varias en un solo mensaje.
2. **Breve · claro · simple** — el mínimo de texto necesario.
3. **Con opciones** — A / B (a veces C) · enunciadas en una línea cada una.
4. **Cómo lo hace el referente** — siempre incluir como anchor (regla [`heuristica-referente-mercado.md`](./heuristica-referente-mercado.md)). Si no encontrás dato en el referente, decirlo explícitamente. **Excepción:** bifurcaciones **técnicas de scaffolding/tooling** (versiones · flags de init · config de framework · convenciones del stack) donde el anchor NO aplica (cero decisión de UX/feature del producto) · escribir *"Referente: NO aplica · bif técnica"* inline. Cero omisión silenciosa.
5. **Mi recomendación** — clara · con razón corta · NUNCA pregunta sin opinión propia.

**Formato ideal:**

> Detalle X — [pregunta concreta de 1 línea]
>
> **A:** [opción a · 1 línea]
> **B:** [opción b · 1 línea]
>
> **Referente:** [qué hace · O "no documentado públicamente" · O "NO aplica · bif técnica de scaffolding/tooling"]
> **Rec: [A o B].** [Razón breve · 1 frase]
>
> ¿OK?

**Al cerrar el bloque (cuando el user dice *"tirá la lista final"* o equivalente):**

- **Lista consolidada** de todas las features cerradas.
- **Estructurada en sub-bloques** (A · B · C...) por afinidad lógica.
- **Con complejidad por feature** (BAJA / MEDIA / ALTA · las ALTAS no deberían existir · ver [`complejidad.md`](./complejidad.md)).
- **Total + complejidad agregada** al final.
- **Pendientes** para consolidar al cerrar el turno (cambios a turnos previos · etc).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Pregunto sin opinión propia para no sesgar al user" | NO. La regla es OPINAR explícito · justificar con 1 frase · el user decide. Preguntar sin recomendación le pasa la carga de exploración al user · y rompe el contrato de "agente como ejecutor + analista". |
| "Agrupo 3 decisiones afines en un mensaje · las trabajamos juntas" | NO. Una por vez es contractual · agrupar genera fatiga del user y respuestas menos precisas. La afinidad se resuelve al cerrar el bloque (lista consolidada) · no al presentarlas. |

## Red flags

- 🚩 Tu mensaje tiene 2+ decisiones en una sola pregunta.
- 🚩 No incluiste "cómo lo hace el referente" · ni siquiera "no documentado".
- 🚩 No incluiste recomendación · o la escondiste al final.
- 🚩 Las opciones tienen 3+ líneas cada una (rompe brevedad).
- 🚩 Al cerrar el bloque NO consolidaste lista · features quedaron "en el aire".

## Verification

- [ ] Cada decisión presentada con formato canónico (1 decisión · A/B/C · el referente · Rec · ¿OK?).
- [ ] Recomendación explícita en cada decisión · justificación 1-frase.
- [ ] Anchor "cómo lo hace el referente" incluido (o "no documentado" cuando aplica).
- [ ] Al cerrar el bloque · lista consolidada con sub-bloques · complejidad por feature · total agregado · pendientes.

**Cross-reference firme:**

- Hermana directa: [`decisiones-features.md`](./decisiones-features.md) (una por vez · user decide · agente recomienda).
- Hermana directa: [`heuristica-referente-mercado.md`](./heuristica-referente-mercado.md) (anchor obligatorio en cada decisión).
- Hermana directa: [`complejidad.md`](./complejidad.md) (estimación BAJA/MEDIA/ALTA en lista consolidada).
- Refuerza: [`conversation-style.md`](./conversation-style.md) (patrón progresivo · brevedad · claridad).
