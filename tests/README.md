# `tests/` · Suite de testing del proyecto

> **Qué es:** raíz del testing. Aloja todos los tests automatizados (E2E con Playwright · SQL invariantes · smoke tests bash del flujo) + la matriz CSV de validación manual del skill [`/validar`](../.claude/skills/validar/SKILL.md) + archivado histórico cuando aparezca.
>
> **Por qué se creó:** separar tests del código de aplicación (`src/`) y de la infra de CI (`scripts/` · `.github/`). Convención Playwright (`testDir: './tests'`) y convención del proyecto (cada PRP del producto deja cobertura codificada acá · regla [`tests-as-dod-per-phase`](../.claude/rules/tests-as-dod-per-phase.md)).
>
> **Para qué sirve:** cubrir comportamiento del producto end-to-end (E2E) · invariantes de la BD (SQL · RLS · audit) cuando el adopter activa stack relacional · invariantes mecánicos del flujo (smoke tests bash) · matriz exhaustiva de validación CSV por PRP del producto.

## Convención

- **Naming Playwright:** `**/*.spec.ts` (testMatch del config). Ignora `**/_archive/**`.
- **Output Playwright:** `tests/test-results/` (gitignored).
- **Archivado:** todo material histórico va a `_archive/` dentro de la carpeta correspondiente (paridad: `tests/_archive/` · `tests/e2e/_archive/` · `tests/manual/_archive/` · creados JIT cuando aparezca primer histórico a archivar).
- **Regla pre-validación:** antes de arrancar un PRP nuevo, ver [`tests/e2e/regression/COVERAGE.md`](./e2e/regression/COVERAGE.md) (regla [`pre-validation-inherited-regression`](../.claude/rules/pre-validation-inherited-regression.md)).

## Subcarpetas actuales

| Carpeta | Rol |
|---|---|
| [`e2e/`](./e2e/) | Tests E2E con Playwright · setup + suite heredado en `regression/` |
| [`e2e/regression/`](./e2e/regression/) | Suite heredado de specs E2E por PRPs del producto cerrados · [`COVERAGE.md`](./e2e/regression/COVERAGE.md) como SoT |
| [`manual/`](./manual/) | Matriz CSV de validación · credenciales · golden references del skill [`/validar`](../.claude/skills/validar/SKILL.md) |
| [`scripts/`](./scripts/) | Smoke tests bash de invariantes del flujo |
| [`scripts/infra-flujo/`](./scripts/infra-flujo/) | Smokes activos wireados al CI (hooks · workflow · shape skills · shape rules) |
| [`sql/`](./sql/) | Tests SQL de invariantes (RLS · audit · permission gates · etc) · útil al adopter con stack relacional |
| `test-results/` | Output de Playwright en runtime (gitignored) |

> **Carpetas JIT (creadas cuando aparezca primer caller):** `_archive/` raíz · `e2e/_archive/` · `manual/_archive/` · y dominio-específicas que el adopter agregue (ej: `stock-race/` si su producto requiere tests de concurrencia · u otra subcarpeta según el dominio).

## Archivos en raíz

| Archivo | Rol |
|---|---|
| `global-setup.ts` | Setup global de Playwright invocado antes de cualquier spec |

## Carpetas hermanas

- [`src/`](../src/) — código de aplicación que estos tests verifican (estructura del adopter).
- `db/migrations/` — schema + RLS + RPCs cuyos invariantes verifica `tests/sql/` (del adopter · cuando sume BD relacional · paridad reglas [`migrations-idempotency`](../.claude/rules/migrations-idempotency.md) + [`seed-upsert-with-fixed-id`](../.claude/rules/seed-upsert-with-fixed-id.md)).
- [`scripts/`](../scripts/) — infra del CI (`local-ci.sh` · `check-routing-english.sh` · etc) consumida por estos tests.
- [`.github/workflows/`](../.github/workflows/) — CI remoto que ejecuta los jobs definidos por estos tests.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
