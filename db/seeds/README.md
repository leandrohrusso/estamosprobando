# `db/seeds/` · Seeds de la BD · prod (system) + test (fixtures durables)

> ⚙️ **Stack adaptation banner:** asume **Postgres** (típicamente Supabase) con seeds SQL planos. Si tu stack usa otro mecanismo (Firebase initial data · ORM factory · etc), el principio (separar data canónica del sistema vs fixtures de tests + orden de aplicación post-migraciones + idempotencia) es universal · la sintaxis cambia.

> **Qué es:** raíz unificada de seeds de la BD del proyecto. Contiene 2 subcarpetas con propósitos complementarios: [`prod/`](./prod/) (system seeds canónicos del producto) y [`test/`](./test/) (fixtures durables para tests E2E + SQL). Materializa las reglas firmes [`migrations-idempotency.md`](../../.claude/rules/migrations-idempotency.md) y [`seed-upsert-with-fixed-id.md`](../../.claude/rules/seed-upsert-with-fixed-id.md).
>
> **Por qué se creó:** separar data canónica del producto (config del sistema · feature flags) de fixtures de tests · ambos viven bajo la misma raíz `db/seeds/<contexto>/` para evitar ambigüedad estructural (`seed/` singular vs `seeds/` plural).
>
> **Para qué sirve:** poblar la BD en distintos contextos · `prod/` se aplica post-migraciones en TODOS los ambientes para config canónica del sistema · `test/` se aplica solo en TEST DB para fixtures durables que los specs E2E + SQL consumen.

## Subcarpetas

| Carpeta | Rol | Cuándo se aplica |
|---|---|---|
| [`prod/`](./prod/) | System seeds canónicos del producto (`<NN>_<aspecto>.sql`) · config + feature flags + referencias del sistema | Bootstrap inicial post-migraciones · CI lo aplica antes de `test/` si los fixtures de test referencian data canónica |
| [`test/`](./test/) | Test seed durable (`test-seed.sql`) · fixtures para tests E2E + SQL · UPSERT con UUIDs fijos | Solo TEST DB · post `prod/` · re-aplicar restaura canonical state si specs anteriores drift-earon |

## Convención

- **Orden de aplicación obligatorio:** primero los archivos de `prod/` en orden numérico → después `test/test-seed.sql`. Si los fixtures de test referencian FKs creadas por seeds de prod, sin el primero el seed test falla con `null value in column <fk>`.
- **Idempotencia:** todos los seeds usan `ON CONFLICT DO NOTHING` (prod · cero updates esperados) o `ON CONFLICT (id) DO UPDATE SET <cols mutables>` (test · re-aplicar restaura canonical state) · re-aplicar es no-op funcional.
- **Naming:** `seed/` singular vs `seeds/` plural es trampa de tipo · todo vive bajo `db/seeds/<contexto>/` cero ambigüedad.

## Carpetas hermanas

- [`db/migrations/`](../migrations/) — schema requerido para que los seeds apliquen.
- [`tests/sql/`](../../tests/sql/) — tests SQL que consumen los fixtures de `test/` (paridad regla [`seed-upsert-with-fixed-id`](../../.claude/rules/seed-upsert-with-fixed-id.md) § Process ítem 4 que prescribe spec de verificación UPSERT cuando el adopter lo codifique).
- [`tests/e2e/regression/`](../../tests/e2e/regression/) — specs E2E que dependen de los fixtures de `test/`.

## Reglas firmes asociadas

- [`migrations-idempotency.md`](../../.claude/rules/migrations-idempotency.md) — toda migración idempotente.
- [`seed-upsert-with-fixed-id.md`](../../.claude/rules/seed-upsert-with-fixed-id.md) — seeds durables con UPSERT + UUIDs fijos.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
