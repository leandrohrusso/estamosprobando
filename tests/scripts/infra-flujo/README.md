# `tests/scripts/infra-flujo/` · Capa transversal "infra del flujo"

> **Qué es:** carpeta de smoke tests bash que verifican invariantes mecánicos del flujo del proyecto (hooks Husky · workflow CI · convenciones del flujo de 6 pasos). NO son tests del producto · NO son E2E · son verificaciones binarias (verde/rojo) sobre piezas transversales que no encajan en `tests/e2e/` ni `tests/sql/`.
>
> **Por qué se creó:** el flujo tiene piezas transversales que se rompen silenciosamente (hook degenerado · `[skip ci]` en HEAD del PR · skill sin shape P8 · regla sin frontmatter) y el costo es alto · esta carpeta convierte cada gotcha empíricamente vivido en invariante mecánico verificado en CI.
>
> **Para qué sirve:** prevenir regresiones en infra crítica del flujo · ABORT inmediato en CI cuando un invariante firme se rompe · warning operativo para invariantes con falso positivo legítimo · documentar cada smoke con cita a la memoria fuente que lo motivó.

## Convención

- **Naming:** 1 archivo `.sh` por invariante · kebab-case descriptivo (ej: `skip-ci-not-in-pr-head.sh` · `husky-hooks-not-degenerated.sh`).
- **Plantilla bash:** `set -euo pipefail` + funciones `ok`/`fail` + EXIT codes claros (0 verde · 1 rojo).
- **Severidad binaria:** o ABORT (rompe regla firme operacional · job `lint`) o warning (heurística con falso positivo legítimo · job `infra-flujo-warnings` con `continue-on-error: true`).
- **Memoria fuente recomendada:** cada smoke cita el archivo en `.claude/memory/` que documenta el gotcha empírico que lo motivó (cuando aplica).
- **Wiring CI híbrido:** ABORT integrado al job `lint` para invariantes críticos · warning separado para invariantes operativos.
- **Consolidación 1 smoke por familia:** cuando varios invariantes hermanos comparten estructura, se consolidan en 1 smoke con verificaciones múltiples internas (ej: `husky-hooks-not-degenerated.sh` verifica los 3 hooks en un solo archivo · NO 3 archivos separados).

## Smoke tests del pack workflow-base

