---
name: migrations-idempotency
description: Toda migración debe ser idempotente · aplicarla N veces produce el mismo resultado que aplicarla 1 vez. Verificado por scripts/test-migrations.sh + job CI migrations-idempotency.
type: rule
applies-to: cualquier migración nueva en db/migrations/ · DDL · RLS policies · RPCs · seeds
---

> ⚙️ **Stack adaptation banner:** esta regla asume migraciones SQL planas bajo `db/migrations/` con sintaxis **PostgreSQL/Supabase** (RLS policies · `SECURITY DEFINER/INVOKER` · RPCs como funciones plpgsql). Si tu proyecto usa un schema manager con migraciones versionadas (ej: Prisma `migrate` · TypeORM `migration:generate` · Drizzle `drizzle-kit push` · Django migrations · Rails migrations), el principio (idempotencia · re-aplicación segura · cero rotura en producción al repetirse) es universal · la implementación cambia: en Prisma usar `prisma migrate resolve` para migraciones aplicadas a mano · en TypeORM cuidar `synchronize: false` + migraciones explícitas · etc. Los patrones idempotentes SQL de § Process (`IF NOT EXISTS` · `DROP POLICY IF EXISTS` antes de `CREATE POLICY`) son ejemplos del stack Postgres · adaptá al schema manager de tu stack.

## Overview

> **Toda migración bajo `db/migrations/` debe ser idempotente.** Aplicarla N veces seguidas produce el mismo resultado que aplicarla 1 vez. Verificado en cloud por `scripts/test-migrations.sh` y en CI remoto por el job `migrations-idempotency`.

**Por qué firme:** las migraciones se aplican primero a TEST DB · luego a prod via Supabase MCP (o equivalente del stack). Si una migración no es idempotente, al repetirse en prod (manual override · re-aplicación post-rollback · supabase branch reset) tira error y bloquea el deploy. Además, el patrón idempotente atrapa bugs heredados (caso clásico: policies preexistentes en cloud no se actualizan con `CREATE POLICY` solo · necesitás `DROP POLICY IF EXISTS` antes). Cuando tu proyecto detecte ese caso, codificarlo como memoria en `.claude/memory/feedback/migration-idempotente-no-actualiza-preexistentes.md`.

## When

**Aplica a:**

- Cualquier archivo nuevo en `db/migrations/00NN_*.sql`.
- DDL: `CREATE TABLE` · `ALTER TABLE` · `CREATE INDEX` · `CREATE TYPE` · `CREATE FUNCTION`.
- RLS policies: `CREATE POLICY` · `ALTER POLICY` · `DROP POLICY`.
- RPCs (Supabase Postgres functions con `SECURITY INVOKER` o `SECURITY DEFINER`).
- Triggers · constraints · seeds del schema.

**NO aplica a:**

- Datos seed de fixtures (esos siguen [`seed-upsert-with-fixed-id.md`](./seed-upsert-with-fixed-id.md)).
- Tests SQL (`tests/sql/*.sql`) — esos pueden no ser idempotentes (rollback explícito al final).

## Process

**Patrones idempotentes obligatorios por tipo de DDL:**

| Tipo | Patrón idempotente |
|---|---|
| **Table** | `CREATE TABLE IF NOT EXISTS <name> (...)` |
| **Column** | `ALTER TABLE <name> ADD COLUMN IF NOT EXISTS <col> <type>` |
| **Index** | `CREATE INDEX IF NOT EXISTS <name> ON <table>(<cols>)` |
| **Constraint** | Bloque `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$;` o `ALTER TABLE ... DROP CONSTRAINT IF EXISTS <name>` antes del `ADD CONSTRAINT` |
| **Type / Enum** | `DO $$ BEGIN CREATE TYPE <name> AS ENUM (...); EXCEPTION WHEN duplicate_object THEN NULL; END $$;` |
| **Function / RPC** | `CREATE OR REPLACE FUNCTION <name>(...) RETURNS ... AS $$ ... $$ LANGUAGE plpgsql;` |
| **RLS Policy** | `DROP POLICY IF EXISTS <name> ON <table>;` ANTES de `CREATE POLICY <name> ON <table> ...` |
| **Trigger** | `DROP TRIGGER IF EXISTS <name> ON <table>;` ANTES de `CREATE TRIGGER ...` |
| **Comment** | `COMMENT ON ... IS '...'` (siempre idempotente) |

