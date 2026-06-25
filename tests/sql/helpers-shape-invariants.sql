-- =====================================================================
-- Helpers shape invariants · template universal Postgres + Supabase
-- =====================================================================
-- > ⚙️ **Stack adaptation banner:** asume stack Postgres + Supabase con
-- > funciones declaradas en `db/migrations/` (mix `SECURITY DEFINER` +
-- > `SECURITY INVOKER` · `STABLE` / `VOLATILE` · trigger fns · helpers
-- > de RLS tipo `current_user_*`). Si tu stack NO usa Postgres ni
-- > Supabase Auth (Firebase rules · GraphQL middleware · etc), este spec
-- > NO aplica · descartá el archivo o adaptalo al security model
-- > equivalente. Los 4 invariantes (A search_path · B EXECUTE-grant
-- > whitelist · C STABLE para helpers RLS · D huérfanos) son patrones
-- > universales de Postgres + el shape `temp table whitelist + DO block
-- > de assert` es replicable.
-- =====================================================================
-- **Por qué este spec existe (universal):** sin un invariante central
-- que enumere TODAS las funciones del schema `public` y verifique shape,
-- cada PRP verifica solo lo que SU PRP introdujo · helpers nuevos en
-- PRPs futuros pueden quedar sin `search_path`, con `EXECUTE` a anon/
-- authenticated sin whitelist, o con `current_user_*` marcado VOLATILE
-- por error (planner degrada O(N²) en RLS con joins). Este spec atrapa
-- el drift en CI antes del merge.
--
-- **Invariantes verificadas:**
--   - **INV-A** · Cada `SECURITY DEFINER` tiene `search_path` configurado
--     (`proconfig != NULL` · `proconfig ILIKE '%search_path%'`). Sin
--     `search_path`, advisor Supabase alarma (vulnerable a search_path
--     attacks · caller setea search_path antes de invocar y la función
--     resuelve nombres ambiguos hacia objetos hostiles del caller).
--   - **INV-B** · `SECURITY DEFINER + VOLATILE + non-trigger` con
--     `EXECUTE` granted a `anon`/`authenticated`: o llama gate
--     (regex sobre `prosrc`) o está en `public_definer_whitelist` con
--     razón firmada por categoría.
--   - **INV-C** · Helpers canónicos RLS (típicamente `current_user_*`)
--     deben ser `STABLE`. Si un PR los marca `VOLATILE` por error, el
--     planner re-evalúa por row → RLS con joins puede degradar a O(N²).
--   - **INV-D** · Whitelists sin entradas huérfanas (RPC removida en
--     PRP de cleanup → limpiar la entrada del whitelist).
--
-- **Cómo usar (adopter):** llenar las 3 whitelists temporales con las
-- RPCs/funciones del proyecto (ver TODO adopter inline en cada bloque
-- `INSERT INTO`). Al boot del template las 3 listas están vacías · los
-- 4 invariantes corren sobre `pg_proc` del schema `public` real del
-- adopter · si el schema está vacío (cero migraciones aplicadas), el
-- spec pasa trivialmente (0 funciones a verificar).
--
-- **Cross-ref firme:** regla #15 [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)
-- (spec ANTES del fix · este spec falla pre-mig que viola shape · pasa
-- post-mig que cumple) + regla #35 [`agents-conditional-by-domain.md`](../../.claude/rules/agents-conditional-by-domain.md)
-- (típicamente activado por adopter con `multi-tenant.enabled: yes`).
-- =====================================================================

\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
  v_proname     text;
  v_proconfig   text;
  v_grantees    text[];
  v_count       int;