| Archivo | Severidad | Invocado en CI por | Memoria fuente / regla |
|---|---|---|---|
| [`skip-ci-not-in-pr-head.sh`](./skip-ci-not-in-pr-head.sh) | 🔴 ABORT | Job `lint` |  |
| [`rules-shape-p8.sh`](./rules-shape-p8.sh) | 🔴 ABORT | Job `lint` (las reglas firmes son doctrina · regression silenciosa si pierden shape P8 / frontmatter) | [`.claude/rules/README.md`](../../../.claude/rules/README.md) + regla #22 [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) |
| [`agents-domain-tight-have-precondition.sh`](./agents-domain-tight-have-precondition.sh) | 🔴 ABORT | Job `lint` · los 6 agentes domain-tight de `/revisar` + `/revisar-main` mantienen banner uniforme + Pre-condition check matriz 3-way (regla #35) | Regla #35 [`agents-conditional-by-domain.md`](../../../.claude/rules/agents-conditional-by-domain.md) |
| [`job-order-parity.sh`](./job-order-parity.sh) | 🔴 ABORT | Job `lint` · `scripts/local-ci.sh` array `ALL_JOBS=(...)` y `.github/workflows/ci.yml` cadenas `needs:` mantienen orden topológico paralelo · parseo dinámico cero hardcode de nombres de jobs · jobs CI-only (ej: `infra-flujo-warnings`) ignorados | Regla #34 [`husky-hooks-smoke-tests.md`](../../../.claude/rules/husky-hooks-smoke-tests.md) § Reglas operativas |
| [`sync-dev-pre-check-tree-comparison.sh`](./sync-dev-pre-check-tree-comparison.sh) | 🔴 ABORT | Job `lint` · `scripts/sync-dev-after-squash-merge.sh` mantiene pre-check tree-comparison del guard 2.6 (refinamiento iterativo upstream · evita FP en happy path squash merge sin perder protección DT-NNN) | regla #27 [`push-and-ci-policy.md`](../../../.claude/rules/push-and-ci-policy.md) |
| [`sync-dev-guards-local-commits-ahead.sh`](./sync-dev-guards-local-commits-ahead.sh) | 🔴 ABORT | Job `lint` · `scripts/sync-dev-after-squash-merge.sh` mantiene el guard que ABORTA si `dev` local tiene commits ahead-of-main sin pushear (DT-NNN · defensa contra pérdida silenciosa de trabajo al force-resetear `dev-backup` post-squash) | regla #27 [`push-and-ci-policy.md`](../../../.claude/rules/push-and-ci-policy.md) |
| [`fresh-install-canonical-state.sh`](./fresh-install-canonical-state.sh) | 🔴 ABORT | Job `lint` · template debe mantener estado canónico contractual hacia proyectos derivados · 11 bloques auditando TODAS las carpetas (root canónicos · estado post-template del sub-paso 1.b · carpetas vacías al boot · counts seed · archivos seed obligatorios · frontmatters memorias · log.md sin entries · docs/logs scaffolding · permisos +x · READMEs canónicos · workspace gitignored) · **skip-safe en proyectos derivados:** guard al inicio · auto-`exit 0` cuando `<PROYECTO>` está ausente de CLAUDE.md (señal de bootstrap aplicado) · solo corre full en el repo template (donde `<PROYECTO>` siempre está presente) · así el CI del primer PRP del adopter NO arranca rojo por diseño · cero des-cableo manual por adopter (queda wireado y se auto-gestiona) · paridad skip-safe con `preflight-environment.sh` | Regla #36 [`product-docs-as-bootstrap-sot.md`](../../../.claude/rules/product-docs-as-bootstrap-sot.md) + regla #22 [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) |
| [`preflight-environment.sh`](./preflight-environment.sh) | 🔴 ABORT | Job `lint` · stack Postgres+Supabase · 4 invariantes pre-jobs ci:local (a) `pg_dump` major match con servidor (parametrizable vía `EXPECTED_PG_MAJOR`) (b) TEST DB reachable (c) pool < `POOL_THRESHOLD` (default 20) (d) cleanup idle connections del current_user · **skip-safe** si `TEST_DATABASE_URL` no exportada (cero falso positivo al boot del template) · invocado inline en `scripts/local-ci.sh` § Pre-condiciones | Regla #32 [`migrations-idempotency.md`](../../../.claude/rules/migrations-idempotency.md) (stack Postgres+Supabase típico) |
| [`state-baseline-post-migrations.sh`](./state-baseline-post-migrations.sh) | 🔴 ABORT | Jobs `e2e` + `sql` · stack Postgres+Supabase · **par funcional con `state-assertion.sh`** (productor↔consumidor) · captura snapshot multi-catálogo (`pg_proc` · `pg_class` · `pg_policies` · `pg_trigger`) en `/tmp/ci-schema-baseline-${RUN_ID}.txt` · `RUN_ID` auto-genera en local · usa `$GITHUB_RUN_ID` en remoto · **skip-safe** si `TEST_DATABASE_URL` no exportada | Regla #32 [`migrations-idempotency.md`](../../../.claude/rules/migrations-idempotency.md) (stack Postgres+Supabase típico) |
| [`state-assertion.sh`](./state-assertion.sh) | 🔴 ABORT | Jobs `e2e` + `sql` (invocado 2× · paridad consolidación 1-smoke-1-archivo) · **par funcional con `state-baseline-post-migrations.sh`** (consumidor↔productor) · diff baseline vs current state vía `comm -23` · ABORT con lista de missings por categoría (functions · classes · policies · triggers) cuando drift detectado (ej: spec dropeó schema sin restaurar) · **skip-safe** si `TEST_DATABASE_URL` / `RUN_ID` / baseline file no presentes | Regla #32 [`migrations-idempotency.md`](../../../.claude/rules/migrations-idempotency.md) (stack Postgres+Supabase típico) |
| [`skills-shape.sh`](./skills-shape.sh) | 🟡 warning | Job `infra-flujo-warnings` (`continue-on-error: true`) · los 15 skills tienen shape P8 + frontmatter | Convención de [`.claude/skills/README.md`](../../../.claude/skills/README.md) |
| [`husky-hooks-not-degenerated.sh`](./husky-hooks-not-degenerated.sh) | 🟡 warning | Job `infra-flujo-warnings` (`continue-on-error: true`) | regla #34 [`husky-hooks-smoke-tests.md`](../../../.claude/rules/husky-hooks-smoke-tests.md) |

## Cómo agregar un smoke test nuevo

1. **Mecánico verificable:** el invariante debe ser binario (verde / rojo) sin ambigüedad. Si la regla es declarativa, queda como satélite en [`.claude/rules/`](../../../.claude/rules/) y NO entra acá.
2. **Plantilla:** copiar shape de `skip-ci-not-in-pr-head.sh` o `husky-hooks-not-degenerated.sh`. Header con propósito + memoria fuente + uso. `set -euo pipefail`. Funciones `ok`/`fail`. Exit 0/1 claros.
3. **Decidir severidad:** ¿rompe regla firme operacional? → ABORT en job `lint`. ¿Es heurística que puede tener falso positivo? → warning en job separado (`infra-flujo-warnings`).
4. **Wiring CI:** agregar step en [`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml) con filtro `if: github.event.pull_request.draft == false`.
5. **Documentar acá:** agregar fila a la tabla "Smoke tests del pack workflow-base" + cita a memoria fuente.

## Qué NO va acá

- ❌ Tests E2E del producto (esos viven en `tests/e2e/regression/` · NO existen al boot del pack).
- ❌ Tests SQL invariantes (esos viven en `tests/sql/` · NO existen al boot del pack).
- ❌ Lints declarativos del producto (rutas en inglés · vocabulario · etc → [`scripts/`](../../../scripts/)).
- ❌ Reglas firmes sin verificación mecánica (esas son satélites en [`.claude/rules/`](../../../.claude/rules/)).

## Carpetas hermanas

- [`tests/scripts/`](../) (carpeta padre) — raíz de smokes bash · cuando el proyecto sume smokes que NO son infra del flujo, viven en la raíz · esta carpeta es solo para los transversales del flujo.
- [`scripts/`](../../../scripts/) (raíz del repo) — infra del CI / linting general (`local-ci.sh` · `sync-dev-after-squash-merge.sh` · `archive-log.sh` · `lint-memory.sh`) consumida por estos smokes.

---

*Convención de README firmada con regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md).*
