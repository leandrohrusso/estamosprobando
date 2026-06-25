# `.claude/memory/` · Sistema de memoria persistente del proyecto

> **Qué es:** sistema de memoria por proyecto inspirado en el paradigma `llm-wiki` (Karpathy) · 4 sub-carpetas que organizan tipos distintos de conocimiento + `MEMORY.md` (índice cargado automáticamente al boot del agente) + `log.md` (cronología append-only) + `_archive/` (memorias desindexadas pero preservadas). Versionado en git · viaja con el repo · compartido con el equipo.
>
> **Por qué se creó:** el LLM no tiene memoria entre sesiones. Sin memoria persistente, el agente repite errores · pierde contexto de PRPs cerrados · no aprende de gotchas. Esta carpeta es el único canal donde el conocimiento sobrevive a la sesión y migra entre conversaciones.
>
> **Para qué sirve:** capturar correcciones del user (`feedback/`) · estado vivo de PRPs en curso (`project/`) · dónde encontrar info externa (`reference/`) · perfil del user (`user/`) · cronología trazable de decisiones/cierres/incidentes (`log.md`) · índice mecánico que el agente carga al boot (`MEMORY.md`).

## Convención

- **MEMORY.md:** índice cargado automáticamente al inicio · cap ~200 LoC · una línea por entry con descripción · paths a archivos .md de las sub-carpetas.
- **log.md:** chronology append-only · formato `## [YYYY-MM-DD] <op> | <título corto>` · 6 ops válidos (`prp-close` · `decision` · `incident` · `directional` · `milestone` · `lint`). Regla firme [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md).
- **Lint mensual:** `bash scripts/lint-memory.sh` con 6 criterios (contradicciones · stale claims · orphan files · cross-refs rotos · conceptos sin página · data gaps PRP). Regla firme [`lint-memory-periodic.md`](../rules/lint-memory-periodic.md).
- **Cero info ya capturada en código/git:** memoria es para conocimiento que NO sobrevive en `git log` ni en archivos del proyecto.
- **Templates canónicos:** cada sub-carpeta tiene un `_template.md` que el agente copia para crear entries nuevas.

## Subcarpetas

| Carpeta | Tipo de memoria | Cuándo se usa |
|---|---|---|
| [`feedback/`](./feedback/) | Anti-patterns · correcciones · gotchas universales | Cuando el user corrige al agente · cuando se descubre un patrón nuevo |
| [`project/`](./project/) | Estado vivo de PRPs en curso · checkpoints · handoffs · decisiones activas | Multi-sesión · cero pérdida entre conversaciones |
| [`reference/`](./reference/) | Punteros a recursos externos · dónde encontrar info | Linear · Slack · Grafana · docs externas relevantes |
| [`user/`](./user/) | Perfil del user (rol · stack · preferencias) | Para tailorizar comunicación al user |
| [`_archive/`](./_archive/) | Memorias archivadas (obsoletas · supersedidas) | Cuando lint mensual detecta stale + user firma archivar |

## Archivos en raíz

| Archivo | Rol |
|---|---|
| `MEMORY.md` | Índice cargado automáticamente al boot del agente · entradas con punteros a archivos de sub-carpetas |
| `log.md` | Cronología append-only · 6 ops válidos · entradas datadas |

## Carpetas hermanas

- [`.claude/skills/memory-manager/`](../skills/memory-manager/) — skill que opera sobre esta carpeta · 4 sub-comandos (`ingest` · `query` · `lint` · `bulk-ingest`).
- [`.claude/PRPs/`](../PRPs/) — los PRPs en estado EN PROGRESO tienen su checkpoint en `project/`.
- [`scripts/lint-memory.sh`](../../scripts/lint-memory.sh) — lint con 6 criterios.

## Reglas firmes asociadas

- [`golden-rule-docs-memory.md`](../rules/golden-rule-docs-memory.md) — al cerrar PRP · checklist 6 ítems incluye actualizar memoria.
- [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md) — formato canónico de log.md.
- [`lint-memory-periodic.md`](../rules/lint-memory-periodic.md) — lint mensual o trigger manual.
- [`session-handoff.md`](../rules/session-handoff.md) — handoffs entre sesiones van en `project/` con shape canónico de 7 secciones.

---

*Convención de README firmada 2026-05-20 (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
