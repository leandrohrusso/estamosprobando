-- =====================================================================
-- RPCs · GRANT EXECUTE a service_role · template universal Postgres + Supabase
-- =====================================================================
-- > ⚙️ **Stack adaptation banner:** asume stack Postgres + Supabase
-- > (RPCs declaradas como `CREATE FUNCTION ... SECURITY DEFINER` en
-- > `db/migrations/` + clientes admin tipo `createAdminClient()` que
-- > operan con rol `service_role`). Si tu stack NO usa Supabase ni
-- > rol `service_role`, este spec NO aplica · descartá el archivo o
-- > adaptalo al rol admin equivalente de tu stack (ej: `postgres` ·
-- > `admin_role` · custom role).
-- =====================================================================
-- **Invariante (defense-in-depth):** toda RPC `SECURITY DEFINER`
-- consumida por un cliente admin (rol `service_role`) DEBE tener
-- `GRANT EXECUTE` a `service_role`. Sin esto, callers admin reciben
-- `permission denied (code 42501)` y silenciosamente caen a defaults
-- o rompen runtime cuando una Server Action invoca la RPC.
--
-- **Cómo usar (adopter):** llenar la lista `v_rpcs` (en los 2 DO blocks)
-- con los nombres de las RPCs admin-callable del proyecto (las que
-- `createAdminClient()` u equivalente invoca). Al boot del template la
-- lista está vacía · el spec emite `NOTICE` y termina sin falla (skip
-- seguro). Cuando se llena, el spec corre 2 tests cross-check:
--   - **TEST 1:** `information_schema.routine_privileges`
--     (`grantee=service_role` · `privilege=EXECUTE`).
--   - **TEST 2:** `pg_proc.proacl` (representación interna del ACL ·
--     busca patrón `service_role=X%`).
--
-- **Pattern de migración idempotente** para sumar el GRANT (paridad
-- regla #32 `migrations-idempotency.md`):
--
--   GRANT EXECUTE ON FUNCTION public.<rpc_name>(<args>) TO service_role;
--   -- GRANT es idempotente · doble GRANT es noop · cero `IF NOT EXISTS` necesario.
--
-- **Cross-ref firme:** regla #15 [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)
-- (spec ANTES del fix · este spec falla pre-mig nueva · pasa post-mig).
-- =====================================================================

\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
  -- TODO adopter: llenar con las RPCs admin-callable del proyecto.
  -- Ejemplo: v_rpcs text[] := ARRAY['cancel_order', 'mark_order_paid'];
  v_rpcs text[] := ARRAY[]::text[];
  v_rpc text;
  v_count integer;
  v_failures text := '';
BEGIN
  IF cardinality(v_rpcs) = 0 THEN
    RAISE NOTICE 'TEST 1 SKIP: lista v_rpcs vacía · adopter declara su cluster en líneas marcadas con TODO';
    RETURN;
  END IF;

  -- TEST 1: cada RPC del cluster tiene ≥1 entry en information_schema
  -- .routine_privileges para grantee=service_role · privilege=EXECUTE.
  FOREACH v_rpc IN ARRAY v_rpcs LOOP
    SELECT count(*) INTO v_count
    FROM information_schema.routine_privileges
    WHERE routine_schema = 'public'
      AND routine_name = v_rpc
      AND grantee = 'service_role'
      AND privilege_type = 'EXECUTE';

    IF v_count = 0 THEN
      v_failures := v_failures || format(E'\n  - %s', v_rpc);
    END IF;
  END LOOP;

  IF v_failures != '' THEN
    RAISE EXCEPTION 'TEST 1 FAIL: RPCs sin EXECUTE a service_role:%', v_failures;
  END IF;

  RAISE NOTICE 'TEST 1 OK: %/% RPCs del cluster tienen EXECUTE a service_role',
    cardinality(v_rpcs), cardinality(v_rpcs);
END $$;

DO $$
DECLARE
  -- TODO adopter: misma lista que el TEST 1 arriba (mantener sincronizadas).
  v_rpcs text[] := ARRAY[]::text[];
  v_rpc text;
  v_proacl text;
  v_failures text := '';
BEGIN
  IF cardinality(v_rpcs) = 0 THEN
    RAISE NOTICE 'TEST 2 SKIP: lista v_rpcs vacía · adopter declara su cluster';
    RETURN;
  END IF;

  -- TEST 2: cross-check vía pg_proc.proacl (representación interna del
  -- ACL · busca patrón "service_role=X%").
  FOREACH v_rpc IN ARRAY v_rpcs LOOP
    SELECT proacl::text INTO v_proacl
    FROM pg_proc
    WHERE proname = v_rpc
      AND pronamespace = 'public'::regnamespace
    LIMIT 1;

    IF v_proacl IS NULL OR v_proacl NOT LIKE '%service_role=X%' THEN
      v_failures := v_failures || format(E'\n  - %s (proacl=%s)', v_rpc, COALESCE(v_proacl, 'NULL'));
    END IF;
  END LOOP;

  IF v_failures != '' THEN
    RAISE EXCEPTION 'TEST 2 FAIL: pg_proc.proacl sin service_role=X:%', v_failures;
  END IF;

  RAISE NOTICE 'TEST 2 OK: pg_proc.proacl confirma service_role=X en %/% RPCs',
    cardinality(v_rpcs), cardinality(v_rpcs);
END $$;

DO $$
BEGIN
  RAISE NOTICE 'rpcs-grant-service-role-invariant: ALL TESTS PASSED (2/2)';
END $$;

ROLLBACK;
