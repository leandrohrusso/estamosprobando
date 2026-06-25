---
name: <patron-kebab-case>
description: <1 línea con el WHY del patrón · qué error/gotcha previene>
type: feedback
---

# <Título descriptivo · 1 línea>

> **Patrón detectado:** <YYYY-MM-DD> · sesión / PRP / commit hash de origen.
>
> **Aplica a:** <stack · contexto · cuándo se gatilla el patrón>.

## Incident concreto

<2-4 líneas describiendo el síntoma real observado · cómo se manifestó · qué se rompió · qué confundió al agente>.

```text
<bloque de código · output de error · query SQL · etc · cuando aplica>
```

## Root cause

<2-4 líneas explicando la causa profunda · por qué el síntoma aparece · qué supuesto del agente era equivocado>.

## Regla derivada

> **<Frase imperativa con la regla 1-línea>.**

<Ampliación: cómo aplicar la regla · cuándo no aplica · cómo verificar que se respeta>.

## Ejemplos del repo (cuando aplica)

- **Caso 1:** <archivo · línea · descripción del aplicar>.
- **Caso 2:** <ídem>.

## Cross-references

- **Reglas firmes asociadas:** [`.claude/rules/<regla>.md`](../../rules/<regla>.md) (cuando hay regla firme que cita este patrón).
- **Memorias hermanas:** [`<otro-patron>.md`](./<otro-patron>.md) (cuando comparten root cause o se complementan).
- **Skills que consultan esta memoria:** `/<skill>` (cuando aplica).

---

*Memoria creada <YYYY-MM-DD> · regla [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4.*
