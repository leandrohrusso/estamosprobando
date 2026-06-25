# `scripts/` · Infra de CI / lint / sync del proyecto

> **Qué es:** carpeta raíz de scripts bash ejecutables que orquestan CI local · lints determinísticos · sync de branches · pre-flights de skills. NO son tests del producto · NO son smoke tests de invariantes de la fábrica (esos viven en [`tests/scripts/`](../tests/scripts/)). Son infra operativa que el agente y el dev invocan directamente.
>
> **Por qué se creó:** convención Node/JS · raíz dedicada para scripts ejecutables que no van a `package.json` (porque son largos · multi-step · o requieren shebang). Algunos son referenciados desde `package.json` scripts y desde [`.github/workflows/ci.yml`](../.github/workflows/) · otros se invocan a mano en momentos específicos del flujo.
>
> **Para qué sirve:** garantizar paridad local↔remoto del CI (`local-ci.sh`) · enforce reglas firmes vía lints (`check-routing-english.sh` · `lint-memory.sh` · `test-migrations.sh`) · sync operativo de branches (`sync-dev-after-squash-merge.sh`) · pre-flights de skills (`local-ultrareview-preflight.sh`) · archivado periódico (`archive-log.sh`).

## Convención

- **Shebang:** `#!/usr/bin/env bash` + `set -euo pipefail` por default.
- **Header:** comentario inicial con propósito + regla/skill origen + uso (`bash scripts/<name>.sh` o invocación específica) + **stack adaptation banner** cuando el script asume herramientas concretas del stack (Postgres · Next.js · etc).
- **Funciones helper:** `ok` / `fail` / `info` para output legible · EXIT 0/1 claros.
- **Permisos:** ejecutables (`chmod +x`) · git preserva el bit `100755`.
- **Guards de boot del template:** scripts que operan sobre paths que pueden no existir al boot del template (`src/app/` · `db/migrations/` · `tests/sql/`) deben hacer skip silencioso con exit 0 cuando los paths no están · evita romper CI pre-bootstrap del producto del adopter.

## Archivos actuales

| Archivo | Severidad | Invocado por | Rol |
|---|---|---|---|
| `local-ci.sh` | 🔴 Crítico | `npm run ci:local` (paso 6 del flujo · gate antes del push) | Reproduce los jobs del CI remoto en local · 1 push = 1 PR = 1 CI · ahorra minutos GitHub Actions (regla [`push-and-ci-policy.md`](../.claude/rules/push-and-ci-policy.md)) |
| `local-ultrareview-preflight.sh` | 🟡 Operativo | Skill [`/revisar`](../.claude/skills/revisar/SKILL.md) | Preflight determinístico del paso 4 · jobs (`typecheck` · `build` · `lint` · `test:sql` · `audit`) + smoke `--help` antes del spawn de los 9 agentes Opus |
| `check-routing-english.sh` | 🔴 ABORT | Job `lint` del CI + `local-ci.sh` | Lint automático: rutas del framework en inglés industria-estándar (regla [`routing-paths-in-english.md`](../.claude/rules/routing-paths-in-english.md)) |
| `lint-memory.sh` | 🟡 Warning | Skill [`/memory-manager lint`](../.claude/skills/memory-manager/SKILL.md) (mensual o trigger manual) | Lint de `.claude/memory/` con 6 criterios (contradicciones · stale claims · orphan files · cross-refs rotos · conceptos sin página propia · data gaps PRP · regla [`lint-memory-periodic.md`](../.claude/rules/lint-memory-periodic.md)) |
| `test-migrations.sh` | 🔴 Crítico | Job `migrations-idempotency` del CI + paso 6 cierre PRP que toca BD | Verifica idempotencia + determinismo de migraciones · 2× reset + apply + dump diff (regla [`migrations-idempotency.md`](../.claude/rules/migrations-idempotency.md) · stack-tight Postgres/Supabase · adaptable a otros schema managers) |
| `run-sql-tests.sh` | 🟡 Operativo | Job `sql` del CI + `local-ci.sh` | Ejecuta specs de [`tests/sql/`](../tests/sql/) cuando existen · skip silencioso con notice al boot del template (paridad `test-migrations.sh`) |
| `sync-dev-after-squash-merge.sh` | 🔴 Operativo | Manual post `gh pr merge <N> --squash` | Re-alinea `dev` con `main` después del squash · evita divergencia heredada que bloquea el próximo CI dispatch silenciosamente (regla [`push-and-ci-policy.md`](../.claude/rules/push-and-ci-policy.md)) |
| `archive-log.sh` | 🟡 Operativo | Auto-propuesta contractual del agente en [`/arrancar`](../.claude/skills/arrancar/SKILL.md) Paso 5 al detectar deadline vencido (cada 14 días) | Archivado periódico de [`.claude/memory/log.md`](../.claude/memory/log.md) · snapshot inmutable a [`.claude/memory/_archive/log-YYYY-MM-DD.md`](../.claude/memory/_archive/) · auto-renovación del deadline en [`docs/logs/deadlines.md`](../docs/logs/deadlines.md) a +14 días (regla [`log-chronology-append-only.md`](../.claude/rules/log-chronology-append-only.md) § Archivado periódico) |

## Carpetas hermanas

- [`tests/scripts/`](../tests/scripts/) — smoke tests bash de invariantes de la fábrica del proyecto (shape P8 de reglas · shape de skills · paridad local↔remoto de jobs · hooks Husky no degenerados · pre-condition checks de agentes domain-tight). Los scripts de acá son **infra operativa** · los de `tests/scripts/` son **verificadores mecánicos de la infra**.
- [`.github/workflows/`](../.github/workflows/) — CI remoto que invoca varios de estos scripts (`local-ci.sh` simétrico · `check-routing-english.sh` en job `lint` · `test-migrations.sh` en job `migrations-idempotency` · `run-sql-tests.sh` en job `sql`).
- [`.husky/`](../.husky/) — git hooks que invocan parte del flow local (`pre-commit` typecheck/lint · `pre-push` typecheck/build · `post-commit` backup a `dev-backup`). Paridad mecánica con jobs equivalentes del CI remoto.

## Cómo agregar un script nuevo

1. **Validar duplicados:** ¿existe ya un script que cubra el rol? Si SÍ, extender ese · NO crear nuevo (regla [`simplicity-first.md`](../.claude/rules/simplicity-first.md)).
2. **Naming:** kebab-case · descriptivo · `<scope>-<accion>.sh` (ej: `lint-routing.sh` · `sync-dev.sh` · `test-migrations.sh`).
3. **Plantilla:** copiar shape de `check-routing-english.sh` o `test-migrations.sh` · header con stack adaptation banner cuando aplique + `set -euo pipefail` + funciones `ok`/`fail` + EXIT codes + guard de boot del template cuando opera sobre paths que pueden no existir.
4. **Permisos:** `chmod +x scripts/<name>.sh` · git preserva el bit `100755`.
5. **Wiring:** decidir si va a `package.json` scripts · job de [`.github/workflows/ci.yml`](../.github/workflows/) · invocación manual · hook de Husky · o múltiples canales con paridad mecánica.
6. **Doc:** sumar fila a la tabla "Archivos actuales" de este README + cita a regla/skill origen.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
