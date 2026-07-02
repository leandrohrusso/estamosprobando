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
