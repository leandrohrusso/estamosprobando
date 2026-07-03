-- =====================================================================
-- 0001_organizations_and_memberships.sql · PRP-002 (TASK-002)
-- Tenancy base: organizations + memberships + enums de rol/estado.
-- Idempotente (regla migrations-idempotency): CREATE ... IF NOT EXISTS +
-- bloques DO $$ EXCEPTION WHEN duplicate_object para los enums.
-- =====================================================================

-- Enums --------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE public.membership_role AS ENUM ('owner', 'admin', 'staff');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.membership_status AS ENUM ('pending', 'active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- organizations (tenant) ---------------------------------------------
CREATE TABLE IF NOT EXISTS public.organizations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  slug                TEXT NOT NULL UNIQUE,
  payment_account_ref TEXT,
  fee_pct             NUMERIC(5,2) NOT NULL DEFAULT 0,
  fee_fixed           INTEGER      NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- memberships (usuario ↔ org con rol) --------------------------------
-- user_id NULL mientras la membership está `pending` (invitación por email
-- sin cuenta vinculada todavía · se vincula al login · PRP-002 Bif 3=A).
CREATE TABLE IF NOT EXISTS public.memberships (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email           TEXT NOT NULL,
  role            public.membership_role   NOT NULL DEFAULT 'staff',
  status          public.membership_status NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_memberships_user  ON public.memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_org   ON public.memberships(organization_id);
CREATE INDEX IF NOT EXISTS idx_memberships_email ON public.memberships(lower(email));
-- hot-path de los helpers RLS is_member_of()/has_role() (org + user + status)
CREATE INDEX IF NOT EXISTS idx_memberships_org_user_status
  ON public.memberships(organization_id, user_id, status);

-- Unicidad de membership por (org, email) CASE-INSENSITIVE: el email es un
-- identificador (no display). Sin esto, 'Staff@x' y 'staff@x' coexistirían en la
-- misma org y ambas podrían activarse, mientras que el link/index usan lower()
-- (asimetría write=crudo / read=lower · LR-001 lr_bug_004). Índice de expresión
-- en vez de constraint inline para poder normalizar sobre lower(email).
-- Idempotente: DROP del constraint viejo (no-op si ya no existe) + índice IF NOT EXISTS.
ALTER TABLE public.memberships DROP CONSTRAINT IF EXISTS memberships_organization_id_email_key;
CREATE UNIQUE INDEX IF NOT EXISTS uq_memberships_org_lower_email
  ON public.memberships(organization_id, lower(email));

-- Clave de idempotencia del onboarding (LR-002 lr_bug_008): el request de creación
-- de organización lleva un UUID estable por submit · create_organization_with_owner
-- reusa la org ya creada si el mismo (user, request) reintenta (double-submit /
-- retry tras respuesta perdida) en vez de crear una 2ª org. NULL en las memberships
-- que no vienen del onboarding (alta por email · Bif 3=A). El índice único parcial
-- serializa dos requests concurrentes con la misma clave (backstop del fast-path).
ALTER TABLE public.memberships ADD COLUMN IF NOT EXISTS idempotency_key UUID;
CREATE UNIQUE INDEX IF NOT EXISTS uq_memberships_user_idempotency
  ON public.memberships(user_id, idempotency_key)
  WHERE idempotency_key IS NOT NULL;

COMMENT ON TABLE public.organizations IS 'Tenant. Cada dato de negocio pertenece a exactamente una organización (PRD §3.1).';
COMMENT ON TABLE public.memberships   IS 'Relación usuario↔org con rol. RLS lee la pertenencia vía esta tabla (PRP-002).';
