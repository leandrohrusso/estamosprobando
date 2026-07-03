-- =====================================================================
-- 0002_rls_and_helpers.sql · PRP-002 (TASK-002)
-- Helpers SECURITY DEFINER (Bif 1=A · evitan recursión de RLS sobre
-- memberships) + RLS + policies en organizations/memberships.
-- Idempotente: CREATE OR REPLACE FUNCTION + DROP POLICY IF EXISTS antes
-- de cada CREATE POLICY (regla migrations-idempotency).
-- =====================================================================

-- Helpers RLS --------------------------------------------------------
-- SECURITY DEFINER: corren como el owner (postgres · RLS-bypass sobre
-- memberships) → cero recursión al evaluar policies de memberships.
-- search_path fijado a public (anti search_path injection).
CREATE OR REPLACE FUNCTION public.is_member_of(org UUID)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org
      AND m.user_id = auth.uid()
      AND m.status = 'active'
  );
$$;

CREATE OR REPLACE FUNCTION public.has_role(org UUID, roles public.membership_role[])
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org
      AND m.user_id = auth.uid()
      AND m.status = 'active'
      AND m.role = ANY(roles)
  );
$$;

-- Grants de privilegios (RLS gatea a nivel fila · el GRANT a nivel tabla) -
GRANT SELECT, INSERT, UPDATE, DELETE ON public.organizations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.memberships   TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_member_of(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, public.membership_role[]) TO authenticated;

-- service_role (bypassa RLS · Edge Functions server-side + helper de sesión de
-- test/CI · constraint #10). Explícito y NO por default privileges: el reset de
-- schema de `test-migrations.sh` (DROP SCHEMA CASCADE · DT-002) borra los grants
-- implícitos · la migración debe ser autosuficiente. GRANT es idempotente.
GRANT ALL ON public.organizations TO service_role;
GRANT ALL ON public.memberships   TO service_role;

-- RLS ----------------------------------------------------------------
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships   ENABLE ROW LEVEL SECURITY;

-- organizations: un miembro activo ve su(s) org(s); solo Owner la edita.
-- INSERT NO tiene policy → creación solo vía RPC create_organization_with_owner.
DROP POLICY IF EXISTS org_select ON public.organizations;
CREATE POLICY org_select ON public.organizations
  FOR SELECT TO authenticated
  USING (public.is_member_of(id));

DROP POLICY IF EXISTS org_update ON public.organizations;
CREATE POLICY org_update ON public.organizations
  FOR UPDATE TO authenticated
  USING (public.has_role(id, ARRAY['owner']::public.membership_role[]))
  WITH CHECK (public.has_role(id, ARRAY['owner']::public.membership_role[]));

-- memberships: ve sus propias filas o las de una org donde es miembro activo;
-- solo Owner de la org escribe (alta/baja/cambio de rol · PRD §4 + Bif 3=A).
DROP POLICY IF EXISTS mbr_select ON public.memberships;
CREATE POLICY mbr_select ON public.memberships
  FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_member_of(organization_id));

-- Escritura owner-gated + Owner INMUTABLE a nivel RLS (LR-002 lr_bug_002):
-- el invariante single-owner (SD-cos-11 · anti-lockout) NO puede vivir solo en las
-- Server Actions · un Owner con su JWT legítimo podría, vía PostgREST directo,
-- auto-concederse un 2º Owner, promover a alguien a Owner, o borrar/mutar al Owner
-- (rompiendo el modelo). `role <> 'owner'` en USING **y** WITH CHECK cierra las
-- cuatro vías (INSERT/UPDATE del NEW row · UPDATE/DELETE del OLD row):
--   - USING role<>'owner'      → no se puede UPDATE ni DELETE la fila del Owner.
--   - WITH CHECK role<>'owner' → no se puede INSERT ni promover a Owner.
-- El Owner se crea SOLO vía la RPC create_organization_with_owner (SECURITY DEFINER ·
-- bypassa RLS). Esta policy es la última red · paridad con el guard app `.neq('role','owner')`.
DROP POLICY IF EXISTS mbr_write ON public.memberships;
CREATE POLICY mbr_write ON public.memberships
  FOR ALL TO authenticated
  USING (
    public.has_role(organization_id, ARRAY['owner']::public.membership_role[])
    AND role <> 'owner'
  )
  WITH CHECK (
    public.has_role(organization_id, ARRAY['owner']::public.membership_role[])
    AND role <> 'owner'
  );
