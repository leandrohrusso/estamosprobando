-- =====================================================================
-- Permission gate enforcement invariant · template universal Postgres + Supabase
-- =====================================================================
-- > ⚙️ **Stack adaptation banner:** asume stack Postgres + Supabase Auth
-- > (roles `anon` · `authenticated` · `service_role` · funciones
-- > `auth.uid()` · `auth.jwt()`). Si tu stack NO usa Supabase Auth (ej:
-- > Firebase rules · custom JWT middleware app-level · roles Postgres
-- > custom), adaptá: los nombres de roles + el regex que matchea gates
-- > en `prosrc` (línea 137) son los puntos de extensión. El principio
-- > (RPCs `SECURITY DEFINER` mutating callable por roles externos NO
-- > pueden saltarse el permission gate) es universal de cualquier
-- > arquitectura multi-tenant con RLS.
-- =====================================================================
-- **Invariante (DATA-LAYER · defense-in-depth multi-tenant):** toda RPC
-- `SECURITY DEFINER + VOLATILE + prokind='f'` con `EXECUTE` granted a
-- `anon` o `authenticated` DEBE:
--   - (a) llamar permission gate dentro del cuerpo (regex sobre
--     `prosrc` matchea `current_user_has_perm` · `current_user_is_super_admin`
--     · `auth\.uid\(\)`); O
--   - (b) estar en `permission_gate_whitelist` con razón firmada por
--     categoría.
--
-- **Por qué este invariante existe (universal):** `SECURITY DEFINER`
-- ejecuta con permisos del owner · bypassa RLS de la tabla. Si la RPC
-- no llama un permission gate explícito, el caller puede invocar la RPC
-- sin restricción de tenant o role. Para RPCs `VOLATILE` (mutating)
-- callable por `anon`/`authenticated`, esto es vector cross-tenant
-- write directo. Las RPCs con grantees solo `postgres` o `service_role`
-- (server trusted) NO necesitan gate interno: el cliente nunca las
-- invoca directo · quedan FUERA del scope del invariante.
--
-- **Cobertura en 3 capas universales:**
--   - **Este spec (DATA-LAYER):** enumera SECDEF+VOLATILE+anon/auth y
--     asserts gate explícito O whitelist.
--   - **Helpers shape (DATA-LAYER):** `helpers-shape-invariants.sql`
--     cubre shape (search_path · STABLE para current_user_*) y EXECUTE-
--     grant a anon/authenticated en whitelist.
--   - **SQL runtime per-RPC:** specs `prp-NNN-<rpc>-perm-gates.sql` que
--     cada PRP suma para validar el gate explícito en RPCs específicas.
--
-- **Cómo usar (adopter):** llenar `permission_gate_whitelist` con las
-- RPCs server-trusted del proyecto que NO requieren gate por diseño
-- (stock atómico · generators · pixel público · resolver auth-by-
-- knowledge · etc · cada entrada con razón firmada por categoría). Al
-- boot del template la whitelist está vacía · INV-A corre sobre las
-- funciones reales del adopter (si el schema está vacío, 0 RPCs a
-- verificar · spec pasa trivialmente).
--
-- **Cross-ref firme:** regla #8 [`quality-standard-senior.md`](../../.claude/rules/quality-standard-senior.md)
-- (multi-tenant strict + cero escapes silenciosos) + regla #15
-- [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)
-- (spec ANTES del fix) + regla #35 [`agents-conditional-by-domain.md`](../../.claude/rules/agents-conditional-by-domain.md)
-- (típicamente activado por adopter con `multi-tenant.enabled: yes`).
-- =====================================================================

\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
  v_proname  text;
  v_prosrc   text;
  v_grantees text[];
  v_count    int;
