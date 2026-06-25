---
name: repaso-features
description: Al cerrar una feature/sub-feature, hacer repaso sintético antes de pasar a la siguiente · asegura alineación · evita decisiones "en el aire".
type: rule
applies-to: cierre de cada feature/sub-feature en discusiones de scope · decisiones encadenadas
---

## Overview

> **Al cerrar una feature o sub-feature en discusión iterativa, hacer un repaso sintético antes de pasar a la siguiente.**

**Por qué firme:** asegura alineación antes de avanzar (el user confirma que entendí bien) · genera resumen útil para construir la lista consolidada al cerrar el bloque · evita que decisiones queden "en el aire" sin documentar · si algo está mal, se corrige antes de seguir construyendo encima. Cita textual del user (upstream): *"Al cerrar una feature/subfeature, repasamos cómo quedó, antes de pasar a la siguiente."*

## When

**Aplica a:**

- Cada sub-feature cerrada dentro de un bloque de discusión.
- Cada feature entera al cierre de todas sus sub-decisiones.
- Cualquier decisión multi-nivel encadenada (feature → sub-feature → micro-decisión).

**NO aplica a:**

- Decisiones unitarias triviales (1 toggle · 1 texto).
- Implementación dentro de un PRP aprobado (las decisiones ya están firmadas).

## Process

**Estructura del repaso (formato canónico):**

```text
✅ FEATURE/SUB-FEATURE: [nombre]

Decisión core:
   [qué se decidió hacer]

Modelo / approach:
   [cómo se va a implementar]

Incluye en MVP:
   - [item 1]
   - [item 2]

NO incluye (V1.5+ o nunca):
   - [item descartado] — razón: [...]

Notas técnicas relevantes:
   - [si hay algo que recordar para el modelo de datos / UI]

¿OK para pasar a la siguiente?
```

**Reglas operativas:**

- En cada sub-feature: presentar opciones → user decide → **HACER REPASO** → pasar a la siguiente.
- Si la sub-feature es muy chica (1-2 decisiones), el repaso puede ser corto.
- Si la sub-feature es compleja (varias micro-decisiones encadenadas), el repaso es más completo.
- Al cerrar una FEATURE entera (ej: 1.1 · 1.2 · etc), hacer repaso consolidado de TODAS sus sub-decisiones.
- **Claridad sobre creatividad** · usar este formato · NO improvisar otro.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El user confirmó cada sub-decisión · no hace falta repaso · sigamos" | NO. El repaso NO es para reconfirmar — es para sintetizar y permitirle ver el conjunto. El user puede haber dicho OK a cada sub-decisión sin haber visto el todo. La síntesis atrapa contradicciones. |
| "El repaso es repetitivo · ya está todo en mis mensajes" | NO. La diferencia entre "está en mis mensajes" y "está repasado en bloque" es crítica · el user no va a re-leer 12 mensajes para confirmar coherencia · el repaso de 10 líneas le permite ver el todo en 30 segundos. |

## Red flags

- 🚩 Cerraste una feature y pasaste a la siguiente sin repaso.
- 🚩 El repaso omite "NO incluye" — eso pierde la decisión de descarte.
- 🚩 El repaso no menciona complejidad estimada (regla [`complejidad.md`](./complejidad.md)).
- 🚩 El repaso es texto libre · no usa el formato canónico · pierde estructura.

## Verification

- [ ] Después de cada sub-feature cerrada, repaso emitido con formato canónico antes de avanzar.
- [ ] El repaso incluye Decisión core / Modelo / Incluye MVP / NO incluye / Notas técnicas / pregunta final.
- [ ] Si la sub-feature es compleja, repaso completo · si es chica, repaso corto pero presente.
- [ ] Al cerrar la feature entera, repaso consolidado de todas las sub-decisiones.

**Cross-reference firme:**

- Hermana directa: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (lista consolidada al cerrar bloque · repaso es el paso intermedio entre sub-decisión y lista final).
- Refuerza: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (la doc no se pospone · repaso es la doc en tiempo real).
