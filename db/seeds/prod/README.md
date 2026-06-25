# `db/seeds/prod/` · System seeds canónicos del producto

> ⚙️ **Stack adaptation banner:** asume **Postgres** con seeds SQL planos. Adaptable a cualquier stack relacional · si tu stack usa otro mecanismo de initial data, mantené el principio: data canónica del sistema separada de fixtures de tests.

> **Qué es:** seeds SQL del sistema · poblan data canónica que TODOS los ambientes necesitan (config global · feature flags · referencias del sistema). Se aplican post-migraciones · una sola vez por ambiente.
>
> **Por qué se creó:** separar data canónica del producto de fixtures de tests. Esta carpeta contiene lo que necesita CUALQUIER ambiente (dev · TEST · prod) para funcionar · NO contiene data de prueba.
>
> **Para qué sirve:** garantizar que nuevos ambientes arranquen con la config mínima viable del producto · sin esto las queries o triggers que asumen data del sistema presente fallan (ej: trigger que asume FK válida hacia tabla de config).

## Convención

- **Naming:** `<NN>_<aspecto>.sql` (orden numérico de aplicación · kebab-case en inglés).
- **Idempotencia:** uso de `INSERT ... ON CONFLICT DO NOTHING` (data canónica inmutable) o `DO UPDATE SET <cols>` cuando aplica.
- **Aplicación:** post-migraciones · en orden numérico (`01_*.sql` → `02_*.sql` → etc) · si hay FKs entre archivos, respetar el orden.
- **NO contiene fixtures de tests** · esos viven en [`../test/test-seed.sql`](../test/test-seed.sql).

## Archivos actuales

Al boot del template la carpeta está **vacía** (cero seeds canónicos). El adopter agrega seeds conforme defina la config canónica de su producto.

Ejemplo típico cuando aparezcan:

| Archivo | Rol típico |
|---|---|
| `<01_system.sql>` | Config canónica del sistema (settings · referencias inmutables) |
| `<02_domain.sql>` | Data canónica del dominio (catálogos · enums externalizados · etc) |

## Carpetas hermanas

- [`../test/`](../test/) — test seed durable (fixtures de tests) · se aplica DESPUÉS de `prod/` si referencia FKs creadas acá.
- [`../../migrations/`](../../migrations/) — schema · estos seeds dependen del schema producido por las migraciones.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md)).*
