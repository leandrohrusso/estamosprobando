# `tests/sql/` · Tests SQL de invariantes · capa BD

> ⚙️ **Stack adaptation banner:** este README asume stack con **BD relacional + PostgreSQL/Supabase** (RLS · RPCs `SECURITY DEFINER/INVOKER` · `pg_policies` · DO blocks con `BEGIN/EXCEPTION/ROLLBACK`). Si tu proyecto usa otro stack (Firebase · MongoDB · MySQL · etc), adaptá: el principio (cubrir invariantes que E2E no atrapa · separación capa BD vs UI · idempotencia con cleanup explícito) es universal · la sintaxis SQL concreta cambia.

> **Qué es:** tests SQL que verifican invariantes de la base de datos (políticas RLS · audit log · atomicity de RPCs · integridad referencial · permisos por rol · render desde snapshots). Se ejecutan contra una TEST DB con el seed durable aplicado.
>
> **Por qué se creó:** cubrir las capas que los tests E2E del browser no atrapan (políticas RLS · invariantes de RPCs · permission gates por rol · atomicity de operaciones). Cada PRP del producto que toca BD deja acá los tests SQL que verifican sus invariantes (paridad regla [`tests-as-dod-per-phase`](../../.claude/rules/tests-as-dod-per-phase.md)).
>
> **Para qué sirve:** garantizar que las policies multi-tenant no permiten cross-tenant leak · que las RPCs son atómicas (rollback en falla) · que el audit log se popula correctamente · que las invariantes BD sobreviven a refactors futuros.

## Convención

- **Naming:** `prp-NNN-<feature>.sql` para tests específicos de un PRP · `<invariant-name>-invariant.sql` o `<invariant-name>.sql` para invariantes transversales.
- **Estructura:** static checks (asserts sobre schema · `pg_policies` · etc) + mutating tests (DO blocks con `BEGIN/EXCEPTION/ROLLBACK` que ejercitan el comportamiento).
- **Idempotencia:** los DO blocks deben dejar la BD en el mismo estado que la encontraron · `ROLLBACK` o cleanup explícito al final · paridad regla [`migrations-idempotency`](../../.claude/rules/migrations-idempotency.md).
- **Test DB:** corren contra una BD test dedicada · NO contra dev local · NO contra prod (cada adopter configura su TEST DB · credentials en `.env` gitignored).
- **Job CI:** ejecutados por el job `sql` del workflow remoto + `npm run test:sql` (o equivalente del stack del adopter) local.

## Archivos actuales (al boot del template)

> Al boot del template la carpeta arranca **vacía** (solo este README + `.gitkeep` cuando aplique). Cada adopter suma sus `.sql` conforme cierra PRPs del producto que tocan BD.

**Estructura sugerida cuando empiecen a aparecer specs:**

### Invariantes transversales (no atadas a 1 PRP)

| Archivo | Rol típico |
|---|---|
| `rls-invariants.sql` | Multi-tenant cross-tenant leak imposible · `pg_policies` checks |
| `helpers-shape-invariants.sql` | Shape de helpers SQL · `SECURITY DEFINER` con `search_path` · `current_user_*` STABLE · EXECUTE-grant en whitelist |
| `permission-gate-enforcement-invariant.sql` | Permission gates por rol enforced · `SECDEF + VOLATILE + anon/auth` gate O whitelist |
| `security-invoker-rpc-policy-coverage.sql` | `SECURITY INVOKER` mutating × tabla destino × policy RLS del cmd correspondiente |
| `<otro-invariante>.sql` | Invariantes específicos del dominio del adopter |

### Tests por PRP

| Archivo | PRP origen |
|---|---|
| `prp-NNN-<feature>.sql` | PRP-NNN (descripción 1-línea) |

## Carpetas hermanas

- [`tests/e2e/regression/`](../e2e/regression/) — capa UI · complementaria a estos invariantes BD.
- [`tests/manual/`](../manual/) — matriz CSV del skill [`/validar`](../../.claude/skills/validar/SKILL.md) · destino paralelo cuando el caso del CSV es de capa BD se destila acá vía PRINCIPIO 6.
- `db/migrations/` (del adopter · just-in-time cuando aparezca el primer schema) — schema + RLS + RPCs cuyos invariantes se verifican acá (paridad regla [`migrations-idempotency`](../../.claude/rules/migrations-idempotency.md)).

## Cómo agregar un test SQL nuevo

1. **Naming canónico:** `prp-NNN-<feature>.sql` o `<invariant>.sql` (transversal).
2. **Estructura:** static checks arriba (queries de assert) · mutating tests abajo (DO blocks con ROLLBACK final).
3. **Idempotencia:** los DO blocks deben dejar la BD en el mismo estado que la encontraron · `ROLLBACK` o cleanup explícito al final.
4. **Wiring CI:** el job `sql` corre `**/*.sql` automáticamente (convención del adopter · cero edit del workflow al sumar un spec nuevo).
5. **Tests del DoD por fase** (regla [`tests-as-dod-per-phase`](../../.claude/rules/tests-as-dod-per-phase.md)) · cada fase del bucle del paso 3 que toca BD cierra con sus invariantes acá.

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
