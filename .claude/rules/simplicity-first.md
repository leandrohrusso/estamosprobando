---
name: simplicity-first
description: Mínimo código que resuelve el problema. Sin features especulativas · sin abstracciones para uso único · sin "flexibilidad" no pedida.
type: rule
source: .claude/references/external-doctrine/karpathy-claude-md.md
applies-to: cualquier acción de codeo nueva (Server Actions · helpers · services · RPCs · components)
---

## Overview

> **Mínimo código que resuelve el problema. Nada especulativo.**

**Por qué firme:** la causa #1 de deuda técnica en proyectos LLM-asisted es la abstracción prematura. Strategy pattern para 1 caso de uso. Configuración para 1 valor. Validación para escenarios imposibles. El código "diseñado para el futuro" se acumula sin nunca usarse y vuelve cada modificación más cara. Karpathy P5 codifica el anti-pattern: **escribir lo mínimo · agregar complejidad solo cuando hay caller real**.

**Origen:** principio P5 de [.claude/references/external-doctrine/karpathy-claude-md.md](../references/external-doctrine/karpathy-claude-md.md) § 2 *"Simplicity First"*. Ejemplos antes/después en [.claude/references/external-doctrine/karpathy-examples.md](../references/external-doctrine/karpathy-examples.md) § 2.

## When

**Aplica a:**

- Helpers nuevos en `src/lib/`.
- Server Actions / Route Handlers nuevos.
- RPCs nuevas en `db/migrations/`.
- Components React nuevos (reusables · de feature · de listado).
- Cualquier abstracción (interface · type · class · context · provider) sin caller real declarado.

**NO aplica a:**

- Cuando el PRP aprobado **explicita** la abstracción como parte del scope (ej: refactor de helpers compartidos `<helperA>/<helperB>` en DT-NNN fue justificado por hydration mismatch · NO por especulación · adaptá a tu dominio).
- Patrones existentes ya consolidados (`ListadoStandard<T>` · `FormSection` · `Toggle`) — reusarlos NO es over-abstraction.
- **Tests del DoD por fase.** Los tests codificados que cierra cada fase del bucle (regla hermana [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) · 2-5 specs por fase típica) NO cuentan como sobre-complejidad. `simplicity-first` aplica al **código de producción** · NO al código de tests. La cobertura del DoD es obligatoria · `simplicity-first` NO es excusa para skipearla.

## Process

**Reglas operativas:**

1. **Sin features beyond del request.** Si el user pidió "guardar preferencia", guardar preferencia · no agregar `merge` opt · `validate` opt · `notify` opt.
2. **Sin abstracciones para 1 caller.** Helper compartido cuando ≥2 callers lo consumen · NO antes.
3. **Sin "flexibilidad" no pedida.** Configurabilidad sin caller que la consuma = código muerto disfrazado.
4. **Sin error handling para escenarios imposibles.** Trust framework guarantees y boundary checks (ver § Doing tasks de CLAUDE.md).
5. **Test del senior:** *"¿Un senior diría que esto está overcomplicado?"* Si SÍ → simplificá.
6. **Test 200→50:** *"Si escribí 200 LoC y podía ser 50, reescribilo."*

**Ejemplo ilustrativo (adaptado de Karpathy EXAMPLES § 2 · escenario en dominio ticketing · adaptá a tu dominio):**

**User Request:** *"Agregá una función para calcular el recargo del owner sobre un subtotal."*

**❌ Anti-pattern (over-abstraction):**

```ts
// 6 archivos · 200 LoC para calcular un porcentaje
abstract class SurchargeCalculator {
  abstract calculate(amount: number): number
}
class PercentageSurchargeCalculator extends SurchargeCalculator { /* ... */ }
class FixedSurchargeCalculator extends SurchargeCalculator { /* ... */ }
interface SurchargeConfig { strategy: SurchargeCalculator; minAmount: number; maxSurcharge: number }
class SurchargeManager { constructor(private config: SurchargeConfig) {} apply(amount: number): number { /* ... */ } }
// + factory + DI container + types + tests para cada branch
```

**✅ Simple:**

```ts
// path de ejemplo · adaptá al naming de tu dominio
// src/lib/<entity>/surcharge.ts
export function computeOwnerSurcharge(subtotal: number, surchargePercent: number): number {
  return Math.round(subtotal * (surchargePercent / 100))
}
```

**Cuándo agregar complejidad:** cuando aparece un caller real que necesita 2+ estrategias (`fixed` + `percentage`) · NO antes. Si llega ese requirement, refactor allá. Mientras tanto: 3 LoC.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "La abstracción ahora me ahorra refactor cuando llegue el caso 2" | NO. El caso 2 puede no llegar nunca · y si llega, el shape de la abstracción que adivinaste hoy probablemente NO encaja con lo que pide. Refactor cuando hay caller real es siempre más barato que abstraer en el aire. |
| "Agregué `validate` opt y `notify` opt para defensa-en-profundidad" | NO. Defensa-en-profundidad es "validar input en boundaries" · NO es "agregar 4 flags opcionales sin caller". Las flags sin caller son código muerto disfrazado de flexibilidad. |

## Red flags

- 🚩 Estás creando una `interface` o `abstract class` con 1 sola implementación.
- 🚩 La función nueva tiene 5+ parámetros opcionales (`merge`, `validate`, `notify`, `cache`, `strict`).
- 🚩 Escribiste 200 LoC y la sensación es "esto podía ser 50".
- 🚩 El helper que creaste no tiene caller real (lo escribiste "por si llega").
- 🚩 Tests del helper cubren branches que ningún caller dispara.

## Verification

- [ ] Cada helper / abstracción nueva tiene ≥1 caller real declarado en el commit.
- [ ] Cero parámetros opcionales que ningún caller usa.
- [ ] Cero clases abstractas / interfaces con 1 implementación.
- [ ] Cero error handling para escenarios que el framework ya garantiza (ej: revalidatePath nunca falla con path estático válido).
- [ ] Test del senior aplicado al diff antes del commit · "¿está overcomplicado?".

**Cross-reference firme:**

- Hermana Karpathy: [`think-before-coding.md`](./think-before-coding.md) · [`surgical-changes.md`](./surgical-changes.md) · [`goal-driven-execution.md`](./goal-driven-execution.md).
- Hermana operativa: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (tests del DoD por fase están FUERA del scope de "mínimo código" · `simplicity-first` cubre código de producción · cero excusa para skip tests).
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · scope mínimo viable del config · solo 3 flags para los 3 agentes domain-tight existentes · cero abstracción especulativa · `simplicity-first` rebate la excusa "agrego flag genérico catch-all más flexible").
- Refuerza: [`surgical-changes.md`](./surgical-changes.md) (no inflar diff con abstracciones no pedidas).
