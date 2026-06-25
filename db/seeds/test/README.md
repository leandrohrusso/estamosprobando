# `db/seeds/test/` · Test seed durable · fixtures para tests E2E + SQL

> ⚙️ **Stack adaptation banner:** asume **Postgres** con seeds SQL planos + tests E2E (típicamente Playwright) + tests SQL. Adaptable a cualquier stack relacional · si tu stack usa factories de ORM o herramienta de fixtures distinta, mantené el principio: UPSERT con identifier fijo + restaurar canonical state al re-aplicar.

> **Qué es:** test seed con fixtures durables (`<tablas del dominio>`) usadas por TODOS los specs E2E ([`tests/e2e/regression/`](../../../tests/e2e/regression/)) y SQL ([`tests/sql/`](../../../tests/sql/)) contra la TEST DB del adopter.
>
> **Por qué se creó:** materializar la regla firme [`seed-upsert-with-fixed-id.md`](../../../.claude/rules/seed-upsert-with-fixed-id.md) — UUIDs hardcoded + `ON CONFLICT (id) DO UPDATE SET <cols mutables>` · re-aplicar el seed restaura el canonical state si los specs anteriores drift-earon la BD. Evita state-drift entre runs de tests sobre BD compartida.
>
> **Para qué sirve:** garantizar que cada run de tests arranca con BD en estado conocido · permite tests paralelos sobre la misma TEST DB sin contaminación cruzada · reduce fragilidad del suite acumulativo.

## Convención

- **UUIDs hardcoded:** cero `gen_random_uuid()` · cada INSERT con UUID literal (`'00000000-0000-0000-0000-000000000001'::uuid`).
- **UPSERT obligatorio:** `INSERT ... ON CONFLICT (id) DO UPDATE SET <cols mutables>` (status · stock · timestamps mutables · etc).
- **Cero columnas inmutables en SET:** NO `created_at` · NO ids · solo lo que un spec puede mutar y necesita restaurar.
- **Aplicación:** DESPUÉS de seeds de `../prod/` si los fixtures de test referencian FKs creadas allá.
- **Verificación opcional:** adopter puede codificar `tests/sql/seed-upsert-restores-canonical.sql` (paridad regla [`seed-upsert-with-fixed-id`](../../../.claude/rules/seed-upsert-with-fixed-id.md) § Process ítem 4): corrompe N fixtures → re-aplica seed → assert canonical restored.

## Archivos actuales

Al boot del template la carpeta está **vacía** (cero fixtures). El adopter agrega `test-seed.sql` cuando defina los fixtures del dominio que sus tests necesitan.

Ejemplo típico cuando aparezca:

| Archivo | Rol típico |
|---|---|
| `test-seed.sql` | Seed durable con fixtures del dominio (`<tablas del dominio>`) · UPSERT con UUIDs fijos · 1 archivo único o split por entidad si crece (`test-seed-<entidad>.sql`) |

## Carpetas hermanas

- [`../prod/`](../prod/) — system seeds del producto · se aplican ANTES de `test/` si los fixtures de test referencian FKs creadas allá.
- [`../../migrations/`](../../migrations/) — schema requerido para que el seed aplique.
- [`../../../tests/sql/`](../../../tests/sql/) — tests SQL que consumen estos fixtures.
- [`../../../tests/e2e/regression/`](../../../tests/e2e/regression/) — specs E2E que dependen de estos fixtures.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md)).*
