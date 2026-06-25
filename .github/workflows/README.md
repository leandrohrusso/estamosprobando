# `.github/workflows/` · GitHub Actions workflows del proyecto

> ⚙️ **Stack adaptation banner:** el workflow `ci.yml` al boot del template asume stack Node + Playwright + SQL. Los jobs llevan comentarios `# TODO: reemplazar con comando de <X> del proyecto` para guiar la adaptación al stack real del adopter (Rails · Django · Go · etc). Cero hardcode irreversible · cada job es plantilla mínima editable.
>
> **Qué es:** definiciones de los workflows de GitHub Actions del proyecto. Al boot del template hay 1 workflow (`ci.yml`) · el adopter puede sumar otros (release · sync-dev-after-merge · etc) conforme su flujo lo necesite.
>
> **Por qué se creó:** convención GitHub · workflows declarativos en YAML viven acá · el harness los descubre automáticamente al hacer push. Materializa la regla firme #27 [`push-and-ci-policy.md`](../../.claude/rules/push-and-ci-policy.md) ("1 push = 1 PR = 1 CI por PRP del producto") con CI remoto único sobre `pull_request` no-draft.
>
> **Para qué sirve:** validar mecánicamente cada PR antes del merge a `main` · jobs bloqueantes (sin `continue-on-error`) garantizan que el código que entra a `main` pasa los gates del proyecto (typecheck · lint · build · tests · invariantes).

## Convención

- **Naming:** `<scope>.yml` en kebab-case (ej: `ci.yml` · futuro `release.yml` · futuro `sync-dev-after-merge.yml`).
- **Triggers:** `pull_request` only (NO `push:`) para evitar runs redundantes · `pull_request` filtra `draft == false` en cada job para que skills como `/ultrareview` puedan trabajar sobre PR draft sin disparar CI.
- **Concurrency:** `concurrency.cancel-in-progress: true` cancela runs viejos del mismo branch cuando llega un push nuevo · ahorra minutos de GitHub Actions.
- **Cero `continue-on-error` en jobs principales:** los jobs del CI son bloqueantes (typecheck · lint · build · etc). Excepción documentada: jobs de tipo `infra-flujo-warnings` (smoke tests con falsos positivos legítimos) usan `continue-on-error: true` en job separado.
- **Verificación cruzada con `scripts/local-ci.sh`:** el orden de jobs en `ci.yml` debe matchear `ALL_JOBS` en `scripts/local-ci.sh` (invariante de paridad explícito en el header del `ci.yml`). Si cambia el orden o se agregan jobs, actualizar AMBOS archivos en el mismo commit.

## Archivos actuales

| Archivo | Rol |
|---|---|
| [`ci.yml`](./ci.yml) | CI principal · jobs bloqueantes sobre `pull_request` no-draft (typecheck · lint · build · unit · e2e · sql + `infra-flujo-warnings` no bloqueante) |
| [`sync-dev-after-merge.yml`](./sync-dev-after-merge.yml) | Trigger sobre `push: branches: [main]` · realinea `origin/dev` y `origin/dev-backup` con `origin/main` post-squash-merge · blindaje contra olvido del script local [`scripts/sync-dev-after-squash-merge.sh`](../../scripts/sync-dev-after-squash-merge.sh) · materializa regla #27 [`push-and-ci-policy.md`](../../.claude/rules/push-and-ci-policy.md) |

> **Workflows futuros (no incluidos al boot del template):** el adopter puede sumar `release.yml` (cuando el proyecto defina ciclos de release versionados) · otros workflows ad-hoc que su flujo requiera.

## Jobs del CI al boot del template (`ci.yml`)

| Job | Comando default (stack Node) | Adaptable a |
|---|---|---|
| `typecheck` | `npm run typecheck` | Comando equivalente del stack (ej: `mypy` · `cargo check` · `go vet`) |
| `lint` | `npm run lint` + 5 smokes infra-flujo del pack | Linter del stack (`ruff` · `rubocop` · `golangci-lint`) · smokes infra-flujo se preservan |
| `build` | `npm run build` | Build prod del stack (`rails assets:precompile` · `python -m build` · `go build`) |
| `unit` | `npm run test:unit` | Test runner del stack · si el proyecto NO tiene unit tests, eliminar el job |
| `e2e` | `npm run test:e2e` | Suite end-to-end del stack (Playwright · Cypress · Capybara · etc) |
| `sql` | `bash scripts/run-sql-tests.sh` | Tests SQL contra TEST DB · si el stack NO tiene BD, eliminar el job |
| `infra-flujo-warnings` | smokes `skills-shape.sh` + `husky-hooks-not-degenerated.sh` | NO eliminar · son invariantes del pack (operativos no bloqueantes) |

