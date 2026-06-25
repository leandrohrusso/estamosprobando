---
name: seed-upsert-with-fixed-id
description: Los seeds de fixtures durables usan ON CONFLICT (id) DO UPDATE con UUIDs fijos · re-aplicar el seed restaura columnas mutables canónicas si la TEST DB derivó. Origen DT-NNN / PRP-NNN Plan B.
type: rule
applies-to: db/seeds/test/test-seed.sql · cualquier fixture durable que se re-aplique a TEST DB
---

> ⚙️ **Stack adaptation banner:** esta regla asume stack con **BD relacional + sintaxis `ON CONFLICT (id) DO UPDATE` nativa** (PostgreSQL/Supabase) + seeds bajo `db/seeds/test/*.sql`. Si tu proyecto usa otra BD relacional (MySQL → `ON DUPLICATE KEY UPDATE` · SQLite → `INSERT ... ON CONFLICT(col) DO UPDATE` · CockroachDB → idem Postgres · MariaDB → idem MySQL), adaptá la sintaxis pero preservá el principio. Si usa NoSQL (MongoDB · DynamoDB · Firestore), adaptá los mecanismos: el principio (re-aplicar seed restaura state canónico cuando un spec previo lo drift-eó · UUIDs fijos + UPSERT vs `INSERT-on-conflict-do-nothing`) es universal · la implementación (`ON CONFLICT (id) DO UPDATE SET <cols mutables>`) es SQL · reemplazá por el equivalente (ej: `bulkWrite` con `upsert:true` de MongoDB · `PutItem` idempotente de DynamoDB · `set(merge:true)` de Firestore).

## Overview

> **Los seeds de fixtures durables usan UPSERT con UUIDs fijos** (`INSERT ... ON CONFLICT (id) DO UPDATE SET <cols mutables>`). Re-aplicar el seed restaura las columnas mutables canónicas (status · stock · venue_id · paid_at · etc) si los tests previos drift-earon el estado de la TEST DB.

**Por qué firme:** la TEST DB es compartida por todos los specs E2E del producto. Si un spec X mutó `<tabla>.<col>` y NO restauró, el spec Y siguiente lee estado corrompido. Sin UPSERT, re-aplicar el seed pre-spec-suite no restaura · solo INSERT-on-conflict-do-nothing · y el drift se acumula sesión tras sesión.

## When

**Aplica a:**

- `db/seeds/test/test-seed.sql` (seed durable de la TEST DB).
- Cualquier fixture compartido entre specs (ej: en un dominio ticketing serían `events · event_dates · ticket_types · orders · vouchers · users · producers` · adaptá a las tablas core de tu dominio).
- Re-aplicación de seed después de cambios estructurales (DDL nuevo · column nuevo).

**NO aplica a:**

- Fixtures efímeros dentro de un spec (ej: `INSERT INTO orders (id, ...) VALUES (gen_random_uuid(), ...)` · spec lo crea + cleanup en `afterEach`).
- Datos one-time del schema base (auth users · system rows generados por migraciones).

## Process

**Patrón canónico del UPSERT con id fijo** (ejemplo en dominio ticketing · adaptá `events`/`organization_id`/`venue_id` a las tablas/columnas core de tu dominio · cero refactor obligatorio del SQL al boot del pack · solo cuando el adopter escriba su seed real):

```sql
-- 1. UUID literal hardcoded (no gen_random_uuid)
-- 2. ON CONFLICT (id) DO UPDATE para restaurar columnas mutables
INSERT INTO events (id, organization_id, name, status, venue_id, ...)
VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  'Evento Test Producciones',
  'published',
  '00000000-0000-0000-0000-000000000020'::uuid,
  ...
)
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  venue_id = EXCLUDED.venue_id;  -- ← columnas que un spec puede haber mutado
```

**Reglas operativas:**

