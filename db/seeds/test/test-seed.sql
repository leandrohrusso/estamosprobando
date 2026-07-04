-- =====================================================================
-- db/seeds/test/test-seed.sql · fixtures durables de la TEST DB · PRP-002
-- UPSERT con UUIDs fijos (regla seed-upsert-with-fixed-id): re-aplicar el
-- seed restaura el estado canónico si un spec previo lo drift-eó.
-- =====================================================================

-- Usuarios de test (auth.users solo exige `id`; email para auth.email()) ----
INSERT INTO auth.users (id, email) VALUES
  ('00000000-0000-0000-0000-000000001001', 'owner-a@test.puertita'),
  ('00000000-0000-0000-0000-000000001002', 'owner-b@test.puertita'),
  ('00000000-0000-0000-0000-000000001003', 'new@test.puertita'),
  ('00000000-0000-0000-0000-000000001004', 'staff-pending@test.puertita')
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

-- Organizaciones (2 tenants A/B para el test de aislamiento) ----------------
INSERT INTO public.organizations (id, name, slug, payment_account_ref, fee_pct, fee_fixed) VALUES
  ('00000000-0000-0000-0000-00000000a001', 'Test Org A', 'test-org-a', NULL, 0, 0),
  ('00000000-0000-0000-0000-00000000b001', 'Test Org B', 'test-org-b', NULL, 0, 0)
ON CONFLICT (id) DO UPDATE SET
  name                = EXCLUDED.name,
  slug                = EXCLUDED.slug,
  payment_account_ref = EXCLUDED.payment_account_ref,
  fee_pct             = EXCLUDED.fee_pct,
  fee_fixed           = EXCLUDED.fee_fixed;

-- Memberships --------------------------------------------------------------
-- m1: owner activo de A · m2: owner activo de B · m3: staff PENDING en A
-- (user_id NULL · para el test de link_pending_memberships).
INSERT INTO public.memberships (id, organization_id, user_id, email, role, status) VALUES
  ('00000000-0000-0000-0000-00000000e001', '00000000-0000-0000-0000-00000000a001', '00000000-0000-0000-0000-000000001001', 'owner-a@test.puertita', 'owner', 'active'),
  ('00000000-0000-0000-0000-00000000e002', '00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-000000001002', 'owner-b@test.puertita', 'owner', 'active'),
  ('00000000-0000-0000-0000-00000000e003', '00000000-0000-0000-0000-00000000a001', NULL, 'staff-pending@test.puertita', 'staff', 'pending')
ON CONFLICT (id) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  user_id         = EXCLUDED.user_id,
  email           = EXCLUDED.email,
  role            = EXCLUDED.role,
  status          = EXCLUDED.status;
