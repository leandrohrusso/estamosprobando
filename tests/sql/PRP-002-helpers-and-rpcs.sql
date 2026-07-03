-- =====================================================================
-- tests/sql/PRP-002-helpers-and-rpcs.sql · G3 helpers + G4/G8 RPCs
-- Rol `authenticated` + claims JWT por transacción · BEGIN..ROLLBACK.
-- =====================================================================

\i db/seeds/test/test-seed.sql

-- G3 · is_member_of / has_role (como user1 · owner de A) -------------------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001001','email','owner-a@test.puertita')::text, true);
DO $$
DECLARE org_a UUID := '00000000-0000-0000-0000-00000000a001';
        org_b UUID := '00000000-0000-0000-0000-00000000b001';
BEGIN
  IF NOT public.is_member_of(org_a)                                   THEN RAISE EXCEPTION 'FAIL: is_member_of(A) debería ser true'; END IF;
  IF     public.is_member_of(org_b)                                   THEN RAISE EXCEPTION 'FAIL: is_member_of(B) debería ser false'; END IF;
  IF NOT public.has_role(org_a, ARRAY['owner']::public.membership_role[])  THEN RAISE EXCEPTION 'FAIL: has_role(A, owner) debería ser true'; END IF;
  IF     public.has_role(org_a, ARRAY['staff']::public.membership_role[])  THEN RAISE EXCEPTION 'FAIL: has_role(A, staff) debería ser false'; END IF;
  RAISE NOTICE 'OK G3 · is_member_of/has_role correctos para user1';
END $$;
ROLLBACK;

-- G4 · create_organization_with_owner (como user3 · sin org previa) --------
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001003','email','new@test.puertita')::text, true);
DO $$
DECLARE new_org UUID; owner_cnt int;
BEGIN
  new_org := public.create_organization_with_owner('New Org', 'new-org-xyz');
  IF new_org IS NULL THEN RAISE EXCEPTION 'FAIL: RPC no retornó org id'; END IF;
  SELECT count(*) INTO owner_cnt
    FROM public.memberships
   WHERE organization_id = new_org
     AND user_id = '00000000-0000-0000-0000-000000001003'
     AND role = 'owner' AND status = 'active';
  IF owner_cnt <> 1 THEN RAISE EXCEPTION 'FAIL: user3 no quedó owner activo (got %)', owner_cnt; END IF;
  RAISE NOTICE 'OK G4 · create_organization_with_owner crea org + membership owner activo';
END $$;
ROLLBACK;

-- G8 · link_pending_memberships (como user4 · staff pending en A por email) -
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000001004','email','staff-pending@test.puertita')::text, true);
DO $$
DECLARE linked int; active_cnt int;
BEGIN
  linked := public.link_pending_memberships();
  IF linked <> 1 THEN RAISE EXCEPTION 'FAIL: se esperaba vincular 1 membership pending (got %)', linked; END IF;
  SELECT count(*) INTO active_cnt
    FROM public.memberships
   WHERE email = 'staff-pending@test.puertita'
     AND user_id = '00000000-0000-0000-0000-000000001004'
     AND status = 'active' AND role = 'staff';
  IF active_cnt <> 1 THEN RAISE EXCEPTION 'FAIL: membership pending no quedó vinculada/activa (got %)', active_cnt; END IF;
  RAISE NOTICE 'OK G8 · link_pending_memberships vincula por email y activa';
END $$;
ROLLBACK;

-- Unicidad (org, email) CASE-INSENSITIVE (LR-001 lr_bug_004) ----------------
-- Sin normalizar, 'Staff@x' y 'staff@x' coexistirían en la misma org mientras
-- el link/index usan lower() (asimetría write=crudo / read=lower). El índice
-- único uq_memberships_org_lower_email lo previene. Corre sin SET ROLE (el
-- superuser bypassa RLS · testeamos el invariante de schema, no las policies).
BEGIN;
DO $$
DECLARE dup boolean := false;
BEGIN
  INSERT INTO public.memberships (organization_id, email, role, status)
  VALUES ('00000000-0000-0000-0000-00000000a001', 'Case-Test@x.com', 'staff', 'pending');
  BEGIN
    INSERT INTO public.memberships (organization_id, email, role, status)
    VALUES ('00000000-0000-0000-0000-00000000a001', 'case-test@x.com', 'staff', 'pending');
  EXCEPTION WHEN unique_violation THEN
    dup := true;
  END;
  IF NOT dup THEN
    RAISE EXCEPTION 'FAIL: (org,email) NO es case-insensitive · Case-Test@x y case-test@x coexisten en la misma org';
  END IF;
  RAISE NOTICE 'OK · unicidad (org, lower(email)) rechaza duplicados case-insensitive';
END $$;
ROLLBACK;
