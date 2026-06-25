-- =====================================================================
-- SECURITY INVOKER RPC × tabla mutada × policy RLS coverage
-- · template universal Postgres + RLS
-- =====================================================================
-- > ⚙️ **Stack adaptation banner:** asume stack Postgres + RLS + rol
-- > `authenticated` (típicamente Supabase Auth). Si tu stack usa otro
-- > rol cliente (ej: `app_user` · `web_user`), ajustá el filtro en
-- > PART 1 (línea ~97 `'authenticated' = ANY(roles)`) al rol equivalente.
-- > El principio (RPCs `SECURITY INVOKER` mutating necesitan policy RLS
-- > del cmd apropiado en la tabla destino · sino el UPDATE/INSERT/DELETE
-- > silenciosamente filtra rows sin error) es 100% comportamiento
-- > universal de Postgres con RLS.
-- =====================================================================
-- **Por qué este spec existe (universal):** Postgres + RLS con
-- `SECURITY INVOKER` aplica policies de la tabla destino al rol del
-- caller (típicamente `authenticated`). Si la tabla NO tiene policy del
-- cmd que la RPC ejecuta (UPDATE · INSERT · DELETE), las filas se
-- filtran silenciosamente (`ROW_COUNT=0` · sin error). Resultado: la
-- RPC parece ejecutarse OK pero el cambio nunca se aplica · bug latente
-- sin alerta.
--
-- **Caso ilustrativo:** una RPC `SECURITY INVOKER` hace UPDATE en una
-- tabla secundaria del flujo (ej: tabla hija de la entidad principal)
-- pero esa tabla NO tiene policy UPDATE para `authenticated` → UPDATE
-- silenciosamente filtra → la entidad principal queda actualizada pero
-- el cambio en la hija nunca se aplica · bug latente sin alerta.
--
-- **Estrategia (whitelist declarativa · 3 capas):**
--   - **PART 1** · whitelist `expected_pairs (rpc, table, cmd)`: cada
--     par debe tener policy correspondiente en la tabla destino al rol
--     `authenticated`. Atrapa el bug original.
--   - **PART 2** · enumeración drift: enumera todas las RPCs
--     `SECURITY INVOKER + VOLATILE + non-trigger` de `pg_proc`. Si
--     aparece una RPC NO contemplada en `expected_pairs` ni en
--     `read_only_rpcs` → falla (detecta drift cuando alguien suma RPC
--     sin actualizar whitelist).
--   - **PART 3** · whitelist sin huérfanos: RPC removida en cleanup →
--     limpiar `expected_pairs`.
--
-- **Cómo usar (adopter):** llenar `expected_pairs` con los tríos (RPC ·
-- tabla · cmd) que tu proyecto introduce conforme cierre PRPs que
-- agregan RPCs `SECURITY INVOKER` mutating. Llenar `read_only_rpcs` con
-- RPCs que retornan datos con `VOLATILE` defensivo pero NO mutan
-- (lecturas con side-effects internos · advisory locks · NOTIFY). Al
-- boot del template ambas listas están vacías · PART 2 SKIPEA seguro
-- para evitar falsos positivos cuando el adopter ya tiene RPCs
-- `SECURITY INVOKER` no whitelist-eadas todavía (ver `IF cardinality
-- = 0 → RETURN` en cada PART).
--
-- **Cross-ref firme:** regla #15 [`regression-first-on-fix.md`](../../.claude/rules/regression-first-on-fix.md)
-- (spec ANTES del fix) + regla #35 [`agents-conditional-by-domain.md`](../../.claude/rules/agents-conditional-by-domain.md)
-- (típicamente activado por adopter con `multi-tenant.enabled: yes`).
-- =====================================================================

\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
  v_count       int;
  v_rpc         text;
  v_table       text;
  v_cmd         text;
  v_undeclared  text;
