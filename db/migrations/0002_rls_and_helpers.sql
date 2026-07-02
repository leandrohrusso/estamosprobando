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

DROP POLICY IF EXISTS mbr_write ON public.memberships;
CREATE POLICY mbr_write ON public.memberships
  FOR ALL TO authenticated
  USING (public.has_role(organization_id, ARRAY['owner']::public.membership_role[]))
  WITH CHECK (public.has_role(organization_id, ARRAY['owner']::public.membership_role[]));
