# Sistema PRP (Product Requirements Proposal) · template del PRP del pack workflow-base

> ⚙️ **Stack adaptation banner:** este template asume stack típico **Next.js (App Router) + Supabase (Postgres + RLS) + Tailwind + Playwright + Husky** del pack workflow-base. Los ejemplos concretos (paths · KPIs · tokens DS · convenciones SQL) provienen del proyecto upstream Ticketera con marca *"ej en upstream Ticketera"* y sufijo *"adaptá a tu stack/rubro/DS"*. Si tu proyecto usa otro stack, los principios (PRP como contrato pre-código · bifurcaciones firmadas · DoD por fase · CSV ownership exclusivo de `/validar` · etc) siguen aplicando · solo cambian los ejemplos concretos · adaptá inline.

> **El blueprint de cada feature compleja del producto. Contrato humano-IA antes de escribir código.**

Un PRP es el documento que cierra QUÉ se construye antes de implementar. Define alcance · criterios de éxito binarios · bifurcaciones arquitectónicas firmadas con tag 🔵 user · inventario de archivos afectados · fases del Blueprint con tests del DoD. Sin PRP aprobado en estado `APROBADO`, el SKILL [`/implementar`](../skills/implementar/SKILL.md) NO arranca (regla del flujo Modo C).

---

## Qué es un PRP

| Sección | Propósito | Responsable |
|---|---|---|
| **Objetivo** | Estado final deseado en 1-2 oraciones | User define · agente refleja |
| **Por Qué** | Problema/Solución + valor de negocio + impacto en KPIs del producto · ver BUSINESS_LOGIC.md | User define · agente investiga contexto |
| **Qué + Criterios de Éxito** | Comportamiento + binarios verificables mecánicamente | User + agente |
| **Contexto** | Referencias del codebase · patrones a respetar · reglas firmes aplicables · decisiones 🔵 user | Agente investiga · user valida |
| **Análisis pre-draft de las personas** | 4 outputs literales de las personas (`architect-planning` · `complexity` · `historical-precedent` pre-draft + `skeptic` post-draft) versionados en git | Agente principal · auto-generado por SKILL [`/planificar`](../skills/planificar/SKILL.md) Pasos 2.5 + 7.5 |
| **Inventario de archivos afectados** | Tabla con emojis 🟢🟡🟠🆕🟣🔴❌ + justificación + cláusula CSV ownership | Agente genera · user firma |
| **Blueprint** | Fases ordenadas cronológicamente con DoD por fase | Agente genera con [`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) |
| **Aprendizajes / Self-Annealing** | Errores · root cause · fixes que surgen durante implementación | Agente actualiza durante `/implementar` |

---

## Flujo de Trabajo · los 6 pasos del flujo

```
1. /arrancar     → contexto · próxima task · modo A/B/C · status tracker
2. /planificar   → este PRP · 6 preguntas PM hat + bifurcaciones 🔵 user + claude-design-matrix
3. /implementar  → bucle agéntico · fases con checkpoints reversibles · DoD por fase · commit local
4. /revisar      → multi-agent paralelo · 9 agentes Opus + consolidator (SKIP si doc-only)
5. /validar      → CSV con Playwright MCP + Supabase MCP · 100% verde (SKIP si doc-only)
6. /entregar     → ci:local 6/6 → push único → CI remoto → merge --squash a main
```

Detalle nominal: [`WORKFLOW.md § 3`](../../WORKFLOW.md). Cada skill es autocontenido en [`.claude/skills/<skill>/SKILL.md`](../skills/).

---

## Nomenclatura

- **Archivos:** `PRP-NNN-<descripcion-kebab>.md` · **ej en upstream Ticketera: `PRP-027-refresh-visual-y-slug-autotrigger.md` · adaptá al naming descriptivo de tu feature**.
- **Numeración:** secuencial sin gaps · padding 3 dígitos · sub-índices con sufijo letra cuando aplica (`PRP-NNNA` · `PRP-NNNB` · `PRP-NNNC`).
- **Estados** (regla [`golden-rule-docs-memory.md § Estado del header del PRP`](../rules/golden-rule-docs-memory.md)):

| Estado | Cuándo aplica |
|---|---|
| `PENDIENTE` | Draft generado por `/planificar` · pendiente firma del user |
| `APROBADO` | User firmó el draft · listo para que `/implementar` arranque Fase 1 |
| `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)` | `/implementar` cerró el bucle agéntico · pasos 4-5-6 pendientes |
| `EN PROGRESO (paso 5 cerrado · 6 pendiente)` | `/validar` cerró CSV 100% verde · solo falta `/entregar` |
| `COMPLETADO` | **Solo post-merge a `main`** · NUNCA antes (anti-pattern de cierre prematuro · ver [§ Anti-patterns al rellenar este template](#anti-patterns-al-rellenar-este-template) al final) |
| `DIFERIDO con razón documentada` | Paso 6 quedó bloqueado · razón explícita en el PRP |

---

## Cuándo NO usar este template

| Caso | Acción correcta |
|---|---|
| Task trivial bien especificada en el roadmap (con files + notes) · sin decisiones de arquitectura | **Modo A** · ejecutar directo · marcar `[ ]` → `[x]` en [`docs/product/product-roadmap.md`](../../docs/product/product-roadmap.md) |
| Encaja en un skill ya existente con flujo cerrado (`/validar` · `/revisar` · skills auxiliares específicos del proyecto si los tiene · ej: `/<design-skill>` · `/<db-skill>`) | **Modo B** · invocar el skill correspondiente |
| Bug fix puntual con root cause claro y scope ≤2 archivos | Fix directo · regression-first FIRME ([`regression-first-on-fix.md`](../rules/regression-first-on-fix.md)) · sin PRP |
| Refactor de fábrica con skill dedicado archivado en sesión previa | Caso histórico cerrado · ver `.claude/_archive/skills/` del proyecto si aplica |

---

# TEMPLATE PRP

> **Copiar el bloque entre las líneas de fence ` ```markdown ... ``` ` abajo · pegar en `.claude/PRPs/PRP-NNN-<descripcion-kebab>.md` · rellenar placeholders entre corchetes `[...]` · marcar secciones condicionales con `N/A · <razón>` cuando no apliquen.**

```markdown
# PRP-NNN · [Título corto descriptivo de la feature/cleanup]

