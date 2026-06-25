# `db/migrations/` · Migraciones SQL secuenciales

> ⚙️ **Stack adaptation banner:** asume **Postgres** (típicamente Supabase) con migraciones SQL planas numeradas. Si tu stack usa un schema manager (Prisma `migrate` · TypeORM · Drizzle · Django migrations · etc), el principio (versionado + replay determinístico + idempotencia) es universal · la sintaxis cambia al equivalente de tu stack.

> **Qué es:** migraciones SQL numeradas que definen el schema completo de la BD · cada migración es atómica · idempotente · versionada en git.
>
> **Por qué se creó:** convención de versionado de schema · permitir replay determinístico de migraciones contra cualquier ambiente (dev local · TEST DB · prod). Materializa la regla firme [`migrations-idempotency.md`](../../.claude/rules/migrations-idempotency.md) — aplicar la misma migración N veces produce el mismo resultado que aplicarla 1 vez.
>
> **Para qué sirve:** evolucionar el schema de forma trazable y reversible · cada PRP del producto que toca BD agrega 1+ migración numerada · los entornos se sincronizan replayeando las migraciones que les faltan.

## Convención

- **Naming:** `00NN_<descripcion-corta>.sql` (4 dígitos · ceros a la izquierda · kebab-case en inglés). Ej: `0001_init.sql` · `00NN_<feature>_schema.sql`.
- **Idempotencia obligatoria:** cada DDL usa el patrón idempotente correspondiente (`CREATE TABLE IF NOT EXISTS` · `DROP POLICY IF EXISTS` antes de `CREATE POLICY` · bloque `DO $$ EXCEPTION WHEN duplicate_object` para tipos · etc · ver tabla completa en regla [`migrations-idempotency`](../../.claude/rules/migrations-idempotency.md) § Process).
- **Verificación local:** `bash scripts/test-migrations.sh` aplica las migraciones 2 veces y compara dumps. CI remoto corre el job `migrations-idempotency`.
- **Cero modificación de migraciones existentes:** una migración mergeada a `main` es inmutable. Si hace falta corregir, agregar una migración nueva que repare.

## Archivos actuales

Al boot del template la carpeta está **vacía** (cero migraciones). El adopter agrega migraciones conforme cierre PRPs del producto que tocan BD.

Convención de inventario: cuando aparezcan migraciones, ver `git log --oneline -- db/migrations/` para historial · cada commit menciona el PRP origen.

## Carpetas hermanas

- [`db/seeds/prod/`](../seeds/prod/) — system seeds canónicos · se aplican post-migraciones para poblar config inicial.
- [`db/seeds/test/`](../seeds/test/) — test seed durable · fixtures para tests · se aplica post-migraciones en TEST DB.
- [`tests/sql/`](../../tests/sql/) — invariantes SQL que verifican el schema producido por estas migraciones.

## Cómo agregar una migración nueva

1. **Numerar:** próximo número secuencial sin gaps (`00NN_<slug>.sql`).
2. **Patrón idempotente:** todo DDL con `IF NOT EXISTS` o `DROP IF EXISTS` previo · bloque `DO $$` para casos sin variante idempotente nativa.
3. **Aplicar contra TEST DB primero:** via Supabase MCP `apply_migration` o equivalente del stack del adopter · NUNCA editar migración previa.
4. **Verificar idempotencia:** `bash scripts/test-migrations.sh` debe retornar verde.
5. **Test SQL asociado:** sumar invariante en `tests/sql/<aspecto>.sql` que verifique la nueva DDL (regla [`tests-as-dod-per-phase.md`](../../.claude/rules/tests-as-dod-per-phase.md)).

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
