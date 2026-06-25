---
name: documentos-definitivos
description: Antes de generar documentos definitivos del proyecto (PRD · roadmap · plan 90 días · resumen ejecutivo), avisar al user y esperar confirmación explícita.
type: rule
applies-to: generación de PRD · roadmap consolidado · planes formales · resúmenes ejecutivos
---

## Overview

> **Antes de generar documentos "definitivos" del proyecto (PRD final · roadmap consolidado · plan 90 días / 6 meses formal · resumen ejecutivo · cualquier deliverable que sintetice múltiples decisiones), avisar al user y esperar confirmación explícita.**

**Por qué firme:** el user quiere terminar TODAS las decisiones del proyecto antes de consolidar documentos finales. Generar el PRD/roadmap antes de tiempo deja afuera decisiones que aún no se tomaron, o cristaliza versiones tempranas que después hay que reescribir. La memoria operativa (`.claude/memory/project/*.md`) es una cosa · el documento "deliverable" es otra · sólo el segundo requiere aviso.

## When

**Aplica a (generación requiere aviso + OK):**

- PRD final del producto.
- Roadmap consolidado.
- Documento de Plan 90 días / 6 meses formal.
- Resumen ejecutivo del proyecto.
- Cualquier "deliverable" que sintetice múltiples decisiones.

**Excepciones (NO requieren aviso · son operativos):**

- Archivos de memoria `.claude/memory/project/*.md` que se van creando turno a turno (operativos para no perder decisiones).
- Archivos `.claude/memory/feedback/*.md` y `reference/*.md` (memorias técnicas).
- Checkpoints y handoffs del refactor (`.claude/memory/project/<prp>-checkpoint.md`).
- PRPs individuales (`.claude/PRPs/*.md`) — esos siguen el flujo `/prp` o `/refactor planificar`.

## Process

**Procedimiento al generar un documento definitivo:**

1. Frenar antes de escribir.
2. Avisar al user textualmente: *"Estamos por consolidar [tipo de documento]. ¿Lo armo ahora o seguimos cerrando decisiones primero?"*
3. Esperar OK explícito.
4. Si el user dice SÍ → generar el documento.
5. Si el user dice "todavía no" → seguir trabajando decisiones · NO generar.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Tengo todas las decisiones · genero el PRD para confirmar todo junto" | NO. La regla es la inversa: confirmar TODAS las decisiones primero · generar el PRD después. La consolidación temprana cristaliza versiones que después hay que reescribir. |
| "Es solo un draft · si no le gusta lo cambiamos" | NO. El "draft" toma tiempo de generar y de leer · y crea expectativa de que el deliverable existe. El aviso de 1 frase + OK del user evita ese ciclo. |

## Red flags

- 🚩 Estás escribiendo un PRD/roadmap formal sin haber preguntado al user.
- 🚩 La sesión avanzó hacia consolidación sin firma explícita.
- 🚩 Generaste un resumen ejecutivo "preliminar" sin haberlo anunciado.

## Verification

- [ ] Antes de generar cualquier documento definitivo, aviso al user enviado.
- [ ] OK explícito del user recibido antes de generar.
- [ ] Memorias operativas (`project/*.md`) generadas sin aviso (son la excepción · OK).

**Cross-reference firme:**

- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (cuando dudás si el documento que vas a generar entra en la lista de "definitivos" · preguntar al user con formato canónico).
- Hermana operativa: [`decisiones-features.md`](./decisiones-features.md) (features se cierran una por una con el user · consolidar deliverables prematuramente cristaliza decisiones que aún no se firmaron).
- Hermana operativa: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (la lista consolidada se entrega al cierre del bloque · cuando el user pide *"tirá la lista final"* · cero deliverable definitivo antes).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye no precipitar deliverables que cristalicen versiones tempranas).