> **Estado**: PENDIENTE
> **Fecha**: YYYY-MM-DD
> **Proyecto**: <PROYECTO>
> **Tipo**: [feature producto | mini-PRP gobernanza | mini-PRP infra · doc-only o mixto]
> **Modo**: [C completo (6 pasos) | C acotado (pasos 1-2-3 · 4-5 SKIP · 6 a decidir)]
> **Cardinalidad de fases**: N fases [reversibles | con punto-de-no-retorno en fase M]
> **Tarea del roadmap cubierta**: [TASK-NNN | ninguna directa · trabajo emergente]
> **Riesgo**: [🟢 Bajo | 🟡 Medio | 🔴 Alto · justificar 1-frase]
> **Complejidad estimada**: [🟢 BAJA | 🟡 MEDIA · 🔴 ALTA prohibida por regla [`complejidad.md`](../rules/complejidad.md) · si la estimación es ALTA, descartar/postergar/descomponer en sub-PRPs MEDIA antes de aprobar]

> **Progreso del flujo de 6 pasos:** (condicional · solo feature producto · skip en mini-PRP gobernanza doc-only)
> 1. ☐ `/arrancar`
> 2. ☐ `/planificar` → APROBADO
> 3. ☐ `/implementar` (N/N fases)
> 4. ☐ `/revisar` (LR-NNN · X/Y fixeados)
> 5. ☐ `/validar` (CSV X/Y Funciona)
> 6. ☐ `/entregar` (ci:local + push + CI remoto + merge --squash)

---

## Objetivo

[Estado final deseado en 1-2 oraciones. Qué se construye · NO cómo. Verificable con criterios binarios abajo.]

**Métrica binaria de éxito:** [comando o assertion mecánica que verifica el cierre · ej: `wc -l <archivo> < 130` · `grep -E "<patrón obsoleto>" <archivo>` retorna 0 matches · spec X verde].

---

## Por Qué

| Problema | Solución |
|---|---|
| [Dolor del usuario/owner/dev · concreto y observable] | [Cómo lo resuelve esta feature · alineado con la identidad del producto de [`BUSINESS_LOGIC.md`](../../BUSINESS_LOGIC.md)] |

**Valor de negocio:**
- [Impacto en KPI del producto · ver [`BUSINESS_LOGIC.md § N`](../../BUSINESS_LOGIC.md) · KPIs del producto · **ej en proyecto upstream Ticketera: productores Premium con renovación · NPS · tickets WhatsApp · resolución IA/humana · volumen vendido · adaptá al rubro de tu producto**]
- [Otro valor observable · cero hand-waving]

