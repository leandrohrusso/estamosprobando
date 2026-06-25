---
name: complejidad
description: Complejidad permitida solo BAJA o MEDIA. Las features ALTA NO entran al alcance directamente · se evalúan con cuidado especial o se dividen.
type: rule
applies-to: planificación de features · scope de PRPs · evaluación de tareas del roadmap
---

## Overview

> **Para todo el desarrollo del producto, solo se admiten features de complejidad BAJA o MEDIA. Las features de complejidad ALTA NO entran al alcance directamente — se evalúan con atención y muchas veces se descartan o se postergan o se descomponen.**

**Por qué firme:** cada feature ALTA toma 3-5x más tiempo que una MEDIA. Un producto sólido se construye con features correctas hechas con calidad, no con features gigantes hechas a medias. Mejor lanzar con 30 features BAJA/MEDIA bien hechas que con 50 a medias.

## When

**Aplica a:**

- Planificación de cualquier feature nueva (PRPs · sub-decisiones · roadmap).
- Evaluación de scope al arrancar `/planificar`.
- Cualquier turno de discusión de features.
- Decisión de "incluir / postergar / descartar" en el roadmap.

**NO aplica a:**

- Refactors técnicos del flujo (medidos por riesgo · no por complejidad de feature).
- Trabajo de mantenimiento (deudas técnicas · fixes).

## Process

**Cómo evaluar complejidad:**

| Nivel | Modelo de datos | UI | Lógica | Tiempo estimado | Casos de borde | Ejemplos ilustrativos |
|---|---|---|---|---|---|---|
| **BAJA** | 1-2 tablas / campos nuevos | 1 pantalla simple · form plano | CRUD básico · sin reglas compuestas | < 1 día con Claude Code | Pocos · obvios | Banner del evento · redes sociales · descripción rich text · soft delete |
| **MEDIA** | 3-5 tablas con relaciones simples | 1-3 pantallas · components reusables | Reglas con override · cálculos derivados · jerarquía de datos | 1-3 días | Mapeables · manejables | Múltiples fechas/funciones · override de comisión por evento · duplicar evento · modo evento · eventos externos con link · AI mejorar descripción |
| **ALTA** (PROHIBIDA por default) | 6+ tablas · relaciones polimórficas · herencias | Múltiples pantallas con interacciones complejas · estados anidados | Reglas multi-nivel · sincronizaciones · integraciones complejas | > 3 días | Muchos · no obvios | Marketplace público con cartelera y SEO · generador de landings drag-and-drop · sistema de membresías recurrentes · motor de seat maps interactivo |

**Cuándo evaluar una feature ALTA con atención (las 4 preguntas):**

1. **¿Se puede simplificar a MEDIA?** Buscar versión reducida (ej: en vez de "drag-and-drop builder", usar "templates pre-armados").
2. **¿Es realmente esencial para el MVP?** Casi siempre la respuesta es NO.
3. **¿Se puede dividir en sub-features de complejidad media o baja?** Roadmap por fases (V1.5, V2).
4. **¿Hay forma de hacerlo manualmente al inicio?** Ej: programa de embajadores se opera manual al principio · sistema completo para V2.

**Cómo aplicar en cada turno de discusión de features:**

1. Estimar complejidad (BAJA / MEDIA / ALTA) explícitamente.
2. Si es ALTA, marcarla con ⚠️ y sugerir alternativa simplificada o postergar.
3. Si el user insiste en mantenerla, evaluar partir en sub-features.
4. Documentar la decisión en el PRP o memoria correspondiente.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es ALTA pero la necesitamos para diferenciarnos del competidor" | NO. La diferenciación viene de hacer 30 features BAJA/MEDIA bien · no de 1 feature ALTA "wow". Buscar la versión reducida o el path manual primero. Si genuinamente no hay alternativa, postergar a V1.5+. |
| "Estimé MEDIA pero en el bucle se infló a ALTA · sigo igual" | NO. Si el scope se infló durante el bucle, parar y re-evaluar. Mejor partir en 2 PRPs MEDIA secuenciales que mergear 1 PRP ALTA con calidad comprometida. |

## Red flags

- 🚩 Discusión de feature lleva >5 turnos sin estimación de complejidad explícita.
- 🚩 Feature estimada ALTA pasó al PRP sin haber respondido las 4 preguntas.
- 🚩 El PRP está en bucle agéntico y se descubre que la complejidad real es ALTA (re-evaluar split).
- 🚩 La memoria de la feature dice "compleja pero la necesitamos" — falta justificación contra las 4 preguntas.

## Verification

- [ ] Cada feature evaluada lleva tag de complejidad (BAJA / MEDIA / ALTA) en su lugar de discusión.
- [ ] Cero features ALTA pasaron a PRP aprobado sin las 4 preguntas respondidas.
- [ ] Si una feature ALTA terminó en el roadmap, hay registro de la justificación o del split en sub-features.
- [ ] Si durante el bucle el scope se infló, decisión documentada (continuar / partir / postergar).

**Cross-reference firme:**

- Hermana operativa: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (la estimación de complejidad BAJA/MEDIA/ALTA se presenta como tag en cada decisión iterativa · en lista consolidada al cerrar bloque).
- Hermana operativa: [`decisiones-features.md`](./decisiones-features.md) (cada feature se decide una por vez · esta regla cubre el criterio de scope · decisiones-features cubre el proceso de decisión).
- Refuerza: [`simplicity-first.md`](./simplicity-first.md) (mínimo código de producción · BAJA/MEDIA son los rangos compatibles con este flujo).
