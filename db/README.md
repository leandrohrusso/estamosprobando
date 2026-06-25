# `db/` · Schema · migraciones · seeds de la base de datos

> ⚙️ **Stack adaptation banner:** esta carpeta asume stack con **BD relacional + migraciones SQL versionadas** (típicamente Postgres + Supabase con RLS). Si tu stack usa otro modelo (Firebase · MongoDB · ORMs con schema sync tipo Prisma/TypeORM), el principio (separar DDL del código · idempotencia · seeds canónicos vs fixtures de test) es universal · la implementación SQL plana de `migrations/` cambia al equivalente de tu schema manager. Adopter sin BD relacional puede eliminar la carpeta entera.

> **Qué es:** raíz de la BD del proyecto · contiene migraciones SQL versionadas + seeds (system seeds canónicos del producto + test seed durable con fixtures para tests).
>
> **Por qué se creó:** convención del proyecto · separar la definición de schema (DDL) de la aplicación (`src/`) · permitir versionado y replay de migraciones contra cualquier ambiente (dev local · TEST DB · prod). Materializa las reglas firmes [`migrations-idempotency.md`](../.claude/rules/migrations-idempotency.md) y [`seed-upsert-with-fixed-id.md`](../.claude/rules/seed-upsert-with-fixed-id.md).
>
> **Para qué sirve:** definir el schema completo de la BD vía migraciones secuenciales numeradas (`0001_*.sql` a `00NN_*.sql`) · poblar data canónica del sistema (`seeds/prod/`) · proveer fixtures durables para los tests E2E + SQL (`seeds/test/`).

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`migrations/`](./migrations/) | Migraciones SQL secuenciales numeradas · idempotentes · cubren schema + RLS + RPCs + índices |
| [`seeds/prod/`](./seeds/prod/) | System seeds canónicos del producto (`<NN>_<aspecto>.sql`) · config + feature flags · se aplican post-migraciones en todos los ambientes |
| [`seeds/test/`](./seeds/test/) | Test seed durable (`test-seed.sql`) · fixtures para tests E2E + SQL · UPSERT con UUIDs fijos (regla [`seed-upsert-with-fixed-id`](../.claude/rules/seed-upsert-with-fixed-id.md)) · solo TEST DB |

## Carpetas hermanas

- `src/lib/<db-client>/` — clients de tu BD consumidos por el código de aplicación (del adopter · ej: `src/lib/supabase/` si usás Supabase).
- [`tests/sql/`](../tests/sql/) — tests SQL que verifican invariantes sobre el schema definido acá.
- [`scripts/test-migrations.sh`](../scripts/test-migrations.sh) — script que verifica idempotencia + determinismo de las migraciones (regla [`migrations-idempotency`](../.claude/rules/migrations-idempotency.md)).

## Reglas firmes asociadas

- [`migrations-idempotency.md`](../.claude/rules/migrations-idempotency.md) — toda migración debe ser idempotente · `IF NOT EXISTS` · `DROP POLICY IF EXISTS` · etc.
- [`seed-upsert-with-fixed-id.md`](../.claude/rules/seed-upsert-with-fixed-id.md) — seeds durables usan UPSERT con UUIDs fijos · re-aplicar restaura canonical state.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
