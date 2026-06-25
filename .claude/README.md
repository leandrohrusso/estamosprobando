# `.claude/` · Fábrica del agente Claude Code

> **Qué es:** carpeta canónica del agente Claude Code · path que el harness lee al boot. Aloja toda la "fábrica" del agente del proyecto: skills invocables del flujo · reglas firmes con shape P8 · sistema de memoria persistente (paradigma llm-wiki) · PRPs (Product Requirements Proposals) del producto · references externas · hooks · config declarativo del flujo · workspace gitignored para meta-work del template.
>
> **Por qué se creó:** convención del harness Claude Code (`.claude/` es el directorio que el agente lee al boot) + materialización del pack workflow-base (flujo de 6 pasos · 37 reglas firmes con shape P8 · 15 skills invocables · 4 carpetas de memoria + log cronológico + índice MEMORY.md cap 200 LoC).
>
> **Para qué sirve:** orquestar todo el trabajo del agente · cargar contexto al boot (memoria + reglas + estado del repo) · invocar skills del flujo de 6 pasos (`/arrancar` → `/planificar` → `/implementar` → `/revisar` → `/validar` → `/entregar`) + skills auxiliares (`/fatiga` · `/handoff` · `/documentar` · `/memory-manager` · etc) · preservar trazabilidad histórica (PRPs cerrados · memorias archivadas · etc).

## Convención

- **Reglas en `rules/`:** shape P8 obligatorio (Overview · When · Process · Anti-rationalization · Red flags · Verification) · [`CLAUDE.md`](../CLAUDE.md) indexa cada una con leyenda + link. Smoke test mecánico en CI valida shape + frontmatter (ver [`tests/scripts/infra-flujo/rules-shape-p8.sh`](../tests/scripts/infra-flujo/rules-shape-p8.sh)).
- **Skills en `skills/`:** `SKILL.md` por skill con frontmatter parseable (`name` + `description` + `allowed-tools`) + shape canónico de 6 H2. Cada skill autocontenido · invocable vía `/<skill>` desde el agente principal.
- **Memoria en `memory/`:** 4 sub-carpetas (`feedback/` · `project/` · `reference/` · `user/`) + [`MEMORY.md`](./memory/MEMORY.md) (índice cargado al boot · cap 200 LoC · líneas posteriores truncan) + [`log.md`](./memory/log.md) (cronología append-only · 6 tipos `<op>` · cero backfill).
- **PRPs en `PRPs/`:** documento por feature compleja (paso 2 del flujo · `/planificar`) · estados `PENDIENTE` → `APROBADO` → `EN PROGRESO` → `COMPLETADO` · obsoletos a [`PRPs/_archive/`](./PRPs/_archive/) con `git mv`.
- **Config declarativo en `config/`:** YAML parseable que alimenta skills multi-agente con flags del dominio (regla #35 [`agents-conditional-by-domain.md`](./rules/agents-conditional-by-domain.md)).

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`PRPs/`](./PRPs/) | Product Requirements Proposals del producto · 1 archivo por PRP · `_archive/` para obsoletos |
| [`_workspace/`](./_workspace/) | Workspace **gitignored** para meta-work del template (handoffs · drafts · scratchpads del template mismo) · NO aplica al proyecto adopter · ver [`_workspace/README.md`](./_workspace/README.md) § scope |
| [`config/`](./config/) | Config declarativo YAML que alimenta skills multi-agente con flags del dominio (`agents-applicability.yml` · regla #35) |
| [`hooks/`](./hooks/) | Hooks ejecutables del agente Claude Code (eventos `PreToolUse` · `PostToolUse` · etc) · NO confundir con [`.husky/`](../.husky/) (hooks de Git) |
| [`memory/`](./memory/) | Sistema de memoria persistente · 4 sub (`feedback/` · `project/` · `reference/` · `user/`) + `MEMORY.md` (índice) + `log.md` (chronology) + `_archive/` |
| [`references/`](./references/) | Reference checklists adoptadas (security · accessibility · performance · testing) consumidas como anchors por agentes de `/revisar` y `/revisar-main` |
| [`rules/`](./rules/) | 37 satélites de reglas FIRMES del flujo · shape P8 · indexadas en [`CLAUDE.md`](../CLAUDE.md) |
| [`skills/`](./skills/) | 15 skills invocables · 6 del flujo de 6 pasos + 2 variantes simples (paso 2 y 4) + 7 auxiliares (`/fatiga` · `/handoff` · `/documentar` · `/memory-manager` · `/auditar-dt` · `/revisar-main` · `/consultor`) |

> **Nota sobre `logs/`:** la subcarpeta `.claude/logs/` NO existe en el repo (gitignored) · se crea dinámicamente al primer run de un hook que escriba output runtime (ej: [`hooks/log-tool-usage.sh`](./hooks/log-tool-usage.sh) la crea con `mkdir -p`). Ver [`.gitignore`](../.gitignore) bloque correspondiente.

## Carpetas hermanas

- [`docs/`](../docs/) — documentación del producto · convención firme: `.claude/` = **cómo trabajamos** (flujo del agente · skills · reglas · memoria) · `docs/` = **qué construimos** (PRD · roadmap · references del producto · logs operativos como `technical-debt.md` y `ultrareview-log.md`).
- [`tests/`](../tests/) — suite de testing del proyecto (E2E · SQL · integration · scripts de smoke como [`tests/scripts/infra-flujo/`](../tests/scripts/infra-flujo/)).
- [`scripts/`](../scripts/) — infra del proyecto · CI local · lint de memoria · sync post-merge · etc.
- [`.husky/`](../.husky/) — hooks de **Git** (`pre-commit` · `pre-push` · `post-commit`) · canal distinto a `.claude/hooks/` que corre en eventos del agente.

## Punto de entrada

Al iniciar cualquier sesión del agente, el boot canónico es invocar el skill [`/arrancar`](./skills/arrancar/SKILL.md) (paso 1 · Contexto del flujo de 6 pasos): carga [`CLAUDE.md`](../CLAUDE.md) + [`BUSINESS_LOGIC.md`](../BUSINESS_LOGIC.md) + [`WORKFLOW.md`](../WORKFLOW.md) + memoria + estado del repo + propone próximo paso en formato Modo A/B/C.

## Reglas firmes asociadas

- [`folder-creation-with-readme.md`](./rules/folder-creation-with-readme.md) — regla #22 · este README materializa la convención.
- [`golden-rule-docs-memory.md`](./rules/golden-rule-docs-memory.md) — regla #18 · al cerrar PRP/fase/task · checklist 6 ítems · doc + memoria nunca se posponen.
- [`status-tracker-visible.md`](./rules/status-tracker-visible.md) — regla #25 · durante Modo C · tracker visible de los 6 pasos al inicio de cada respuesta principal.
- [`log-chronology-append-only.md`](./rules/log-chronology-append-only.md) — regla #20 · formato canónico de [`memory/log.md`](./memory/log.md).

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](./rules/folder-creation-with-readme.md)).*