BEGIN
  -- ----- Setup: tablas temporales con whitelists declarativas ----------
  CREATE TEMP TABLE IF NOT EXISTS expected_pairs (
    rpc_name   text NOT NULL,
    table_name text NOT NULL,
    cmd        text NOT NULL  -- 'UPDATE' | 'INSERT' | 'DELETE'
  ) ON COMMIT DROP;

  CREATE TEMP TABLE IF NOT EXISTS read_only_rpcs (
    rpc_name text PRIMARY KEY
  ) ON COMMIT DROP;

  -- TODO adopter (WHITELIST 1 · expected_pairs): llenar con los tríos
  -- (rpc_name, table_name, cmd) que tu proyecto introduce. Cada RPC
  -- SECURITY INVOKER mutating debe enumerar TODAS las tablas que muta y
  -- el cmd correspondiente. Mantener al día con cada PRP que sume RPC
  -- nuevo.
  -- Ejemplo:
  --   INSERT INTO expected_pairs (rpc_name, table_name, cmd) VALUES
  --     ('cancel_order',     'orders',       'UPDATE'),
  --     ('cancel_order',     'order_items',  'UPDATE'),
  --     ('mark_order_paid',  'orders',       'UPDATE'),
  --     ('mark_order_paid',  'payments',     'INSERT');

  -- TODO adopter (WHITELIST 2 · read_only_rpcs): llenar con RPCs que
  -- retornan datos con `VOLATILE` defensivo pero NO mutan (advisory
  -- locks · NOTIFY · side-effects internos sin escritura a tablas).
  -- Ejemplo:
  --   INSERT INTO read_only_rpcs (rpc_name) VALUES
  --     ('get_dashboard_kpis');

  -- ====================================================================
  -- PART 1 — Cada par del whitelist tiene policy correspondiente
  -- ====================================================================
  IF (SELECT count(*) FROM expected_pairs) = 0 THEN
    RAISE NOTICE 'PART 1 SKIP: whitelist expected_pairs vacía · adopter declara sus pares en líneas marcadas con TODO';
  ELSE
    FOR v_rpc, v_table, v_cmd IN
      SELECT rpc_name, table_name, cmd FROM expected_pairs
    LOOP
      SELECT count(*) INTO v_count
      FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = v_table
        AND cmd = v_cmd
        AND ('authenticated' = ANY(roles) OR 'public' = ANY(roles));

      ASSERT v_count >= 1,
        format(
          'PART 1 · invariant violation: RPC %s muta %s con %s pero no hay policy para authenticated. '
          'Fix: agregar policy %s_%s_authenticated TO authenticated USING (...) WITH CHECK (...).',
          v_rpc, v_table, v_cmd, v_table, lower(v_cmd)
        );
    END LOOP;
    RAISE NOTICE 'PART 1 OK · % pares whitelist con policy correspondiente',
      (SELECT count(*) FROM expected_pairs);
  END IF;

  -- ====================================================================
  -- PART 2 — Enumeración: ningún RPC user-callable mutante sin whitelist
  -- ====================================================================
  -- Si alguien agrega un RPC SECURITY INVOKER + VOLATILE + non-trigger
  -- sin actualizar este spec, la enumeración lo destapa.
  --
  -- SKIP seguro: si AMBAS whitelists están vacías, asumimos boot del
  -- template (cero RPCs declaradas todavía) y omitimos para evitar
  -- falso positivo cuando el adopter ya tiene RPCs sin whitelist-ear.
  -- Una vez que el adopter llene al menos una whitelist, PART 2 corre y
  -- defiende drift en RPCs nuevas.
  IF (SELECT count(*) FROM expected_pairs) = 0
     AND (SELECT count(*) FROM read_only_rpcs) = 0 THEN
    RAISE NOTICE 'PART 2 SKIP: ambas whitelists vacías · adopter llena al menos una para activar drift detection';
  ELSE
    FOR v_undeclared IN
      SELECT p.proname
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
      WHERE n.nspname = 'public'
        AND p.prokind = 'f'
        AND p.prosecdef = false                         -- SECURITY INVOKER
        AND p.provolatile = 'v'                         -- VOLATILE (mutating)
        AND pg_get_function_result(p.oid) <> 'trigger'  -- excluir trigger fns
        AND p.proname NOT IN (SELECT rpc_name FROM expected_pairs)
        AND p.proname NOT IN (SELECT rpc_name FROM read_only_rpcs)
    LOOP
      ASSERT false,
        format(
          'PART 2 · RPC %s es user-callable + SECURITY INVOKER + VOLATILE + non-trigger, '
          'pero no figura en expected_pairs ni en read_only_rpcs. '
          'Acción: si muta tablas, agregar pares (rpc, tabla, cmd) en expected_pairs; '
          'si solo lee con side-effects (advisory locks · NOTIFY), agregar a read_only_rpcs.',
          v_undeclared
        );
    END LOOP;
    RAISE NOTICE 'PART 2 OK · enumeración: 0 RPCs sin whitelist';
  END IF;

  -- ====================================================================
  -- PART 3 — Pares sobrantes: whitelist apunta a RPC que ya no existe
  -- ====================================================================
  -- Heurística inversa: si el whitelist menciona una RPC que fue
  -- removida en un PRP de cleanup, eliminarlo también del whitelist
  -- (evita falsos positivos en PART 1 cuando la policy queda pero el
  -- caller se va).
  IF (SELECT count(*) FROM expected_pairs) = 0 THEN
    RAISE NOTICE 'PART 3 SKIP: whitelist expected_pairs vacía · nada para verificar huérfanos';
  ELSE
    FOR v_rpc IN
      SELECT DISTINCT rpc_name FROM expected_pairs
      WHERE rpc_name NOT IN (
        SELECT proname FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public' AND p.prokind = 'f'
      )
    LOOP
      ASSERT false,
        format(
          'PART 3 · WHITELIST menciona RPC %s pero no existe en pg_proc. '
          'Eliminar las filas correspondientes de expected_pairs.',
          v_rpc
        );
    END LOOP;
    RAISE NOTICE 'PART 3 OK · whitelist sin entradas huérfanas';
  END IF;

  RAISE NOTICE 'security-invoker-rpc-policy-coverage: ALL CHECKS PASSED (3/3)';
END $$;

ROLLBACK;
