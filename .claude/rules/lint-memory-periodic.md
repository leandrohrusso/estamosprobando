---
name: lint-memory-periodic
description: Lint mensual de .claude/memory/ con 6 criterios (contradicciones · stale claims · orphan files · conceptos sin página · cross-references rotos · data gaps PRP). Read-only · genera reporte + entrada log lint.
type: rule
source: .claude/references/external-doctrine/karpathy-llm-wiki-video.md
applies-to: mantenimiento periódico de la memoria del proyecto (.claude/memory/)
---

## Overview

> **Lint mensual de `.claude/memory/` con 6 criterios.** Read-only · NO modifica archivos · genera 1 reporte + 1 entrada `lint` en `.claude/memory/log.md`. El user decide caso por caso si fixear.

**Por qué firme:** la memoria persistente acumula deuda invisible si nadie la audita. Contradicciones entre dos memorias, claims que se volvieron stale, archivos huérfanos que no están en `MEMORY.md`, conceptos que merecen página propia, cross-references rotos por renames, PRPs cerrados sin aprendizajes documentados — todos comen valor a la memoria sin que se note. Refinamiento adoptado del video tutorial Karpathy llm-wiki donde explica la operación `lint` (ver [.claude/references/external-doctrine/karpathy-llm-wiki-video.md](../references/external-doctrine/karpathy-llm-wiki-video.md) líneas 38, 149-154 del snapshot · archivado post-PRP-NNN commit `<hash>`). Adaptado al proyecto con 6 criterios concretos.

## When

**Aplica a:**

- Cadencia mensual por default (1 vez por mes calendario).
- Trigger manual disponible (`/memory-manager lint` o equivalente · post-PRP-NNN).

**NO aplica a:**

- Memorias generadas durante una sesión activa (esas siguen el flujo normal de [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md)).
- Lint de código (eso va por ESLint/typecheck/build).

## Process

**Los 6 criterios del lint:**

| # | Criterio | Qué busca | Ejemplo ilustrativo |
|---|---|---|---|
| 1 | **Contradicciones** | 2+ memorias dicen cosas opuestas sobre el mismo tema (ej: una dice "siempre X" y otra dice "nunca X" sin contexto que justifique). | `feedback/rls-policies-public-shadowing.md` dice "policies `to public` con USING tabla sin GRANT a anon SOMBREAN policies anon" pero `feedback/rls-to-public-needs-grant-for-anon-policy.md` dice "policy `to public` con auth filter NO permite anon". Ambas verdaderas en distintos contextos · necesitan reconciliación o cross-reference explícito. |
| 2 | **Stale claims** | Memorias que afirman estado del repo o BD que ya no es cierto (TS dice X · BD tiene Y · convención dice Z) post-cambios recientes. | `feedback/middleware-host-aware-rewrites.md` decía "short URL `/[6chars]` colisionaba con `/events`" — fixeado en commit hace meses · sigue diciendo "colisiona" sin banner ✅ Resuelta. |
| 3 | **Orphan files** | Archivos en `.claude/memory/<carpeta>/` que NO están en `MEMORY.md` (índice) · si no se referencian desde el índice, el agente no los carga al boot · contenido invisible. | Archivo `feedback/orphan-example.md` existe físicamente pero no aparece en `MEMORY.md § feedback/`. Acción: (a) agregar al índice si aplica · (b) eliminar si es obsoleto · (c) marginar a `_archive/` si tiene valor histórico. |
| 4 | **Conceptos sin página propia** | Patrón / regla / decisión que aparece mencionada en 3+ memorias distintas pero NO tiene su propia página en `feedback/` o `reference/` · señal de que merece extracción a satélite dedicado. | Mención repetida del patrón "RLS SECURITY DEFINER vs INVOKER" en 3 memorias distintas · candidato a `reference/rls-security-definer-vs-invoker-decision-tree.md`. |
| 5 | **Cross-references rotos** | Link markdown `[text](path.md)` que apunta a archivo inexistente (movido · renombrado · archivado) · navegación rota desde el índice o entre memorias. | `MEMORY.md` referencia `[Pre-refactor baseline](reference/pre-refactor-baseline.md)` · si ese archivo no existe (untracked / borrado), es link roto. |
| 6 | **Data gaps PRP** | PRP cerrado COMPLETADO pero su sección "Aprendizajes / Self-Annealing" está vacía O las memorias nuevas que el PRP debió generar (CSV bugs · gotchas · decisiones) no aparecen en `MEMORY.md` · señal de que el cierre fue incompleto. | PRP-XXX cierra sin entrada en `log.md` formato `prp-close` · sin gotchas codificados como memorias nuevas · sin actualización del banner CLAUDE.md. Lint detecta el gap y lo reporta. |

