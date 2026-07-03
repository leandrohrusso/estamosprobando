-- =====================================================================
-- tests/sql/PRP-002-rls-isolation.sql · G2 aislamiento cross-tenant
-- Simula el rol `authenticated` + claims JWT (auth.uid()) por transacción.
-- Cada escenario en BEGIN..ROLLBACK: cero drift del seed.
-- Falla con RAISE EXCEPTION (ON_ERROR_STOP → exit 1) · verde con NOTICE.
-- =====================================================================

\i db/seeds/test/test-seed.sql

-- Escenario 1 · user1 (owner de A) NO ve datos de la org B ------------------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
DO $$
DECLARE org_a int; org_b int; mbr_b int;
BEGIN
  SELECT count(*) INTO org_a FROM public.organizations WHERE slug = 'test-org-a';
  SELECT count(*) INTO org_b FROM public.organizations WHERE slug = 'test-org-b';
  SELECT count(*) INTO mbr_b FROM public.memberships   WHERE organization_id = '00000000-0000-0000-0000-00000000b001';
  IF org_a <> 1 THEN RAISE EXCEPTION 'FAIL: user1 no ve su org A (got %)', org_a; END IF;
  IF org_b <> 0 THEN RAISE EXCEPTION 'FAIL cross-tenant: user1 VE org B ajena (got %)', org_b; END IF;
  IF mbr_b <> 0 THEN RAISE EXCEPTION 'FAIL cross-tenant: user1 VE memberships de B (got %)', mbr_b; END IF;
  RAISE NOTICE 'OK G2.1 · user1 ve A(1) · NO ve B(orgs=0, memberships=0)';
END $$;
ROLLBACK;

-- Escenario 2 · user2 (owner de B) NO ve datos de la org A ------------------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001002','email','owner-b@test.puertita')::text, true);
DO $$
DECLARE org_a int; org_b int;
BEGIN
  SELECT count(*) INTO org_a FROM public.organizations WHERE slug = 'test-org-a';
  SELECT count(*) INTO org_b FROM public.organizations WHERE slug = 'test-org-b';
  IF org_b <> 1 THEN RAISE EXCEPTION 'FAIL: user2 no ve su org B (got %)', org_b; END IF;
  IF org_a <> 0 THEN RAISE EXCEPTION 'FAIL cross-tenant: user2 VE org A ajena (got %)', org_a; END IF;
  RAISE NOTICE 'OK G2.2 · user2 ve B(1) · NO ve A(0)';
END $$;
ROLLBACK;

-- Escenario 3 · usuario autenticado sin membership NO ve ninguna org --------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001003','email','new@test.puertita')::text, true);
DO $$
DECLARE total int;
BEGIN
  SELECT count(*) INTO total FROM public.organizations;
  IF total <> 0 THEN RAISE EXCEPTION 'FAIL: usuario sin membership VE % orgs (esperado 0)', total; END IF;
  RAISE NOTICE 'OK G2.3 · usuario sin membership ve 0 orgs';
END $$;
ROLLBACK;

-- ===========================================================================
-- Aislamiento cross-tenant del lado WRITE (LR-001 lr_bug_001).
-- Escribir una membership = conceder acceso a un tenant → la ruta de mutación
-- es la más peligrosa para constraint #1. Verifica que mbr_write / org_update
-- (owner-gated) bloquean la escritura cross-tenant y la escritura de no-owners.
-- ===========================================================================

-- Escenario 4 · owner de A NO puede INSERT una membership en la org B ---------
-- (WITH CHECK has_role(B, owner) = false → RLS rechaza · error 42501).
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
DO $$
DECLARE blocked boolean := false;
BEGIN
  BEGIN
    INSERT INTO public.memberships (organization_id, email, role, status)
    VALUES ('00000000-0000-0000-0000-00000000b001', 'intruso@test.puertita', 'admin', 'active');
  EXCEPTION WHEN insufficient_privilege THEN
    blocked := true;
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'FAIL cross-tenant WRITE: owner de A pudo INSERT membership en org B'; END IF;
  RAISE NOTICE 'OK G-write.4 · owner de A NO puede escribir memberships de B';
END $$;
ROLLBACK;

-- Escenario 5 · owner de A NO puede UPDATE la org B (RLS filtra USING → 0 filas)
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
DO $$
DECLARE n int;
BEGIN
  UPDATE public.organizations SET name = 'hijacked' WHERE id = '00000000-0000-0000-0000-00000000b001';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 0 THEN RAISE EXCEPTION 'FAIL cross-tenant WRITE: owner de A pudo UPDATE org B (% filas)', n; END IF;
  RAISE NOTICE 'OK G-write.5 · owner de A NO puede UPDATE org B (0 filas)';
END $$;
ROLLBACK;

-- Escenario 6 · owner de A NO puede DELETE una membership de la org B ---------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
DO $$
DECLARE n int;
BEGIN
  DELETE FROM public.memberships WHERE organization_id = '00000000-0000-0000-0000-00000000b001';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 0 THEN RAISE EXCEPTION 'FAIL cross-tenant WRITE: owner de A pudo DELETE memberships de B (% filas)', n; END IF;
  RAISE NOTICE 'OK G-write.6 · owner de A NO puede DELETE memberships de B (0 filas)';
END $$;
ROLLBACK;

-- Escenario 7 · un miembro NO-owner de A (staff) NO puede escribir memberships
-- de su PROPIA org (mbr_write es owner-gated · no todo miembro puede invitar).
BEGIN;
SET LOCAL ROLE authenticated;
-- 1) como owner de A, dar de alta un staff activo (user3) en A (permitido).
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
INSERT INTO public.memberships (organization_id, user_id, email, role, status)
VALUES ('00000000-0000-0000-0000-00000000a001', '00000000-0000-0000-0000-000000001003', 'staff3@test.puertita', 'staff', 'active');
-- 2) ahora, como ese staff, intentar invitar a otra persona a A → bloqueado.
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001003','email','staff3@test.puertita')::text, true);
DO $$
DECLARE blocked boolean := false;
BEGIN
  BEGIN
    INSERT INTO public.memberships (organization_id, email, role, status)
    VALUES ('00000000-0000-0000-0000-00000000a001', 'invitado-por-staff@test.puertita', 'staff', 'pending');
  EXCEPTION WHEN insufficient_privilege THEN
    blocked := true;
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'FAIL: un staff (no-owner) de A pudo escribir memberships de A'; END IF;
  RAISE NOTICE 'OK G-write.7 · staff no-owner de A NO puede escribir memberships (owner-gate)';
END $$;
ROLLBACK;
