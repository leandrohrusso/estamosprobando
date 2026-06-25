---
name: heuristica-referente-mercado
description: Cuando hay duda de diseño, feature, comportamiento o arquitectura, mirar primero cómo lo hace el referente del rubro · copiar approach en versión simplificada · diferencial es la simpleza vs la complejidad acumulada del referente.
type: rule
applies-to: decisiones de diseño · features · arquitectura · UX · comportamiento del producto
---

## Overview

> **Cuando haya una duda de diseño, feature, comportamiento o arquitectura, mirar cómo lo hace el referente del mercado primero. Si el referente lo hace así, es por algo — copiar el approach pero en versión simplificada.**

**Por qué firme:** el referente del mercado opera a escala (típicamente 100x+ que el proyecto nuevo) · sus decisiones agregadas suelen tener razón empírica detrás · ignorarlas es bias del implementador *"yo lo haría distinto"* sin anchor en lo que funciona. La heurística NO dice "copiar todo": dice "mirar primero · entender por qué · y después decidir si copiar tal cual, simplificar, o desviarse con justificación".

**Cómo identificar el referente del mercado del proyecto:**

- Producto SaaS líder en el mismo dominio funcional con mayor adopción comprobada.
- Competidor directo con escala mayor cuya UX y feature-set son referencia para los compradores potenciales.
- Si hay 2-3 referentes plausibles, elegir el que tu propio producto compite más de cerca por mercado.

## When

**Aplica a:**

- Decisiones de UX (formularios · listados · cards · navegación · flows).
- Decisiones de feature (qué entra · qué se omite · qué se simplifica).
- Decisiones arquitectónicas del producto (multi-tenancy · pagos · roles · permisos).
- Cualquier *"no sé cómo encarar esto"* antes de inventar.

**NO aplica a:**

- Decisiones técnicas del stack (framework · BD · estilos) — el stack se decide por criterios técnicos, no por mimicry.
- Decisiones del flujo de trabajo del agente (esas viven en `.claude/rules/` y son específicas del proyecto, no del producto).

## Process

**Cómo aplicar la heurística (5 preguntas):**

| # | Pregunta | Acción |
|---|---|---|
| 1 | ¿Esta feature existe en el referente del mercado? | Buscar evidencia (screenshots · docs · onboarding del referente) antes de inventar. |
| 2 | ¿Cómo la implementa? | Replicar la lógica core, NO la complejidad accesoria. |
| 3 | ¿La necesitamos en MVP? | Solo si es indispensable o deseable — el resto se difiere a versiones posteriores. |
| 4 | ¿La copiamos tal cual? | NO — versión simplificada: menos opciones visibles, UX más limpia, defaults sensatos. |
| 5 | ¿El referente tiene mil cosas en pantalla? | Sí, justamente — nosotros mostramos solo lo que el usuario necesita. |

**Excepciones — cuándo NO copiar al referente:**

- Cuando el founder/owner tiene experiencia directa que contradice al referente (ej: el referente omite X pero el founder sabe que los usuarios de su nicho lo valoran).
- Cuando la decisión del referente responde a su escala (multi-país · multi-procesador · multi-currency) y tu proyecto opera en un scope más acotado.
- Cuando el lema *"menos es más"* lo descarta: si el referente tiene una feature que confunde o sobra, no la copiamos.
- Cuando hay un detalle UX que el referente hace mal y vos lo detectaste.

**Combinación con la regla "feature por feature" ([`decisiones-features.md`](./decisiones-features.md)):**

1. Vemos una feature posible para el MVP.
2. ¿Está en el "70% común" del rubro?
3. ¿Cómo la hace el referente? (consultar evidencia).
4. ¿Qué versión simplificada tiene sentido?
5. Decisión conjunta con el user (regla: él elige · yo recomiendo).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Tengo una idea mejor que el referente · innovamos directo" | NO. La regla es referente primero · innovación después. Si el referente lo hace de cierta manera y vos pensás otra, primero documentar el tradeoff · después decidir. La innovación sin anchor en lo que funciona es bias del implementador. |
| "El referente tiene la feature pero compleja · la dejo afuera del MVP por simpleza" | OK pero documentar la desviación. *"Por simpleza"* no es justificación suficiente · hay que decir "el referente lo tiene · nosotros lo posponemos a v1.5 porque [razón]". El descarte ciego pierde info útil. |
| "No tenemos un referente claro · improviso" | NO. Si genuinamente no hay referente directo, ampliar a referentes adyacentes (rubros vecinos con UX similar) antes de inventar desde cero. La heurística es buscar anchor en lo que funciona, no en quién es el competidor exacto. |

## Red flags

- 🚩 Estás proponiendo una solución y NO mencionaste cómo lo hace el referente primero.
- 🚩 Estás copiando la complejidad accesoria del referente (5 sub-secciones · 20 toggles) en lugar de la versión simplificada.
- 🚩 Una decisión de UX se cerró sin haber consultado el referente del rubro.
- 🚩 La feature replica al referente tal cual · sin diferencial percibido (más simple · más limpio · más cercano).

## Verification

- [ ] Cada decisión de feature/diseño/UX tiene anchor explícito a *"cómo lo hace el referente"* o *"no documentado / sin referente claro"*.
- [ ] Versión simplificada elegida (menos opciones · UX más limpia · defaults sensatos) cuando aplica.
- [ ] Desviaciones del referente documentadas con justificación (escala · experiencia user · lema *"menos es más"*).
- [ ] El diferencial percibido (más simple · más limpio · más personal) está presente en el resultado.

**Cross-reference firme:**

- Hermana operativa: [`decisiones-features.md`](./decisiones-features.md) · [`metodologia-iteracion.md`](./metodologia-iteracion.md) (formato de presentación incluye *"cómo lo hace el referente"*).
- Refuerza: [`simplicity-first.md`](./simplicity-first.md) (versión simplificada · menos es más).