BEGIN
  -- ----- Setup whitelists --------------------------------------------------
  CREATE TEMP TABLE IF NOT EXISTS permission_gate_whitelist (
    proname text PRIMARY KEY,
    reason  text NOT NULL
  ) ON COMMIT DROP;

  -- TODO adopter: llenar con las RPCs SECURITY DEFINER server-trusted
  -- del proyecto que NO requieren gate por diseño. Categorías típicas
  -- con razón firmada:
  --
  --   - Stock atómico (server trusted invocado desde Server Action
  --     authenticated · checkout/cancel/refund flow):
  --       ('decrement_stock', 'Stock atómico · server trusted invocado desde Server Action authenticated.')
  --
  --   - Generators sin PII (usado en checkout flow authenticated):
  --       ('generate_order_number', 'Generator sin PII · server trusted en checkout flow.')
  --
  --   - Pixel público (callable por anon · contador analytics sin
  --     escritura sensible):
  --       ('track_click', 'Pixel público · callable por anon · sin escritura sensible.')
  --
  --   - Resolver auth-by-knowledge (short code es el secret · callable
  --     por anon desde URL pública):
  --       ('resolve_branding', 'Resolver auth-by-knowledge · short code es el secret.')
  --
  --   - RPC público read-only con cascada safe-fail:
  --       ('validate_coupon', 'RPC público read-only · preview en checkout · cero UPDATE.')

  -- Trigger fns: prokind='f' pero rettype='trigger' · no callable
  -- directo · se ejecutan implícitamente desde el trigger del schema ·
  -- NO requieren gate interno. La whitelist se auto-popula desde
  -- pg_proc (cero adopter input para esta lista).
  CREATE TEMP TABLE IF NOT EXISTS trigger_fn_excluded (proname text PRIMARY KEY) ON COMMIT DROP;
  INSERT INTO trigger_fn_excluded (proname)
  SELECT p.proname
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.prokind = 'f'
    AND p.prorettype = 'trigger'::regtype;

  -- =====================================================================
  -- INV-A · Cada SECURITY DEFINER + VOLATILE + EXECUTE-grant anon/auth
  --         debe llamar gate o estar en whitelist
  -- =====================================================================
  -- Postgres encoda los grantees en proacl como `<role>=X*/<owner>`.
  -- Extraemos la parte antes de `=` para cada elemento del array.
  FOR v_proname, v_prosrc, v_grantees IN
    SELECT
      p.proname,
      p.prosrc,
      coalesce(
        (SELECT array_agg(DISTINCT split_part(g, '=', 1))
         FROM unnest(p.proacl::text[]) AS g),
        ARRAY[]::text[]
      )
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND p.prosecdef = true
      AND p.provolatile = 'v'
      AND p.prorettype != 'trigger'::regtype
      AND p.proname NOT IN (SELECT proname FROM trigger_fn_excluded)
  LOOP
    -- Solo aplica el invariante si la RPC es callable por anon o
    -- authenticated. Server trusted (postgres + service_role only)
    -- queda fuera del scope.
    IF NOT ('anon' = ANY(v_grantees) OR 'authenticated' = ANY(v_grantees)) THEN
      CONTINUE;
    END IF;

    -- Verificar si tiene gate explícito en el cuerpo. TODO adopter:
    -- ajustar el regex si tu stack usa nombres distintos de helpers de
    -- permisos (ej: `has_permission` · `is_admin` · `auth.user_id()` ·
    -- etc · paridad regla #35 flag `multi-tenant.enabled`).
    IF v_prosrc ~* 'current_user_has_perm|current_user_is_super_admin|auth\.uid\(\)' THEN
      CONTINUE; -- gate presente → OK
    END IF;

    -- No tiene gate · debe estar en whitelist.
    SELECT count(*) INTO v_count
    FROM permission_gate_whitelist
    WHERE proname = v_proname;

    ASSERT v_count = 1,
      format(
        'INV-A: función %I es SECURITY DEFINER + VOLATILE + EXECUTE-granted a %s '
        'pero NO llama permission gate (current_user_has_perm / '
        'current_user_is_super_admin / auth.uid()) y NO está en whitelist. '
        'Acción: '
        '(a) si la RPC requiere gate por permission/role, agregar la llamada en el cuerpo; '
        '(b) si es server trusted (stock · generator · pixel · resolver público) y NO requiere '
        'gate por diseño, agregar entrada a permission_gate_whitelist con razón firmada por '
        'categoría; '
        '(c) si NO debería ser callable por anon/authenticated, '
        'REVOKE EXECUTE FROM anon, authenticated y dejar grantees server-only.',
        v_proname, array_to_string(v_grantees, ',')
      );
  END LOOP;
  RAISE NOTICE 'INV-A OK · % entrada(s) whitelist verificada(s) + gates implícitos',
    (SELECT count(*) FROM permission_gate_whitelist);

  -- =====================================================================
  -- INV-B · Whitelist sin entradas huérfanas
  -- =====================================================================
  -- Si un PRP de cleanup remueve una RPC, sacarla del whitelist también.
  FOR v_proname IN
    SELECT proname FROM permission_gate_whitelist
    WHERE proname NOT IN (
      SELECT p.proname FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public' AND p.prokind = 'f'
    )
  LOOP
    ASSERT false,
      format(
        'INV-B: permission_gate_whitelist menciona %I pero no existe en pg_proc. '
        'Limpiar entrada del whitelist.',
        v_proname
      );
  END LOOP;
  RAISE NOTICE 'INV-B OK · whitelist sin entradas huérfanas (% entradas)',
    (SELECT count(*) FROM permission_gate_whitelist);

  RAISE NOTICE 'permission-gate-enforcement-invariant: ALL CHECKS PASSED (2/2)';
END $$;

ROLLBACK;