**Verificación local (obligatoria al cierre de cualquier PRP que toca migrations):**

```bash
bash scripts/test-migrations.sh
```

Aplica las migraciones 2 veces y compara dumps. Si falla pasada 2 → migración NO idempotente · NO mergear.

**Verificación CI remoto:**

Job `migrations-idempotency` corre en `.github/workflows/ci.yml` con `needs: [e2e]` + `if: always()`. Aplica el suite de migraciones 2 veces sobre TEST DB y verifica equivalencia.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "La migración es nueva · primera aplicación · no necesita idempotencia" | NO. La migración va a aplicarse en cloud · en branches de Supabase · en TEST DB · en CI. Cualquiera de esos contextos puede repetirla. La regla es idempotente desde el día 1 · cero excepciones. |
| "Mi `CREATE POLICY` ya pasó test local · no necesito `DROP POLICY IF EXISTS`" | NO. Caso clásico: policies preexistentes en cloud (de migraciones anteriores que se re-aplicaron) NO se actualizan con `CREATE POLICY` solo · queda shape stale. `DROP POLICY IF EXISTS` antes garantiza el shape correcto. Codificá el ejemplo concreto que detecte tu proyecto en `feedback/migration-idempotente-no-actualiza-preexistentes.md`. |

## Red flags

- 🚩 Tu migración nueva tiene `CREATE TABLE <name>` sin `IF NOT EXISTS`.
- 🚩 Tu migración tiene `CREATE POLICY <name>` sin `DROP POLICY IF EXISTS <name>` antes.
- 🚩 Tu migración tiene `ALTER TABLE ADD COLUMN <col>` sin `IF NOT EXISTS`.
- 🚩 Tu migración tiene `CREATE TYPE <name> AS ENUM` sin bloque `DO $$ EXCEPTION WHEN duplicate_object`.
- 🚩 No corriste `bash scripts/test-migrations.sh` antes del commit.
- 🚩 CI remoto reportó job `migrations-idempotency` rojo y mergeaste igual.

## Verification

- [ ] Cada DDL en la migración usa el patrón idempotente correspondiente (tabla · columna · índice · constraint · type · function · policy · trigger).
- [ ] `bash scripts/test-migrations.sh` corre verde local antes del commit.
- [ ] CI remoto job `migrations-idempotency` verde post-push.
- [ ] Si la migración modifica policy preexistente: `DROP POLICY IF EXISTS` antes del `CREATE POLICY`.

**Cross-reference firme:**

- Memoria detallada (cuando tu proyecto la genere): `feedback/migration-idempotente-no-actualiza-preexistentes.md` con el caso concreto del repo · vacío al boot del pack.
- Hermana: [`seed-upsert-with-fixed-id.md`](./seed-upsert-with-fixed-id.md) (idempotencia de seeds via UPSERT).
- Refuerza: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (validación per-fase).

> **Banner de bifurcación · idempotencia DDL vs idempotencia de datos.** Esta regla y [`seed-upsert-with-fixed-id.md`](./seed-upsert-with-fixed-id.md) son hermanas paralelas del bloque "idempotencia de BD" pero divergen deliberadamente en estructura: **migrations-idempotency** usa tabla referencial por tipo DDL (table · column · index · policy · etc · 8 patrones) porque DDL tiene N tipos discretos · cada uno con su patrón idempotente correcto. **seed-upsert** usa patrón único (UUID fijo + `ON CONFLICT (id) DO UPDATE SET <cols mutables>`) + heurística de "qué columnas van al SET" porque seeds son INSERTs de datos · 1 patrón cubre el 100%. La asimetría es legítima · refleja la naturaleza distinta de DDL (multi-pattern) vs DML (single-pattern). Ambas comparten severidad ABORT en CI · cero excepciones · regression-first FIRME.