---

## Qué

### Criterios de Éxito (binarios verificables · prefijo G1...)

- [ ] **G1 · [Criterio 1]** · verificable con [comando o assertion mecánica].
- [ ] **G2 · [Criterio 2]** · verificable con [...].
- [ ] **G3 · [Criterio 3]** · verificable con [...].

### Comportamiento Esperado (Happy Paths)

**Happy path 1 ([nombre]):** [paso a paso del flujo principal del actor primario].

**Happy path 2 ([nombre]):** [otro flujo cuando aplica · ej: cancelación · refund · validación negativa].

---

## Contexto

### Referencias del codebase (SoT)

- [Archivo o módulo relevante 1 con link y línea cuando aplica · ej de patrón path+línea · **upstream Ticketera: `src/lib/services/events/create.ts:42-78` · adaptá al stack de tu proyecto**].
- [Migración existente como referencia simétrica · ej: [`db/migrations/00NN_<feature>.sql`](../../db/migrations/)].
- [Componente producción a reusar · NO recrear · regla [`simplicity-first.md`](../rules/simplicity-first.md)].
- [DT origen del trabajo cuando aplica · ej: [`docs/logs/technical-debt.md:NNN`](../../docs/logs/technical-debt.md)].

### Patrones existentes a respetar (regla [`simplicity-first.md`](../rules/simplicity-first.md) · reusar > recrear)

- Componentes de producción del DS · **ej en upstream Ticketera: `src/components/{auth,listado-standard,forms,brand}/` · adaptá a las carpetas del DS de tu proyecto** — NO recrear.
- Helpers en `src/lib/<dominio>/` agrupados por dominio · **ej en upstream Ticketera: `src/lib/services/<dominio>/` · adaptá al convention de tu stack**.
- Server Actions con patrón `validate Zod → auth → permission → exec → audit` (referencia PRP histórico análogo de tu proyecto · ej en upstream Ticketera: `PRP-003` (módulo eventos) Fase 2).
- Migraciones SQL en `db/migrations/00NN_*.sql` · numeración secuencial · idempotentes ([`migrations-idempotency.md`](../rules/migrations-idempotency.md)).
- Seeds durables en `db/seeds/test/*.sql` con UPSERT id fijo ([`seed-upsert-with-fixed-id.md`](../rules/seed-upsert-with-fixed-id.md)).
- Stack confirmado: ver [`BUSINESS_LOGIC.md § 7`](../../BUSINESS_LOGIC.md) (SoT única · NO duplicar acá).
- **Verificación obligatoria del PRP contra las decisiones críticas no negociables** ([`BUSINESS_LOGIC.md § 8`](../../BUSINESS_LOGIC.md)) · cualquier propuesta que viole una constraint se cambia, NO la decisión (paridad [`WORKFLOW.md § 9 Convenciones`](../../WORKFLOW.md)).

### Reglas firmes aplicables (`.claude/rules/`)

Listar las reglas que enmarcan el área del PRP (convención canónica del pack). Ejemplos típicos:

