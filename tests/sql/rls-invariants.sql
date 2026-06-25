-- =====================================================================
-- RLS Invariants · template universal Postgres + RLS
-- =====================================================================
-- > ⚙️ **Stack adaptation banner:** asume Postgres + RLS (típicamente
-- > Supabase). Si tu stack usa otro modelo de seguridad row-level
-- > (Firebase rules · GraphQL resolvers · middleware app-level),
-- > adaptá las queries o moviendo este spec a `tests/<otro>/`.
-- =====================================================================
-- Tests SQL ejecutables que verifican invariantes universales de RLS.
-- Se corren en CI con el job `sql` de `.github/workflows/ci.yml`.
--
-- Pattern típico de spec mutating (para sumar a este archivo conforme
-- el adopter cierre PRPs que tocan multi-tenancy):
--
--   BEGIN;
--   SET LOCAL ROLE authenticated;
--   SET LOCAL request.jwt.claims = '{"sub":"<test-user-uuid>","role":"authenticated"}';
--   DO $$
--   BEGIN
--     ASSERT (SELECT count(*) FROM <tenant_table> WHERE <owner_id> = '<other-tenant>') = 0,
--            'cross-tenant leak: <tenant_table>';
--   END $$;
--   ROLLBACK;
--
-- Cuándo aplica este spec: adopter declara `multi-tenant.enabled: yes`
-- O `migration-safety.enabled: yes` en `.claude/config/agents-applicability.yml`
-- (regla #35 agents-conditional-by-domain). Sin BD relacional con RLS,
-- el job `sql` del CI debería estar desactivado.
-- =====================================================================

-- =====================================================================
-- INV-1 · RLS habilitada en TODA tabla con policies
-- =====================================================================
-- Atrapa el bug clásico: alguien crea una policy nueva en una tabla
-- pero olvida `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`. Sin RLS
-- habilitada, las policies son decorativas y la tabla queda accesible
-- sin filtro al rol que tenga GRANT SELECT.
--
-- Este invariante atrapa cualquier regresión futura: si alguien crea
-- una policy en una tabla sin haberla habilitado, este test falla en
-- CI y bloquea el merge.
-- =====================================================================
DO $$
DECLARE
  v_offenders text;
  v_count integer;
BEGIN
  SELECT count(*), string_agg(t.tablename, ', ' ORDER BY t.tablename)
    INTO v_count, v_offenders
  FROM pg_tables t
  WHERE t.schemaname = 'public'
    AND t.rowsecurity = false
    AND EXISTS (
      SELECT 1 FROM pg_policies p
      WHERE p.schemaname = 'public' AND p.tablename = t.tablename
    );

  IF v_count > 0 THEN
    RAISE EXCEPTION 'INV-1 violado: % tablas con policies pero RLS deshabilitada -> %',
      v_count, v_offenders;
  END IF;

  RAISE NOTICE 'INV-1 OK · todas las tablas con policies tienen RLS enabled';
END $$;