BEGIN
  -- ----- Setup whitelists --------------------------------------------
  -- WHITELIST 1 · SECURITY DEFINER que SÍ pueden ser EXECUTE-granted a
  -- anon/authenticated. Cada entrada documenta por qué (categoría +
  -- razón firmada).
  CREATE TEMP TABLE IF NOT EXISTS public_definer_whitelist (
    rpc_name text PRIMARY KEY,
    reason   text NOT NULL
  ) ON COMMIT DROP;

  -- TODO adopter: llenar con las RPCs SECURITY DEFINER que tu proyecto
  -- expone intencionalmente a anon/authenticated. Categorías típicas:
  --   - Helpers canónicos RLS (current_user_*) → EXECUTE a authenticated.
  --   - Pixel público anon (track_*, count_*) → EXECUTE a anon.
  --   - Resolver auth-by-knowledge (short code = secret) → EXECUTE a anon.
  --   - Stock atómico server-trusted → EXECUTE a authenticated.
  --   - Generators sin PII → EXECUTE a authenticated.
  --   - Soft-delete del backoffice → EXECUTE a authenticated.
  -- Ejemplo:
  --   INSERT INTO public_definer_whitelist (rpc_name, reason) VALUES
  --     ('current_user_has_perm', 'Helper RLS canónico · EXECUTE a authenticated · filtra internamente por auth.uid().'),
  --     ('track_click', 'Pixel público anon · contador analytics sin escritura sensible.');

  -- WHITELIST 2 · Trigger fns sin EXECUTE a roles externos. Las trigger
  -- fns se ejecutan implícitamente desde el trigger del schema · NO
  -- requieren GRANT a roles externos · roles externos no pueden
  -- invocarlas directo.
  CREATE TEMP TABLE IF NOT EXISTS trigger_fn_whitelist (proname text PRIMARY KEY) ON COMMIT DROP;

  -- TODO adopter: llenar con las trigger fns del schema (típicamente
  -- `set_updated_at` · `handle_new_user` · validaciones constraint-like).
  -- Ejemplo:
  --   INSERT INTO trigger_fn_whitelist (proname) VALUES
  --     ('set_updated_at'),
  --     ('handle_new_user');

  -- WHITELIST 3 · Helpers canónicos del modelo RLS que DEBEN ser STABLE.
  -- Estos son los `current_user_*` (o equivalente del adopter) que
  -- typicamente se invocan dentro de RLS policies via auth.uid().
  CREATE TEMP TABLE IF NOT EXISTS rls_canonical_helpers (proname text PRIMARY KEY) ON COMMIT DROP;

  -- TODO adopter: llenar con los helpers de RLS canónicos del proyecto
  -- (los que se invocan desde policies USING/WITH CHECK).
  -- Ejemplo:
  --   INSERT INTO rls_canonical_helpers (proname) VALUES
  --     ('current_user_has_perm'),
  --     ('current_user_is_super_admin');

  -- ====================================================================
  -- INV-A · SECURITY DEFINER → proconfig contiene search_path
  -- ====================================================================
  FOR v_proname, v_proconfig IN
    SELECT p.proname, p.proconfig::text
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.prokind = 'f' AND p.prosecdef = true
  LOOP
    ASSERT v_proconfig IS NOT NULL AND v_proconfig ILIKE '%search_path%',
      format(
        'INV-A: SECURITY DEFINER %s no tiene search_path en proconfig (got: %s). '
        'Fix: ALTER FUNCTION %s SET search_path = public, pg_catalog. '
        'Advisor Supabase alarma esto (search_path attacks).',
        v_proname, COALESCE(v_proconfig, 'NULL'), v_proname
      );
  END LOOP;
  SELECT count(*) INTO v_count FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public' AND p.prokind = 'f' AND p.prosecdef = true;
  RAISE NOTICE 'INV-A OK · % SECURITY DEFINER con search_path', v_count;

  -- ====================================================================
  -- INV-B · SECURITY DEFINER mutating · EXECUTE solo en whitelist
  -- ====================================================================
  -- Para cada SECURITY DEFINER que NO es trigger fn: si tiene EXECUTE
  -- granted a 'anon' o 'authenticated', debe figurar en
  -- public_definer_whitelist.
  --
  -- Postgres encoda los grantees en proacl como `<role>=X*/<owner>`.
  -- Extraemos la parte antes de `=` para cada elemento del array.
  FOR v_proname, v_grantees IN
    SELECT
      p.proname,
      coalesce(
        (SELECT array_agg(DISTINCT split_part(g, '=', 1))
         FROM unnest(p.proacl::text[]) AS g),
        ARRAY[]::text[]
      )
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.prokind = 'f' AND p.prosecdef = true
      AND p.proname NOT IN (SELECT proname FROM trigger_fn_whitelist)
  LOOP
    IF ('anon' = ANY(v_grantees) OR 'authenticated' = ANY(v_grantees)) THEN
      SELECT count(*) INTO v_count
      FROM public_definer_whitelist
      WHERE rpc_name = v_proname;
      ASSERT v_count = 1,
        format(
          'INV-B: SECURITY DEFINER %s tiene EXECUTE para %s pero no está en whitelist. '
          'Acción: si es público intencional, agregar a public_definer_whitelist con justificación. '
          'Si NO debería ser callable, REVOKE EXECUTE FROM anon, authenticated.',
          v_proname, array_to_string(v_grantees, ',')
        );
    END IF;
  END LOOP;
  RAISE NOTICE 'INV-B OK · % entradas whitelist verificadas',
    (SELECT count(*) FROM public_definer_whitelist);

  -- ====================================================================
  -- INV-C · Helpers canónicos RLS → STABLE
  -- ====================================================================
  -- Si un helper canónico (current_user_*) se marca VOLATILE, el planner
  -- re-evalúa por row · RLS con joins puede degradar a O(N²) o peor.
  FOR v_proname IN SELECT proname FROM rls_canonical_helpers LOOP
    SELECT count(*) INTO v_count FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = v_proname AND p.provolatile = 's';
    ASSERT v_count = 1,
      format(
        'INV-C: Helper canónico %s no es STABLE. Fix: ALTER FUNCTION %s STABLE. '
        'Si se cambió a VOLATILE intencionalmente, revisitar el contrato.',
        v_proname, v_proname
      );
  END LOOP;
  RAISE NOTICE 'INV-C OK · % helpers canónicos STABLE',
    (SELECT count(*) FROM rls_canonical_helpers);

  -- ====================================================================
  -- INV-D · Whitelist sin entradas huérfanas
  -- ====================================================================
  -- Si una RPC fue removida en un PRP de cleanup, sacarla del whitelist.
  FOR v_proname IN
    SELECT rpc_name FROM public_definer_whitelist
    WHERE rpc_name NOT IN (
      SELECT p.proname FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public' AND p.prokind = 'f'
    )
  LOOP
    ASSERT false,
      format('INV-D: whitelist menciona %s pero no existe en pg_proc. Limpiar entry.', v_proname);
  END LOOP;
  RAISE NOTICE 'INV-D OK · whitelist sin entradas huérfanas';

  RAISE NOTICE 'helpers-shape-invariants: ALL CHECKS PASSED (4/4)';
END $$;

ROLLBACK;