**Cómo opera el lint (cadencia + output):**

- **Cadencia:** mensual por default · trigger manual disponible.
- **Modalidad:** read-only · NO modifica archivos · genera 1 reporte estructurado + 1 entrada `lint` en `.claude/memory/log.md` (formato canónico de [`log-chronology-append-only.md`](./log-chronology-append-only.md)).
- **Output del reporte:** lista por criterio (de los 6) con paths exactos + descripción 1-frase de cada hallazgo · rankeada por severidad (contradicciones > stale claims > cross-references rotos > data gaps > orphan files > conceptos sin página).
- **Acción del user:** decide caso por caso si fixear (ahora o postergar) · cada fix es un commit aparte con mensaje `lint(memory): <criterio> · <fix corto>`.

**Procedimiento operativo:**

1. Leer `MEMORY.md` (índice) y enumerar todos los archivos referenciados.
2. `find .claude/memory -type f -name "*.md" -not -path "*/_archive/*"` para listar archivos físicos.
3. Cruzar índice vs físico → criterio 3 (orphan files).
4. Para cada archivo `feedback/` y `reference/`: validar links markdown con `grep -oE "\[.*\]\([^)]*\.md\)"` + `test -f` cada path → criterio 5 (cross-references rotos).
5. Buscar mismo concepto/patrón en 3+ archivos distintos via `grep -l "<concepto>" feedback/*.md reference/*.md` → criterio 4 (conceptos sin página).
6. Para cada PRP marcado COMPLETADO en roadmap: verificar que existe entrada `prp-close` en `log.md` y sección Aprendizajes no vacía → criterio 6 (data gaps PRP).
7. Para criterios 1 (contradicciones) y 2 (stale claims): revisión semántica · requiere lectura contrastada · NO puramente mecánica.
8. Generar reporte estructurado · agregar entrada `lint` en `log.md` con resumen.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El lint modifica archivos automáticamente para arreglar lo que encuentra" | NO. Read-only es contractual · automatizar fixes sin OK del user introduce ruido y pérdida de contexto. El lint reporta · el user decide qué fixear y cuándo. |
| "No corro el lint hasta que sienta que la memoria está sucia" | NO. La cadencia mensual es disparador objetivo para evitar sesgo subjetivo. Si el user pospone el lint indefinidamente, la deuda invisible crece sin alarma. |

## Red flags

- 🚩 Lint corrió y generó fixes automáticos sin OK del user.
- 🚩 Pasó >1 mes desde el último lint y nadie lo disparó.
- 🚩 El reporte del lint NO se cerró con entrada `lint` en `log.md`.
- 🚩 El reporte tiene "0 hallazgos" — sospecha de criterios mal aplicados (la memoria real siempre tiene drift).

## Verification

- [ ] Lint corrió en cadencia mensual o por trigger manual del user.
- [ ] Reporte estructurado generado con 6 secciones (1 por criterio) + paths + severidad.
- [ ] Entrada `lint` agregada al final de `.claude/memory/log.md` (formato canónico).
- [ ] Cero modificación automática de archivos (verificable con `git status` post-lint).
- [ ] User decidió caso por caso qué fixear; cada fix queda en commit separado con mensaje `lint(memory): ...`.

**Cross-reference firme:**

- Hermana: [`log-chronology-append-only.md`](./log-chronology-append-only.md) (entrada `lint` sigue ese formato).
- Hermana operativa: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (la doc no se pospone · el lint atrapa los gaps que la golden-rule no detectó en tiempo real).
- Skill operativo: [`/memory-manager`](../skills/memory-manager/SKILL.md) sub-comando `lint` (ejecuta el lint mensual con los 6 criterios · output read-only · reporte estructurado + entry `lint` en `log.md` · user decide qué fixear caso por caso · paridad arquitectónica regla↔skill doctrine↔execution).

> **Stack de documentación · 3 reglas paralelas del ciclo doc/memoria.** Esta regla forma parte del bloque "documentación y memoria" junto a [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) y [`log-chronology-append-only.md`](./log-chronology-append-only.md). Roles complementarios sin solapamiento: (1) **golden-rule** = CUÁNDO documentar (sincrónica al cierre · bloqueante). (2) **lint-memory (esta)** = AUDITAR memoria periódicamente (asincrónica cadencia mensual · read-only · user decide qué fixear). (3) **log-chronology** = FORMATO canónico de la cronología (append-only · 6 tipos de evento). Las 3 severidades divergen legítimamente (bloqueante · preventiva · de integridad) porque protegen distintas capas del mismo stack.
