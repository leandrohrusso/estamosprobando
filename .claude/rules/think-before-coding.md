---
name: think-before-coding
description: No asumir · no esconder confusión · explicitar tradeoffs antes de escribir código. Si hay múltiples interpretaciones, listar y preguntar.
type: rule
source: .claude/references/external-doctrine/karpathy-claude-md.md
applies-to: cualquier request del user que tenga ambigüedad real (scope · formato · campos · volumen · interpretación)
---

## Overview

> **No asumir. No esconder confusión. Explicitar tradeoffs.**

**Por qué firme:** la causa #1 de re-trabajo en agentes LLM es asumir intenciones del user que nunca dijo. El agente "pica" silenciosamente y entrega código que pegó al lado del request — el user descubre la asunción cuando ya hay código escrito y la corrección cuesta más que la pregunta original. Karpathy P4 codifica el anti-pattern: **antes de implementar**, listar asunciones, preguntar si hay duda, presentar interpretaciones múltiples si existen.

**Origen:** principio P4 de [.claude/references/external-doctrine/karpathy-claude-md.md](../references/external-doctrine/karpathy-claude-md.md) § 1 *"Think Before Coding"*. Ejemplos antes/después en [.claude/references/external-doctrine/karpathy-examples.md](../references/external-doctrine/karpathy-examples.md) § 1.

## When

**Aplica a:**

- Request con ambigüedad real de scope (ej: *"agregá feature X"* sin filtros · multi-tenancy · roles · privacy).
- Request con interpretaciones múltiples (ej: *"hacelo más rápido"* — ¿latency · throughput · UX?).
- Request donde el resultado depende de un dato no provisto (formato de archivo · campos · volumen).
- Cualquier acción ≥30 LoC nueva que no esté cubierta por un PRP aprobado.

**NO aplica a:**

- Tareas triviales (rename · typo · 1 línea de comment).
- Acciones cubiertas explícitamente por un PRP aprobado con bifurcaciones firmadas (Modo C).
- Adopciones livianas sin grados de libertad (ej: aplicar patrón ya documentado).

## Process

**Antes de implementar:**

1. **Listar asunciones explícitas.** Si el request omite scope · formato · campos · volumen · roles · multi-tenancy, escribir 1 línea por asunción al user.
2. **Si hay múltiples interpretaciones, presentarlas.** No elegir solo. Mostrar 2-4 interpretaciones con tradeoff 1-frase y recomendación early.
3. **Si existe approach más simple, decirlo.** Push back con justificación cuando el request implica complejidad innecesaria.
4. **Si algo no está claro, parar.** Nombrar exactamente qué genera confusión y preguntar — no improvisar.

**Ejemplo ilustrativo (adaptado de Karpathy EXAMPLES § 1 · escenario en dominio ticketing · adaptá a tu dominio):**

**User Request:** *"Agregá una feature para exportar las órdenes de un evento."*

**❌ Anti-pattern (asunciones silenciosas):**

```ts
// Server Action que exporta TODAS las órdenes a CSV con campos elegidos a dedo
export async function exportOrders(eventId: string) {
  const supabase = await createClient()
  const { data: orders } = await supabase
    .from('orders').select('id, buyer_email, total_paid, status').eq('event_id', eventId)
  // ... genera CSV en memoria · descarga directa · todos los campos · sin paginación
}
```

**Problemas:** asumió scope (todas vs filtradas) · asumió formato (CSV vs JSON vs Excel) · asumió campos (¿exponer `buyer_email`? PII) · asumió volumen (¿100 órdenes o 100k?).

**✅ Lo que debería pasar:**

> Antes de implementar necesito aclarar:
>
> 1. **Scope:** ¿Todas las órdenes del evento o filtrar por estado/fecha? Cuidado con PII si exportamos todas.
> 2. **Formato:** ¿CSV descarga directa, JSON via endpoint, o Excel con totales por función?
> 3. **Campos:** ¿`buyer_email` y `buyer_dni` van? (RLS no aplica a este flujo · es decisión de privacy).
> 4. **Volumen:** ¿Cuántas órdenes por evento típico? Afecta si va sync (Server Action) o async (background job + Resend).
>
> Lo más simple: endpoint server-side que retorna JSON paginado con campos no-PII. Si necesitamos CSV con PII, agregamos exportar audit log + permission check de role `producer:owner`.
>
> ¿Qué preferís?

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es obvio lo que el user quiere · evito el round-trip" | NO. Lo "obvio" es donde nacen las asunciones equivocadas. El round-trip de la pregunta cuesta minutos · re-hacer código pega 30+ min. Listar 2-3 asunciones explícitas + recomendación early NO es lentitud · es velocidad real. |
| "El user dijo X · si quería Y me lo decía" | NO. El user no sabe qué nivel de detalle necesitás. La regla es preguntar lo que TE FALTA antes de codear · no asumir que el silencio del user es luz verde para llenar gaps. |

## Red flags

- 🚩 Estás escribiendo código de ≥30 LoC sin haber listado asunciones al user.
- 🚩 El request tiene 2+ interpretaciones razonables y elegiste 1 silenciosamente.
- 🚩 Notás que un campo del schema podría ser PII y NO mencionaste el caveat al user antes de exponerlo.
- 🚩 El user pidió algo "más rápido / más fácil / mejor" y arrancaste a codear sin preguntar qué métrica importa.

## Verification

- [ ] Antes del primer Edit/Write, lista de asunciones presentada al user (cuando ≥1 ambigüedad real existe).
- [ ] Si había 2+ interpretaciones, las presentaste con tradeoff y recomendación early.
- [ ] Si existía approach más simple, lo mencionaste antes de implementar el complejo.
- [ ] Pregunta concreta hecha cuando algo no estaba claro — no improvisaste.

**Cross-reference firme:**

- Hermana operativa: [`simplicity-first.md`](./simplicity-first.md) · [`surgical-changes.md`](./surgical-changes.md) · [`goal-driven-execution.md`](./goal-driven-execution.md). Las 4 reglas Karpathy se refuerzan mutuamente.
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · al diseñar sub-agente nuevo del pack · listar asunciones del dominio · si una asunción NO es universal · el agente es domain-tight + aplica el mecanismo Pieza 1-4 · `think-before-coding` rebate la asunción silenciosa "todos los proyectos cumplen X").
- Refuerza: [`conversation-style.md`](./conversation-style.md) (cuando hay 2+ decisiones, presentar progresivamente).