**Smokes invariantes del job `lint` (ABORT en fallo):** [`rules-shape-p8.sh`](../../tests/scripts/infra-flujo/rules-shape-p8.sh) · [`skip-ci-not-in-pr-head.sh`](../../tests/scripts/infra-flujo/skip-ci-not-in-pr-head.sh) · [`agents-domain-tight-have-precondition.sh`](../../tests/scripts/infra-flujo/agents-domain-tight-have-precondition.sh) · [`sync-dev-pre-check-tree-comparison.sh`](../../tests/scripts/infra-flujo/sync-dev-pre-check-tree-comparison.sh) · [`fresh-install-canonical-state.sh`](../../tests/scripts/infra-flujo/fresh-install-canonical-state.sh).

## Secrets requeridos

El adopter define los secrets del CI en `Settings > Secrets and variables > Actions` del repo GitHub. Los valores específicos (URLs · API keys · connection strings · credenciales seed) dependen del stack y el proveedor:

- **Build:** secrets que el comando `build` necesita en runtime (ej: URLs públicas · API keys del frontend si aplica).
- **Tests E2E:** secrets de TEST DB o entorno staging contra el cual corre la suite (URLs · keys · credenciales seed).
- **Tests SQL:** connection string al TEST DB.

Cero secrets hardcoded en este README · cada proyecto adopter declara los suyos en `BUSINESS_LOGIC.md § 7 Stack confirmado` + memoria persistente en `.claude/memory/reference/` cuando aplica.

## Carpetas hermanas

- [`.github/`](../) — raíz de configuración GitHub · contiene este folder + `PULL_REQUEST_TEMPLATE.md`.
- [`scripts/`](../../scripts/) — scripts bash invocados desde `ci.yml` (`local-ci.sh` simétrico · `run-sql-tests.sh` · `sync-dev-after-squash-merge.sh` · etc).
- [`tests/scripts/infra-flujo/`](../../tests/scripts/infra-flujo/) — smoke tests que codifican invariantes mecánicos del flujo · varios se invocan desde el job `lint` (con ABORT integrado) + `infra-flujo-warnings` (sin ABORT).

## Cómo agregar un workflow nuevo

1. **Validar que NO existe** un workflow que ya cumpla el rol (regla #23 [`respect-existing-folder-structure.md`](../../.claude/rules/respect-existing-folder-structure.md)).
2. **Naming:** `<scope>.yml` kebab-case (ej: `release.yml` · `sync-dev-after-merge.yml`).
3. **Trigger:** `pull_request` o `push: branches: [<rama>]` según corresponda · evitar duplicar CI sobre el mismo evento.
4. **Sumar fila** acá en § "Archivos actuales" con rol 1-línea.
5. **Si el workflow refleja un invariante operativo del pack** (ej: `sync-dev-after-merge.yml` blindando regla #27) sumarlo también a § "Workflows futuros" cuando se materialice.

## Reglas firmes asociadas

- [`push-and-ci-policy.md`](../../.claude/rules/push-and-ci-policy.md) — regla #27 · 1 push + 1 PR + 1 CI remoto + 1 local CI gate por PRP.
- [`migrations-idempotency.md`](../../.claude/rules/migrations-idempotency.md) — regla #32 · si el stack tiene migraciones · job dedicado (típicamente `migrations-idempotency`) las valida.
- [`seed-upsert-with-fixed-id.md`](../../.claude/rules/seed-upsert-with-fixed-id.md) — regla #33 · si el stack tiene seeds · usar UPSERT con UUIDs fijos · re-aplicar restaura canonical state.
- [`husky-hooks-smoke-tests.md`](../../.claude/rules/husky-hooks-smoke-tests.md) — regla #34 · hooks Husky con smoke tests · paridad con jobs CI cuando aplica.

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
