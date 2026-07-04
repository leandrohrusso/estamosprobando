-- =====================================================================
-- 0003_onboarding_rpcs.sql · PRP-002 (TASK-002)
-- RPCs SECURITY DEFINER de onboarding:
--   - create_organization_with_owner: resuelve el chicken-and-egg de RLS
--     (un usuario sin membership no puede insertar su propia membership
--     Owner bajo la policy owner-gated) creando org + membership Owner
--     atómicamente (SD-cos-1).
--   - link_pending_memberships: vincula memberships `pending` por email al
--     login (SD-cos-2 · Bif 3=A).
-- Idempotente: CREATE OR REPLACE FUNCTION.
-- =====================================================================

-- La firma vieja (TEXT, TEXT) queda como overload huérfano si solo hacemos
-- CREATE OR REPLACE con la firma nueva (Postgres identifica funciones por nombre +
-- tipos de args). DROP idempotente para que re-aplicar la migración deje SOLO la
-- firma de 3 args (con idempotencia · LR-002 lr_bug_008).
DROP FUNCTION IF EXISTS public.create_organization_with_owner(TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.create_organization_with_owner(
  p_name TEXT, p_slug TEXT, p_request_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  new_org UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'no session' USING errcode = '28000';
  END IF;

  -- Idempotencia por request (LR-002 lr_bug_008 · Bif A firmada user): si este
  -- usuario ya creó una org con este p_request_id, la devolvemos en vez de crear una
  -- segunda (double-submit / retry tras respuesta perdida). La clave es por
  -- (user, request) · NO gatea a "0 memberships" → preserva multi-org. El índice
  -- único parcial uq_memberships_user_idempotency serializa el caso concurrente.
  SELECT m.organization_id INTO new_org
    FROM public.memberships m
   WHERE m.user_id = auth.uid()
     AND m.idempotency_key = p_request_id
   LIMIT 1;
  IF FOUND THEN
    RETURN new_org;
  END IF;

  INSERT INTO public.organizations (name, slug)
  VALUES (p_name, p_slug)
  RETURNING id INTO new_org;

  -- email normalizado a lower() · consistente con el índice único
  -- uq_memberships_org_lower_email y con link_pending_memberships (LR-001 lr_bug_004).
  INSERT INTO public.memberships (organization_id, user_id, email, role, status, idempotency_key)
  VALUES (new_org, auth.uid(), lower(auth.email()), 'owner', 'active', p_request_id);

  RETURN new_org;
END;
$$;

CREATE OR REPLACE FUNCTION public.link_pending_memberships()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  n integer;
BEGIN
  IF auth.uid() IS NULL OR auth.email() IS NULL THEN
    RETURN 0;
  END IF;

  UPDATE public.memberships
     SET user_id = auth.uid(),
         status  = 'active'
   WHERE user_id IS NULL
     AND lower(email) = lower(auth.email());

  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_organization_with_owner(TEXT, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.link_pending_memberships() TO authenticated;