1. **UUID fijo en cada INSERT** · cero `gen_random_uuid()` en seeds durables (sino el ON CONFLICT no atrapa la fila previa).
2. **Columnas en `DO UPDATE SET`** · solo las mutables que un spec puede romper (status · stock_remaining · paid_at · cancelled_at · venue_id · etc). NO incluir `created_at` ni columnas inmutables.
3. **Si una columna inmutable cambia de schema** · re-emitir el seed en una migración (no editar el seed silenciosamente · porque los UUIDs son contractuales).
4. **Verificación regression-first:** spec SQL que codifica el patrón **snapshot canonical → corromper N fixtures durables → re-aplicar seed → assert cada fixture restaurado al canónico**. Adopter codifica su versión en `tests/sql/seed-upsert-restores-canonical.sql` (o naming equivalente · con UUIDs + tablas + lógica reales del proyecto). Pre-fix (seed con `ON CONFLICT DO NOTHING`) → assert falla con EXIT=1. Post-fix (seed con `ON CONFLICT DO UPDATE SET`) → assert pasa con `RAISE NOTICE` OK.

**Cómo decidir qué columnas van a `DO UPDATE SET`:**

> Si un spec puede mutar la columna durante el test y la próxima sesión va a leerla esperando el valor canónico → la columna va al SET.

Ejemplos del seed (ilustrativos · adaptá a tu dominio):

- `events.status`: SÍ (specs publican/despublican).
- `events.venue_id`: SÍ (specs cambian venue para validar reglas).
- `events.created_at`: NO (inmutable · si un spec la cambia es bug del spec).
- `event_dates.status`: SÍ.
- `ticket_types.stock_remaining`: SÍ (compras drenan stock · refunds devuelven).
- `orders.status` + `paid_at`: SÍ (simulate_pay · cancel_order mutan).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Uso `gen_random_uuid()` en el seed para que cada test corra con UUIDs frescos" | NO. Ese patrón es para fixtures efímeros dentro del spec · NO para seed durable. UUIDs frescos rompen referential integrity con otros fixtures durables · y el ON CONFLICT no atrapa nada. |
| "Si un spec rompe el state, el spec siguiente debe limpiar · no el seed" | NO. La TEST DB es compartida y los specs corren en paralelo · cleanup post-spec no llega a tiempo. La regla DT-NNN firma firme · UPSERT en seed = última red de defensa. |
| "Agregar `DO UPDATE SET` infla el seed · prefiero `ON CONFLICT DO NOTHING`" | NO. `DO NOTHING` = no idempotencia funcional · el seed ya no restaura state. La regla es UPSERT con SET de columnas mutables · cero excepciones. |

## Red flags

- 🚩 Tu seed nuevo usa `gen_random_uuid()` o no tiene UUID hardcoded.
- 🚩 Tu seed usa `ON CONFLICT (id) DO NOTHING` en lugar de `DO UPDATE SET`.
- 🚩 Una columna mutable que un spec rompe NO está en el `DO UPDATE SET` (next session lee estado drifted).
- 🚩 No corriste el spec regression-first del UPSERT del seed (si tu proyecto codificó uno · ver Process ítem 4) antes del commit.

## Verification

- [ ] Cada INSERT del seed durable tiene UUID hardcoded.
- [ ] Cada INSERT del seed durable tiene `ON CONFLICT (id) DO UPDATE SET <cols mutables>`.
- [ ] Las columnas en `DO UPDATE SET` son solo las mutables (status · stock · venue_id · paid_at · etc · NO `created_at`).
- [ ] Spec regression-first del UPSERT del seed verde antes del commit (si tu proyecto lo codificó · ver Process ítem 4).
- [ ] Re-aplicar el seed en TEST DB drifted retorna canonical state (verificable manual).

**Cross-reference firme:**

- Hermana: [`migrations-idempotency.md`](./migrations-idempotency.md) (idempotencia DDL).
- Memoria asociada (cuando tu proyecto la genere): `feedback/psql-set-variables-not-in-do-blocks.md` con gotcha de `\set` variables psql dentro de bloques `DO` · vacío al boot del pack.
- Refuerza: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md) (regression-first FIRME).

> **Banner de bifurcación · idempotencia de datos vs idempotencia DDL.** Esta regla y [`migrations-idempotency.md`](./migrations-idempotency.md) son hermanas paralelas del bloque "idempotencia de BD" pero divergen deliberadamente en estructura (ver banner espejo en la regla hermana). Esta regla usa patrón único (UUID fijo + `ON CONFLICT (id) DO UPDATE SET <cols mutables>`) + heurística de "qué columnas mutables van al SET" porque seeds son INSERTs de datos · 1 patrón cubre el 100%. La hermana usa tabla referencial por tipo DDL (8 patrones) porque DDL tiene N tipos discretos. Ambas comparten severidad ABORT en CI · cero excepciones · regression-first FIRME.
