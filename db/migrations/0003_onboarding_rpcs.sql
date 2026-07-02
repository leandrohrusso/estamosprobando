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

CREATE OR REPLACE FUNCTION public.create_organization_with_owner(p_name TEXT, p_slug TEXT)
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

  INSERT INTO public.organizations (name, slug)
  VALUES (p_name, p_slug)
  RETURNING id INTO new_org;

  INSERT INTO public.memberships (organization_id, user_id, email, role, status)
  VALUES (new_org, auth.uid(), auth.email(), 'owner', 'active');

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

GRANT EXECUTE ON FUNCTION public.create_organization_with_owner(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.link_pending_memberships() TO authenticated;
