---
name: surgical-changes
description: Todo diff debe trazarse al request · cero drive-by refactoring · cero "mejoras" no pedidas
type: rule
source: .claude/references/external-doctrine/karpathy-claude-md.md
applies-to: cualquier modificación de código durante /implementar, /validar, refactors solicitados, edits Modo A
---

## Overview

> **Todo diff debe trazarse al request.** Si una línea cambió y no estaba pedida, hay que justificarla en 1 frase o revertirla.

**Por qué esta regla existe:** drive-by refactoring durante `/implementar` o auditoría estructural genera bugs colaterales, infla diffs y dificulta el review. En auto-blindaje activo, el agente se siente tentado a "limpiar" — esa tentación es el anti-pattern. Integrado de [Karpathy guidelines](https://x.com/karpathy/status/2015883857489522876) — snapshot fuente en [.claude/references/external-doctrine/karpathy-claude-md.md](../references/external-doctrine/karpathy-claude-md.md). Cuando tu proyecto detecte ejemplos concretos de drive-by encubierto, codificarlos como memoria en `.claude/memory/feedback/surgical-changes.md` (vacío al boot del pack).

## When

**Aplica a:**

- Modificaciones de código durante `/implementar` (paso 3 del Modo C).
- Fixes durante `/validar` (paso 5).
- Refactors solicitados explícitamente.
- Edits puntuales en Modo A.

**Excepción 1 — bugs genuinos en archivos del scope:** bugs detectados en archivos del scope del PRP en curso (typos, bugs latentes) sí se fixean, documentándolos en sección "Aprendizajes" del PRP.

**Excepción 2 — deuda técnica con scope explícito:** si el archivo que tocás por el request actual tiene una fila activa en [docs/logs/technical-debt.md](../../docs/logs/technical-debt.md), el agente DEBE mencionar la DT al usuario al inicio del PRP/turno y preguntar si se incorpora al scope. Si el user dice **sí** → la DT entra al scope, se cierra siguiendo Regla B (mover a "Resueltas" en el mismo commit). Si dice **no** → no se toca código relacionado.

## Process

**Reglas operativas:**

1. **No "mejorar" código adyacente, comentarios, formatting o imports** que no requiera el request.
2. **No refactorear lo que no está roto**, aunque vos lo harías distinto.
3. **Matchear estilo existente del archivo** (quotes, indent, naming) — incluso si vos usás otro.
4. **Si notás dead code no relacionado** → mencionarlo al usuario, NO borrarlo en silencio.
5. **Si tu cambio dejó imports/vars/funciones huérfanos** → SÍ removerlos. Limpiá tu propio mess, no el ajeno.

**Test antes del commit:**

> Leé el diff completo. Para cada línea cambiada, preguntate "¿de qué línea del request viene esto?". Si no podés justificarla en 1 frase → revertila.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Aprovecho que estoy en este archivo y arreglo el comment desactualizado de la línea 34" | NO. Si no era parte del request, no se toca. Mencionalo al user al cierre, no a hurtadillas en el diff. La "limpieza colateral" se acumula sin review explícito y es donde nacen las regresiones. |
| "El estilo del archivo es viejo, lo modernizo de paso" | NO. Matchear estilo del archivo destino, incluso si vos lo escribirías diferente. La modernización es un PRP propio con su propio scope y testing. |

## Red flags

- 🚩 El diff incluye reformatting (cambios de indent o quotes) en líneas que no eran del request.
- 🚩 Estás "limpiando" imports muertos en código ajeno mientras tocás otra parte del archivo.
- 🚩 Encontraste una variable mejor nombrada y la renombrás "ya que estoy".
- 🚩 El PR tiene 200+ líneas cambiadas pero la feature pedía un cambio de 30.

## Verification

- [ ] Para cada línea del diff, podés justificarla en 1 frase trazable al request.
- [ ] Imports/vars/funciones removidos pertenecen a código que tu cambio dejó huérfano (no a código ajeno).
- [ ] Si encontraste deuda técnica en el archivo: mencionada al user (no removida silenciosamente) o ingresada al scope con OK explícito.
- [ ] El estilo (quotes, indent, naming) del diff matchea el resto del archivo.

**Cross-reference firme:**

- Hermana operativa: [`register-out-of-scope-as-dt.md`](./register-out-of-scope-as-dt.md) (cualquier hallazgo out-of-scope detectado durante un edit quirúrgico · DT en el acto · NO removerlo silenciosamente · cero drive-by encubierto).
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · cero modificación de agentes universales que no son domain-tight · scope quirúrgico del mecanismo · `surgical-changes` rebate la excusa "modifico un agente universal para que también lea el config · uniformidad").
- Hermana Karpathy: [`think-before-coding.md`](./think-before-coding.md) · [`simplicity-first.md`](./simplicity-first.md) · [`goal-driven-execution.md`](./goal-driven-execution.md). Las 4 reglas Karpathy se refuerzan mutuamente.
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye trazabilidad del diff al request).
- Memoria asociada (cuando tu proyecto la genere): `feedback/surgical-changes.md` con ejemplos concretos del repo adaptados de Karpathy · vacío al boot del pack.
