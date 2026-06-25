---
name: goal-driven-execution
description: Definir criterios de éxito verificables ANTES de implementar. Tareas vagas se transforman en goals con check binario (test que reproduce el bug · test que pasa post-fix).
type: rule
source: .claude/references/external-doctrine/karpathy-claude-md.md
applies-to: cualquier tarea de implementación con scope ≥1 fase · fixes de bugs · refactors solicitados
---

## Overview

> **Definir criterios de éxito. Loop hasta verificarlo.**

**Por qué firme:** sin criterio de éxito verificable, el agente entra en loop subjetivo ("creo que ya está / probemos a ver"). Con criterio binario (test rojo pre-fix · test verde post-fix), el cierre es objetivo y el progreso es visible. Karpathy P7 codifica la heurística: **transformar tareas vagas en goals verificables** · escribir test que reproduce ANTES de fixear · planificar steps con check explícito por step.

**Origen:** principio P7 de [.claude/references/external-doctrine/karpathy-claude-md.md](../references/external-doctrine/karpathy-claude-md.md) § 4 *"Goal-Driven Execution"*. Ejemplos antes/después en [.claude/references/external-doctrine/karpathy-examples.md](../references/external-doctrine/karpathy-examples.md) § 4.

## When

**Aplica a:**

- Fixes de bugs (regression-first FIRME aplica · ver [`regression-first-on-fix.md`](./regression-first-on-fix.md)).
- Tareas multi-step (más de 1 fase del bucle agéntico · más de 1 archivo modificado con lógica no trivial).
- Refactors solicitados (criterio: tests existentes verdes pre-refactor · verdes post-refactor).
- Validaciones del CSV paso 5 cuando una fila falla.

**NO aplica a:**

- Tareas mecánicas triviales (rename · `git mv` · adopciones livianas) — el criterio es typecheck verde y suficiente.
- Reads / exploraciones (no hay "éxito" que medir).

## Process

**Transformar tareas vagas en goals verificables:**

| Vago | Verificable |
|---|---|
| "Agregá validación" | "Escribir test con inputs inválidos · luego hacer que pase" |
| "Fixeá el bug" | "Escribir test que reproduce el bug · luego hacer que pase" |
| "Refactoreá X" | "Asegurar que tests pasan antes Y después del refactor" |
| "Hacé el endpoint" | "Test E2E: navegar a `/v/<short>` con recurso válido → ver pantalla de detalle. Test SQL: short con char inválido → 404" |

**Para tareas multi-step, escribir plan corto:**

```text
1. [Step] → verify: [check binario]
2. [Step] → verify: [check binario]
3. [Step] → verify: [check binario]
```

**Criterio fuerte vs débil:**

- ✅ **Fuerte:** *"Test reproduce el bug · fix lo cierra · no hay regresión en tests heredados"* — permite loop independiente, agente sabe cuándo terminó.
- ❌ **Débil:** *"Hacelo andar"* / *"Que funcione bien"* — requiere clarificación constante con el user, agente no sabe cuándo cerrar.

**Ejemplo ilustrativo (adaptado de Karpathy EXAMPLES § 4 · escenario en dominio ticketing · adaptá a tu dominio):**

**User Request:** *"El scanner staff falla cuando el ticket es de un combo cancelado parcialmente."*

**❌ Anti-pattern (vago):**

```text
Voy a fixear el scanner:
1. Reviso el código del scanner.
2. Identifico el problema.
3. Hago mejoras.
4. Pruebo.
[Procede a editar sin criterio claro · pega 200 LoC distribuidos · no sabe cuándo terminó]
```

**✅ Lo que debería pasar:**

```text
Para "fixear el scanner staff con combo cancelado parcial" necesito criterio claro.

Plan:
1. Escribir spec E2E: orden con combo · cancelar 1 hijo · scanear ticket del hijo cancelado
   Verify: spec falla (reproduce el bug · scanner deja entrar al hijo cancelado)

2. Implementar: scanner consulta `tickets.is_cancelled` antes de marcar como `redeemed`
   Verify: spec del paso 1 pasa

3. Verificar regresión: specs heredados de scanner (paso 3 pre-validación inherited regression)
   Verify: tests/e2e/regression/prp-008-staff-scanner.spec.ts sigue verde

4. Ver edge case: combo donde TODOS los hijos están cancelados pero el ticket-padre no
   Verify: spec adicional pasa

Cada step tiene check binario y es independientemente verificable.
¿Arrancamos con el step 1?
```

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es obvio cuándo terminé · no necesito criterio explícito" | NO. "Obvio" es subjetivo · loop no termina hasta que tenés un check binario. Mejor 5 minutos escribiendo el criterio que 30 minutos en loop "creo que ya". |
| "Escribir test antes del fix duplica trabajo" | NO. Es la mitad del fix · y queda en `tests/e2e/regression/` o `tests/sql/` para garantizar que el bug NO vuelve. Sin test antes, el "fix" puede no estar fixeando lo que pensabas. Ver [`regression-first-on-fix.md`](./regression-first-on-fix.md). |

## Red flags

- 🚩 Tu plan es *"reviso · identifico · mejoro · pruebo"* sin check binario por step.
- 🚩 Estás escribiendo código sin haber definido qué test confirma el éxito.
- 🚩 Hace 30+ min que estás en "creo que ya está / probá a ver" sin criterio objetivo.
- 🚩 El bug fix no tiene spec en `tests/e2e/regression/` o `tests/sql/` que reproduzca pre-fix.

## Verification

- [ ] Antes del primer Edit del fix / refactor, plan con check binario por step escrito.
- [ ] Para fixes: spec PRINCIPIO 6 (regression-first) escrito · falla pre-fix · pasa post-fix.
- [ ] Para multi-step: cada step listado tiene `verify:` con check binario.
- [ ] Cierre objetivo: typecheck + build verde + spec aplicado verde · no "creo que ya".

**Cross-reference firme:**

- Hermana Karpathy: [`think-before-coding.md`](./think-before-coding.md) · [`simplicity-first.md`](./simplicity-first.md) · [`surgical-changes.md`](./surgical-changes.md).
- Refuerza: [`regression-first-on-fix.md`](./regression-first-on-fix.md) · [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md).