- [`think-before-coding.md`](../rules/think-before-coding.md) — Karpathy P4 · listar asunciones pre-código · push back si hay approach más simple · cero "picar" silenciosamente.
- [`ante-duda-preguntar-user.md`](../rules/ante-duda-preguntar-user.md) — ambigüedad real · scope no claro · interpretación múltiple → preguntar al user con recomendación early · NO improvisar.
- [`status-tracker-visible.md`](../rules/status-tracker-visible.md) — Modo C obligatorio · tracker de los 6 pasos al inicio de cada respuesta principal hasta el cierre del paso 6.
- [`migrations-idempotency.md`](../rules/migrations-idempotency.md) — DDL idempotente · `IF NOT EXISTS` · `DROP POLICY IF EXISTS` antes de `CREATE POLICY`.
- [`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) — 2-5 specs/queries por fase del Blueprint · regression-first FIRME.
- [`regression-first-on-fix.md`](../rules/regression-first-on-fix.md) — bug → spec reproduce pre-fix · pasa post-fix · 1-2 filas vecinas.
- [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) — al crear carpeta nueva · README obligatorio en raíz.
- [`routing-paths-in-english.md`](../rules/routing-paths-in-english.md) — paths del framework en inglés industria-estándar · copy en idioma del producto · regla ortogonal de localización.
- [`surgical-changes.md`](../rules/surgical-changes.md) — diff trazable al request · cero drive-by.
- [`quality-standard-senior.md`](../rules/quality-standard-senior.md) — 6 puntos del estándar · cero hardcode · cero copy-paste · cero código basura · simetría módulos hermanos.
- [`fatigue-self-evaluation.md`](../rules/fatigue-self-evaluation.md) — sub-rule de quality-standard-senior · STOP + aviso formato canónico (🟢/🟡/🔴 + caminos A/B) antes de comprometer calidad por carga de sesión.
- [`always-fix-all-bugs.md`](../rules/always-fix-all-bugs.md) — todo bug se fixea · cero diferimiento por severidad.
- [`register-out-of-scope-as-dt.md`](../rules/register-out-of-scope-as-dt.md) — hallazgo out-of-scope → DT en el acto · 8 campos contractuales.
- [`husky-hooks-smoke-tests.md`](../rules/husky-hooks-smoke-tests.md) — cualquier cambio a `.husky/pre-commit` · `pre-push` · `post-commit` obliga actualizar el smoke test correspondiente en `tests/scripts/infra-flujo/`.
- [`session-handoff.md`](../rules/session-handoff.md) — continuidad multi-sesión · shape canónico de 7 secciones · path obligatorio `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>.md` cuando el PRP requiere cierre mid-flight.

Tabla canónica completa: [`CLAUDE.md § Reglas FIRMES`](../../CLAUDE.md).

### Decisiones cerradas (firmas 🔵 user · YYYY-MM-DD)

Formato canónico de cada bifurcación arquitectónica cerrada:

- **🔵 Bif N · [Tema] — Opción X firmada por user · YYYY-MM-DD** · *"[justificación 1-frase del user · cita literal cuando aplica]"*.

Ejemplos:
- **🔵 Bif 1 · [Modelo de datos / approach técnico] — Opción A firmada por user · YYYY-MM-DD** · *"[razón]"*.
- **🔵 Bif 2 · [Patrón de UI / approach UX] — Opción A firmada por user · YYYY-MM-DD** · *"[razón]"*.
- **🔵 Claude Design [SI/SKIP] firmado por user · YYYY-MM-DD** · *"[razón · matriz dispara/no dispara]"* (siempre se firma · regla del SKILL [`/planificar`](../skills/planificar/SKILL.md) Paso 4).

### Sub-decisiones cosméticas (cerradas con recomendación early · agente decide · firma 🔵 implícita al aprobar el PRP)

- **SD-cos-1 · [Tema operativo menor]:** [decisión + razón 1-frase].
- **SD-cos-2 · [...]:** [...].

Las SDs cosméticas son decisiones SIN tradeoff arquitectónico real · el agente las cierra con recomendación early · el user puede objetar pero NO firma cada una.

### Modelo de datos (CONDICIONAL · "N/A · cero schema" si no aplica)

[Cuando el PRP toca BD/RPC/RLS · pegar SQL completo del DDL · trigger · función · RLS policy. Referencia [`migrations-idempotency.md`](../rules/migrations-idempotency.md) FIRME.]

```sql
-- db/migrations/00NN_<feature>.sql

CREATE TABLE IF NOT EXISTS public.<tabla> (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- ...
);

-- RLS
ALTER TABLE public.<tabla> ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS <name> ON public.<tabla>;
CREATE POLICY <name> ON public.<tabla>
  FOR SELECT TO authenticated
  USING (...);
```

**Si NO aplica:** declarar literal *"N/A · cero schema · cero migraciones · cero RPC · cero RLS"* y continuar.

### Claude Design handoff (CONDICIONAL · "N/A · cero UI nueva" si no aplica)

[Cuando el PRP toca UI nueva que la matriz [`claude-design-matrix.md`](../rules/claude-design-matrix.md) dispara SÍ · referenciar el handoff esperado:]

- **Brief Claude Design:** [`docs/design/handoff/prp-NNN-<feature>/brief.md`](../../docs/design/handoff/) — pendiente de entrega antes de Fase X.
- **Componentes producción a reusar:** [`src/components/<area>/`](../../src/components/) · NO recrear.
- **Tokens del DS:** tokens del DS · escala tipográfica · radii · shadows · **ej en upstream Ticketera: paleta terracota + sage · adaptá al DS de tu proyecto**.

**Si NO aplica:** declarar literal *"N/A · cero UI nueva · matriz no dispara · primitivos directos del DS"* O *"N/A · PRP doc-only · sin superficies visuales"*.

---

## Análisis pre-draft de las personas

> **Sección OBLIGATORIA · contractual (decisión arquitectónica del pack workflow-base · sección contractual del template · trazabilidad versionada en git · cero log externo). Referencias históricas en footer de pedigrí.** Auto-generada por el SKILL [`/planificar`](../skills/planificar/SKILL.md) Paso 2.5 (3 personas paralelas pre-draft) + Paso 7.5 (skeptic post-draft) · outputs literales versionados en git. Las 4 personas viven en [`.claude/skills/planificar/agents/`](../skills/planificar/agents/) · campos de cada output siguen sub-decisión cosmética del template (shape estructurado por persona).
>
> **Resilience policy del pack (sub-decisión cosmética del template · ver footer pedigrí):** si una persona devuelve timeout o error · pegar literal `persona X no respondió · análisis incompleto · continuar con las restantes` (pre-draft) o `skeptic no respondió · análisis post-draft incompleto · PRP presentado al user sin refinamiento adicional` (post-draft) · cero ABORT del flujo de planificación.

### architect-planning

[output literal de la persona architect-planning · pegado durante Paso 2.5 (pre-draft) por el agente principal de `/planificar` · campos: Shape arquitectónico propuesto · Patrones a reusar · Riesgos arquitectónicos · Simetrías cross-módulo a considerar]

### complexity

[output literal de la persona complexity · pegado durante Paso 2.5 (pre-draft) por el agente principal de `/planificar` · campos: Estimación 🟢 BAJA / 🟡 MEDIA / 🔴 ALTA · Fundamento (1-2 frases) · Señales de inflación de scope · Sub-descomposición sugerida si 🔴]

### historical-precedent

[output literal de la persona historical-precedent · pegado durante Paso 2.5 (pre-draft) por el agente principal de `/planificar` · campos: Precedentes relevantes (PRPs históricos con paths) · Decisiones firmadas 🔵 que aplican por analogía · Diferencias clave a contemplar]

### skeptic

[output literal de la persona skeptic · pegado durante Paso 7.5 (post-draft) por el agente principal de `/planificar` después de cuestionar el draft completo · campos: Issues detectados en el draft · Missing pieces · Asunciones sin firmar · Contradicciones internas · refinamientos aplicados por el agente principal si los issues fueron válidos (max 1 iteración antes del Paso 8)]

---

## Inventario de archivos afectados

Convención emojis (convención canónica del pack):

| Emoji | Acción |
|---|---|
| 🟢 | Archivo nuevo creado |
| 🟡 | Archivo existente modificado |
| 🟠 | Archivo de docs / logs / memoria tocado |
| 🆕 | Archivo nuevo de tests · specs · migraciones |
| 🟣 | Entregable cuyo ownership es de OTRO skill del flujo (típicamente CSV de `/validar` · ver nota abajo) |
| 🔴 | Archivo eliminado o archivado |
| ❌ | NO tocar (declarado explícito · restricción de scope) |

| Acción | Archivo | Justificación |
|---|---|---|
| 🟢 | `<path/al/archivo-nuevo>` | [razón · 1-frase trazable al request] |
| 🟡 | `<path/al/archivo-existente>` | [cambio puntual + 1-frase] |
| 🆕 | `tests/e2e/regression/PRP-NNN-<feature>.spec.ts` | Regression-first FIRME · spec del DoD de Fase N |
| 🆕 | `tests/sql/PRP-NNN-<feature>.sql` | Invariante SQL del DoD de Fase N |
| 🟣 | `tests/manual/PRP-NNN_<feature>.csv` | **NO se crea en este PRP/paso 3 `/implementar`** · ownership exclusivo del SKILL [`/validar`](../skills/validar/SKILL.md) paso 5 del flujo que lo crea con metodología rigurosa (Playwright MCP + Supabase MCP + credenciales reales + regression-first FIRME). Acá solo se lista como entregable contractual del PRP entero. Memoria seed esperada del pack: `csv-is-validar-not-implementar.md` · sumá con `/memory-manager ingest` si tu proyecto la necesita. |
| 🟠 | `docs/logs/technical-debt.md` | Mover DT-NNN a Resueltas con commit hash + abrir DTs nuevas detectadas out-of-scope (regla [`register-out-of-scope-as-dt.md`](../rules/register-out-of-scope-as-dt.md)) |
| 🟠 | `.claude/memory/log.md` | Entrada `decision` al cierre del Paso 3 + entrada `prp-close` al cierre del Paso 6 (regla [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md)) |
| ❌ | [Archivos fuera de scope] | NO tocar (regla [`surgical-changes.md`](../rules/surgical-changes.md)) |

**Restricciones de scope** (paridad regla [`surgical-changes.md`](../rules/surgical-changes.md)):

- [Restricción 1 · qué NO se hace en este PRP · diferido a PRP futuro con DT explícita].
- [Restricción 2 · qué áreas del codebase NO se tocan].
- [Restricción 3 · qué simetrías se ofrecen pero NO se aplican silenciosamente].

---

## Blueprint (Assembly Line · N fases)

> Cada fase cierra con: código + tests del DoD ([`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) · 2-5 specs/queries por fase típica · 10-20 totales por PRP cuando entrega código de producto) + `npm run typecheck` verde + `npm run build` verde + commit local. **NO push hasta paso 6** ([`push-and-ci-policy.md`](../rules/push-and-ci-policy.md) regla #27 "1 push por PRP en paso 6").
>
> **Pre-step obligatorio antes de Fase 1** (regla [`pre-validation-inherited-regression.md`](../rules/pre-validation-inherited-regression.md) #16): si tu proyecto tiene suite de regresión codificada en `tests/e2e/regression/COVERAGE.md`, cruzar `git diff main --name-only` contra ese índice · correr specs heredados matcheados con `npm run test:e2e -- tests/e2e/regression/<spec>.spec.ts` · si rojo pre-Fase 1 → bug heredado fuera de scope → DT en el acto ([`register-out-of-scope-as-dt.md`](../rules/register-out-of-scope-as-dt.md)) · NO mezclar con trabajo del PRP. Si tu proyecto NO tiene suite de regresión aún (típico al boot del template · regla #17 [`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) la genera incrementalmente fase a fase), este pre-step se skipea documentando "suite vacío al boot · pre-validation no aplica" inline en el PRP. Excepción: firma user explícita que el fix entra al scope actual.

### Fase 1 — [Nombre descriptivo · ej: "BD schema + RLS + RPCs core"]

**Objetivo:** [qué se logra al cerrar esta fase · 1-2 oraciones].

**Tipo:** 🟢 reversible · O 🔴 punto-de-no-retorno (justificar · ej: migración SQL aplicada a TEST DB cloud).

**Acción:**
1. [Paso concreto 1 con archivo y comando cuando aplica].
2. [Paso 2].
3. [Paso N].

**DoD (Definition of Done):**
- [ ] `<archivo>.<ext>` creado con [criterio mecánico].
- [ ] `tests/<sql|e2e>/PRP-NNN-<spec>.<ext>` creado con N-M tests verdes (regression-first FIRME).
- [ ] `bash scripts/test-migrations.sh` verde (cuando aplica · idempotencia).
- [ ] `npm run typecheck` verde.
- [ ] `npm run build` verde.
- [ ] Commit local `<tipo>(PRP-NNN): fase 1 · <título> · <resumen 1-frase>`.

**Reversibilidad:** [sí / no · 1-frase de cómo revertir si rompe la siguiente fase].

### Fase 2 — [Nombre]

**Objetivo:** [...].
**Acción:** [...].
**DoD:** [...].
**Reversibilidad:** [...].

### Fase N — Validación Final (cuando aplica)

**Objetivo:** Sistema funcionando end-to-end · criterios de éxito del § Qué cumplidos.

**Acción:**
1. Correr suite completo de specs heredados ([`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md) · acumulativo).
2. Validación visual con Playwright MCP cuando aplica.
3. Confirmar criterios G1...GN del § Qué marcados.

**DoD:**
- [ ] `npm run typecheck` verde.
- [ ] `npm run build` verde.
- [ ] Spec heredado global verde.
- [ ] Visual smoke verde cuando aplica (Playwright MCP `browser_snapshot`).
- [ ] Criterios de éxito G1...GN marcados.

---

## Criterios de éxito (binarios)

1. ✅ G1 cumplido · verificable con [comando].
2. ✅ G2 cumplido · verificable con [comando].
3. ✅ GN cumplido · verificable con [comando].
4. ✅ `npm run typecheck` exit 0.
5. ✅ `npm run build` exit 0.
6. ✅ `git diff --stat` muestra solo los archivos del Inventario (cero drive-by · regla [`surgical-changes.md`](../rules/surgical-changes.md)).

---

## SKIPs justificados (CONDICIONAL · solo cuando aplica)

> Sección solo presente en mini-PRPs gobernanza doc-only u otros casos donde paso 4 `/revisar` y/o paso 5 `/validar` no aportan. Cada SKIP requiere firma 🔵 user explícita.

### Paso 4 · `/revisar` · SKIP

**Razón:** [doc-only · cero código aplicación · multi-agent review no aporta sobre cleanup de gobernanza · cobertura por DoD mecánico de Fase 1].

**Firma 🔵 user · YYYY-MM-DD:** *"[cita literal del user al firmar el PRP · ej: 'sin revisar, es solo doc']"*.

### Paso 5 · `/validar` · SKIP

**Razón:** [cero UI · cero forms · cero RPCs · CSV con Playwright/Supabase MCPs no aporta · verificación funcional cubierta por DoD por fase].

**Firma 🔵 user · YYYY-MM-DD:** *"[cita literal]"*.

### Paso 6 · `/entregar` · DIFERIDO consolidado con próximo PRP (cuando aplica)

**Razón:** consolidación de entrega con próximo PRP del producto · 1 push consolidado + 1 PR + 1 CI remoto + 1 merge `--squash`. Paridad cluster de mini-PRPs gobernanza.

**Firma 🔵 user · YYYY-MM-DD:** *"[cita literal · ej: 'queda diferido para mergear junto con prp posterior']"*.

**Implicación operativa:**
- NO se corre `npm run ci:local` al cierre de Fase N.
- NO se hace push a `origin/dev` (queda en commits locales).
- Backup automático `.husky/post-commit` replica a `origin/dev-backup` igual (regla firme).
- Próximo PRP consume el commit local · `/planificar` siguiente lee archivos desde working tree de `dev`.

---

## Aprendizajes / Self-Annealing

> Sección VACÍA al aprobar el PRP. Se rellena durante `/implementar` con gotchas detectados · root cause · fixes. El conocimiento persiste · el mismo error NUNCA ocurre dos veces (principio del auto-blindaje · ver SKILL [`/implementar` § Paso 3.5](../skills/implementar/SKILL.md)).

Formato canónico de cada entry (paridad con shape canónico del pack):

### N · [Título corto del aprendizaje]

[Descripción 2-5 líneas: qué falló · root cause · fix aplicado · referencia a spec/commit/memoria persistente cuando aplica · lección replicable.]

---

## Cierre

Al cerrar la última fase del Blueprint, marcar este PRP como **EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)** · NO `COMPLETADO`. El estado `COMPLETADO` se reserva para post-merge a `main` (paso 6 `/entregar` ejecutado · O diferido con razón documentada).

REGLA DE ORO docs y memoria checklist 6 ítems ([`golden-rule-docs-memory.md`](../rules/golden-rule-docs-memory.md)) aplica al cierre de la última fase del paso 3 · ítems 4.5 (CSV) y 4.7 (ultrareview log) quedan pendientes del paso 5 y paso 6 respectivamente (NO se cumplen acá · decisión arquitectónica del pack workflow-base · trazada a memoria persistente `csv-is-validar-not-implementar.md` · ver footer pedigrí para fecha de codificación).

Actualizar entrada en `.claude/memory/log.md` tipo `prp-close` recién al cierre del paso 6 (merge a `main`) · regla [`log-chronology-append-only.md`](../rules/log-chronology-append-only.md).

---

*PRP-NNN pendiente aprobación. No se ha modificado código todavía.*
```

---

## Anti-patterns al rellenar este template

Cero excepciones · cada anti-pattern apunta a la regla firme que lo prohíbe:

- **NO crear nuevos patrones si los existentes funcionan** — regla [`simplicity-first.md`](../rules/simplicity-first.md) (mínimo código que resuelve el problema · cero abstracciones especulativas sin caller real).
- **NO drive-by refactoring · cero limpieza colateral sin firma** — regla [`surgical-changes.md`](../rules/surgical-changes.md) (todo diff trazable al request · si encontrás algo fuera de scope abrí DT con regla [`register-out-of-scope-as-dt.md`](../rules/register-out-of-scope-as-dt.md)).
- **NO suponer · ir a fuente de verdad** — regla [`no-suponer-fuente-de-verdad.md`](../rules/no-suponer-fuente-de-verdad.md) (cuando el agente no sabe efectivamente · va a repo/memoria/MCPs internos · docs oficiales externas · NUNCA solo memoria del LLM).
- **NO ignorar errores de TypeScript** — `npm run typecheck` exit 0 obligatorio al cierre de cada fase ([`tests-as-dod-per-phase.md`](../rules/tests-as-dod-per-phase.md)).
- **NO hardcodear UUIDs / slugs / shortcodes en specs** — regla [`quality-standard-senior.md`](../rules/quality-standard-senior.md) punto 2 (constantes nombradas · fixtures explícitas).
- **NO omitir validación Zod en Server Actions** — regla [`principios-desarrollo-flujo.md`](../rules/principios-desarrollo-flujo.md) punto 6 (Server-side validation obligatoria · NO solo cliente).
- **NO crear `tests/manual/PRP-NNN_*.csv` en paso 3 `/implementar`** — ownership exclusivo del paso 5 `/validar` · memoria seed esperada del pack: `csv-is-validar-not-implementar.md` · sumá con `/memory-manager ingest` si tu proyecto la necesita.
- **NO omitir la sección "Análisis pre-draft de las personas"** — sección contractual auto-generada por el SKILL [`/planificar`](../skills/planificar/SKILL.md) Pasos 2.5 + 7.5 con outputs literales de las 4 personas (`architect-planning` · `complexity` · `historical-precedent` pre-draft + `skeptic` post-draft) · omitirla rompe trazabilidad de planificación versionada en git (decisión arquitectónica del pack · ver footer pedigrí).
- **NO marcar el header del PRP como `COMPLETADO` antes del merge a `main`** — estado `COMPLETADO` se reserva para post-`/entregar` · al cierre del paso 3 marcar `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)` (regla [`golden-rule-docs-memory.md § Estado del header`](../rules/golden-rule-docs-memory.md)).
- **NO crear carpeta nueva sin firma user + README obligatorio** — regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) + sesgo anti-raíz [`respect-existing-folder-structure.md`](../rules/respect-existing-folder-structure.md) (default = NO crear · default = subcarpeta dentro de carpeta existente).
- **NO usar `gh pr merge --delete-branch`** sobre `dev` — `dev` es rama persistente · `--delete-branch` la elimina antes del sync · regla [`push-and-ci-policy.md`](../rules/push-and-ci-policy.md). Caso histórico documentado en footer pedigrí.
- **NO planificar feature de complejidad ALTA** — regla [`complejidad.md`](../rules/complejidad.md) (solo BAJA o MEDIA · ALTA se descarta · posterga · o descompone en sub-PRPs MEDIA antes de aprobar · cita textual user: *"prohibidas features de complejidad ALTA"*).
- **NO arrancar Fase 1 sin pre-validar regresión heredada cuando el proyecto tiene suite** — regla [`pre-validation-inherited-regression.md`](../rules/pre-validation-inherited-regression.md) (si tu proyecto tiene suite en `tests/e2e/regression/COVERAGE.md`: cruzar `git diff main --name-only` contra ese índice + correr specs heredados verdes ANTES de tocar código · si rojo pre-Fase 1 → bug heredado fuera de scope → DT en el acto. Si el proyecto NO tiene suite aún, skipear documentando "suite vacío al boot · pre-validation no aplica" inline).

---

*Template canónico del SKILL [`/planificar`](../skills/planificar/SKILL.md) Paso 1 + Paso 7 · principio universal del pack workflow-base · adaptá al historial real de tu proyecto.*

> **Banner pedigrí · referencias históricas del proyecto upstream (NO aplican a tu proyecto):**
> - Codificado vía PRP-NNN (cierra DT-NNN · gaps del template legacy archivado).
> - Sub-sección "Análisis pre-draft de las personas" firmada 🔵 user vía PRP-NNN · Bif 4 = B (cero log externo · trazabilidad versionada en git).
> - Resilience policy SD-cos-N firmada en el mismo PRP-NNN.
> - Anti-pattern `gh pr merge --delete-branch` detectado en proyecto upstream (DT-NNN).
> - Decisión 🔵 user sobre ownership del CSV (`/validar` paso 5 · NO `/implementar` paso 3) vía memoria persistente `csv-is-validar-not-implementar.md`.
> - Shape paralelo con PRPs del proyecto upstream (cluster mini-PRPs gobernanza).
>
> Cada proyecto adopter del workflow-base generará sus propias referencias históricas al codificar decisiones arquitectónicas durante PRPs reales. Las referencias arriba son CONTEXTO DE ORIGEN · NO aplican literalmente a tu proyecto (paridad CLAUDE.md § Reglas FIRMES).
