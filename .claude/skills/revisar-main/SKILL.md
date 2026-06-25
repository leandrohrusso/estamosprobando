---
name: revisar-main
type: skill
description: "Multi-agent code review holístico del estado completo de `main` (no diff) · 9 agentes Opus paralelos + consolidator general-purpose con checklist 10 ítems + preflight bash determinístico + log persistente en docs/logs/revisar-main-log.md · paridad arquitectónica con `/revisar` pero scope holístico · cadencia mensual paridad lint memoria · Paso 0.5 planning automático decide modo simple (1 fase) vs por fases (M fases acotadas con handoff automático) según inventario del repo · 3/9 agentes son **domain-tight** (multi-tenant · atomicity · migration-safety) condicionales al config `.claude/config/agents-applicability.yml` leído en Paso 0.4 con branching yes/no/unknown (regla #35) · ejecución puede emitir ABORT si algún flag está en `unknown` esperando firma user. Activar cuando el usuario dice: revisar main, revisar el main, auditar main, auditoria holística, audit holístico, revisión holística, lint mensual de código, lint código, drift de main, drift acumulado, asimetrías cross-PRP, asimetrias cross-prp, retro-auditoría, retro-auditoria, revisar todo el repo, auditá agents-applicability holístico, audita agents-applicability holistico, qué agentes domain-tight están activos en main, que agentes domain-tight estan activos en main."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/revisar-main` — auditoría holística del estado completo de `main` con planning previo por fases

> **Skill custom autocontenido** (PRP-NNN · 6 bifurcaciones 🔵 user upstream). Paridad arquitectónica con `/revisar` (paso 4 del flujo del producto) pero **scope holístico sobre `main` completo** (no diff vs main). Materializa el lint mensual de código · simétrico operativo con `scripts/lint-memory.sh` (lint mensual de memoria).
>
> **Inspiración estructural:** copia adaptada de [`.claude/skills/revisar/SKILL.md`](../revisar/SKILL.md) + 9 agentes + consolidator (Bif N = A · 🔵 user upstream · cero coupling con `/revisar` actual contractual paso 4 del flujo). **Qué significa Bif N = A** (refinamiento iterativo upstream): los 9 agentes review + consolidator se **DUPLICAN físicamente** en `revisar-main/agents/` y `revisar-main/consolidator.md` con § Role + § Input + § Verification checklist adaptados al modo holístico (área del repo · cero diff incremental · cero PRP en curso) · cero modificación de los originales en `revisar/agents/` y `revisar/consolidator.md` (contractuales paso 4) · cualquier cambio futuro a los agentes de `/revisar` requiere replicación explícita acá (NO herencia automática). **Novedad arquitectónica:** Paso 0.5 planning automático del scope decide modo simple (1 pasada) vs modo por fases (M pasadas según inventario) con handoff automático entre fases vía regla [`session-handoff.md`](../../rules/session-handoff.md) (Bif N = A).

## Overview

> **Propósito:** auditar TODO el estado de `main` (no diff) con los mismos 9 agentes Opus calibrados de `/revisar` adaptados al modo holístico. Detecta bugs estructurales acumulados que ningún diff individual ve: asimetrías cross-PRP (ej: operaciones análogas como `softDelete<EntidadA>` vs `softDelete<EntidadB>` que UR-NNN detectó retro), invariantes RLS/atomicity/multi-tenant rotos por cambios sucesivos, render snapshot mal aplicado, audit gaps, dead code estructural. Red de seguridad mensual sobre `main` · paridad operativa con lint mensual de memoria.
>
> **Cuándo invocar (esquemático):** cadencia mensual (fila en `docs/logs/deadlines.md` · `/arrancar` avisa al boot) · invocable ad-hoc cuando se sospecha drift acumulado o se quiere auditar un área específica del repo · NO sustituye a `/revisar` (paso 4 del flujo del producto sobre diff del PRP en curso · contractual).
>
> **Qué NO hace:** ❌ NO sustituye a `/revisar` (paso 4 sobre diff vs main · contractual) · ❌ NO mergea ni hace push · ❌ NO fixea (solo detecta · "siempre fixear todo, con calidad senior" lo hace el agente principal post-reporte vía PRPs nuevos del producto que consuman los findings) · ❌ NO toca código de producto (skill doc-only · auditoría) · ❌ NO se mezcla con el paso 4 del flujo del producto.

## When

**Aplica:**

- **Cadencia mensual codificada** (fila en `docs/logs/deadlines.md` · paridad DT-NNN lint memoria · disparador "1er del mes siguiente") · `/arrancar` lee el deadline al boot y avisa cuando se acerca (≤7 días) o vence.
- **Ad-hoc por sospecha de drift** · user dice *"revisar main"* · *"revisar el main"* · *"auditar main"* · *"auditoría holística"* · *"audit holístico"* · *"revisión holística"* · *"lint mensual de código"* · *"lint código"* · *"drift de main"* · *"drift acumulado"* · *"asimetrías cross-PRP"* · *"retro-auditoría"* · *"revisar todo el repo"*.
- **Pre-release / hito** · antes de un milestone mayor (ej: primer release · cambio estructural grande) corre `/revisar-main` para baseline holístico del repo.

**NO aplica:**

- **Paso 4 del flujo del producto** sobre PRP en curso · ese rol es de `/revisar` (auditoría del diff vs main · contractual · cero solapamiento).
- **Diff específico de un PRP** · usar `/revisar` (skill hermano · contractual paso 4 del flujo).

## Process

> **Estructura: 6 pasos hardcoded · Paso 0 + 0.5 nuevos vs `/revisar` (Bif N = B variable · Bif N = A handoff automático). Paso 1-5 paridad con `/revisar` pero adaptados al modo holístico (input = área del repo asignada según familia técnica · no diff).**
>
> **Reglas firmes que enmarcan el flujo** (refinamiento iterativo upstream):
>
> - [`folder-creation-with-readme.md`](../../rules/folder-creation-with-readme.md) #22 — README en raíz al crear carpeta nueva (cumplido al implementar este skill).
> - [`session-handoff.md`](../../rules/session-handoff.md) #26 — shape canónico 7 secciones del handoff invocado automáticamente entre fases (Bif 4 = A).
> - [`surgical-changes.md`](../../rules/surgical-changes.md) — cero modificación de `/revisar` actual (contractual) ni de los 9 agentes originales (Bif 1 = A · copia adaptada).
> - [`simplicity-first.md`](../../rules/simplicity-first.md) — copia adaptada (NO import + wrapper · cero abstracción especulativa).
> - [`quality-standard-senior.md`](../../rules/quality-standard-senior.md) — 6 puntos aplicados al draft del run + a cada finding del consolidator.
> - [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) — TODOS los findings (`critical` + `normal` + `nit-backlog`) se fixean post-reporte · cero diferimiento por severidad (los fixes pueden distribuirse en PRPs nuevos del producto que consuman el log entry).
> - [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) — post-reporte aplica el checklist GR 6-ítems al cierre del run: (a) entry `## [YYYY-MM-DD] lint \| RM-NNN run consolidado` en `.claude/memory/log.md` (paridad regla [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) tipo `lint`) · (b) findings consolidados archivados en `docs/logs/revisar-main-log.md § RM-NNN.0` · (c) cada finding que escale a PRP nuevo del producto aplica el checklist GR completo al cierre de su propio paso 6 · (d) si el run abre DTs nuevas, fila en `docs/logs/technical-debt.md` en el acto (paridad regla [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) #24) · cero reporte de `/revisar-main` "cerrado" sin estos 4 sub-pasos verificables.

### Paso 0 · Validación de pre-condiciones

Antes de invocar el preflight, verificar 3 invariantes con `Bash`:

1. **Working tree limpio:** `git status --porcelain` retorna vacío. Si hay archivos sin commitear, ABORT con mensaje *"Working tree sucio · commiteá primero (paridad `/revisar` Paso 0)."*
2. **Branch = main (o equivalente):** `git rev-parse --abbrev-ref HEAD` = `main` · O explícitamente firmado por user que la branch actual representa el estado a auditar (cuando se invoca durante PRP en curso para auditoría holística complementaria). Default: requiere `main`.
3. **`main` existe localmente:** `git rev-parse main` resuelve sin error.

**Check pre-arranque opcional (recomendado):** invocar [`/fatiga`](../fatiga/SKILL.md) antes del Paso 0.4 · este skill puede gastar tokens significativos (~$5-10 por fase · M fases en modo por fases) · vale confirmar MI estado fresco antes de invertir. Si el aviso emite 🟡 medio o 🔴 grande, considerar [`/handoff`](../handoff/SKILL.md) para retomar en sesión nueva con contexto liviano.

### Paso 0.4 · Leer config de aplicabilidad de agentes domain-tight

> **Por qué obligatorio (NO opcional · paridad `/revisar` Paso 0.6):** los 3 sub-agentes domain-tight del Paso 2 (`multi-tenant` · `atomicity` · `migration-safety`) asumen condiciones del dominio (multi-tenancy estricto · stock atomicity · BD relacional con migrations) que NO todo proyecto cumple. Si tu proyecto NO cumple la condición, spawnear el agente igual emite false positives + ensucia el log + cuesta tokens sin valor. Doctrina del mecanismo: regla firme #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md).
>
> **Por qué ANTES del Paso 0.5 planning:** el planning del scope decide qué archivos del repo aplican a cada agente · si un agente está deshabilitado, NO necesitamos incluir su familia técnica en el plan del scope (ahorro de tokens + claridad del plan firmado por user).
>
> **Por qué numerado 0.4 (NO 0.6 como en `/revisar`):** divergencia arquitectónica justificada · `/revisar-main` tiene Paso 0.5 planning automático (novedad vs `/revisar` · Bif N = B 🔵 user upstream) que requiere el config como input · el paso config se inserta ANTES del planning. Hermano paralelo: [`/revisar/SKILL.md § Paso 0.6`](../revisar/SKILL.md) (mismo behavior · numeración distinta por NO tener Paso 0.5 planning intermedio · paridad lógica exacta · cero divergencia funcional).

Antes del Paso 0.5 planning, aplicar regla firme #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md) § Process Pieza 3 (5 sub-pasos contractuales): (1) leé el config con `Read` · (2) parseá los 3 flags · (3) si `unknown` → firma user · (4) construí lista a spawnear · (5) emití transparencia. Leé [`.claude/config/agents-applicability.yml`](../../config/agents-applicability.yml) con `Read` y parseá los 3 flags:

- `multi-tenant.enabled` (`yes` / `no` / `unknown`).
- `atomicity.enabled` (`yes` / `no` / `unknown`).
- `migration-safety.enabled` (`yes` / `no` / `unknown`).

**Si algún flag está en `unknown`** → emitir aviso al user con formato canónico:

```text
⚠️ El proyecto NO declaró `<flag>` en `.claude/config/agents-applicability.yml`
(valor actual: `unknown`). Necesito firma user antes de avanzar.

¿El proyecto aplica `<condición>`?
- **A · sí · activar agente** `<nombre-agente>`.
- **B · no · skipear agente** `<nombre-agente>`.

Rec: leer [`BUSINESS_LOGIC.md § 8 Constraints del dominio que activan sub-agentes`](../../../BUSINESS_LOGIC.md)
para definir el flag · editar `.claude/config/agents-applicability.yml`
con el valor decidido + actualizar la tabla de § 8 con justificación 1-frase ·
volver a invocar el skill.
```

Cero asumir default (`yes` o `no`) · cero spawnear agente con flag en `unknown` (regla #35 § Anti-rationalization #2). ABORT con aviso al user hasta que firme.

**Si los 3 flags están en `yes` o `no` (cero `unknown`):**

1. Construir lista de agentes a spawnear:
   - **6 universales/amplios siempre:** `architect` · `security` · `tests` · `correctness` · `a11y` · `i18n`.
   - **3 domain-tight:** solo si su flag = `yes`. Skipear si flag = `no`.
2. Emitir al user transparencia explícita del config aplicado:

```text
Agentes a spawnear: N/9 según `.claude/config/agents-applicability.yml`:
- **Habilitados:** <lista de N agentes que van a correr>
- **Skipeados:** <lista de agentes domain-tight con flag `no`>
```

1. Pasar la lista al Paso 0.5 planning como input · las familias técnicas asociadas a agentes deshabilitados se omiten del plan del scope.

Continuar al Paso 0.5 planning.

**Backup defensivo:** si `agents-applicability.yml` NO existe o no es parseable → emitir aviso al user *"Config de aplicabilidad NO disponible · cero defaults silenciosos · necesito firma user explícita: ¿activo los 3 agentes domain-tight (`multi-tenant` + `atomicity` + `migration-safety`) o los skipeo todos?"* y ABORT hasta firma.

### Paso 0.5 · Planning automático del scope (NOVEDAD vs `/revisar`)

> **Por qué obligatorio:** repo grande (~440 archivos sensibles) NO entra en 1 pasada holística de 9 agentes Opus paralelos (context overflow · output diluido · hallazgos perdidos en ruido). El Paso 0.5 inventaria el repo · estima cardinalidad por familia técnica · decide modo simple vs modo por fases · presenta plan al user para firma 🔵 antes de gastar tokens.

**Procedimiento:**

1. **Inventario del repo por familia técnica** con `find` + `wc -l`. Familias canónicas (alineadas con foco de los 9 agentes):
   - **RPCs + atomicity:** `db/migrations/**/*.sql` · funciones `SECURITY DEFINER` · triggers.
   - **RLS + multi-tenant + audit:** policies en migraciones · helpers `current_user_has_perm` · audit_log.
   - **Render + snapshot + correctness:** `src/lib/services/**` (helpers puros · render histórico · módulos de negocio core del proyecto).
   - **a11y + i18n + migration-safety + tests:** `src/components/**` (UI) · `src/app/**` (routing + copy) · `tests/e2e/**` + `tests/sql/**` (cobertura).
2. **Estimar contexto requerido** por familia (LoC totales · # archivos · # capas).
3. **Decidir modo** (cardinalidad variable · Bif N = B 🔵 user upstream):
   - **Modo simple (1 fase):** si la suma estimada de tokens cabe holgadamente en 1 pasada de 9 agentes paralelos. Ejecutar Paso 1-5 sobre `main` completo en 1 corrida.
   - **Modo por fases (M fases):** si el inventario excede capacidad de 1 pasada. Agrupar agentes por afinidad técnica (Bif N = A 🔵 user upstream):
     - **Fase típica 1:** RPCs + atomicity (agentes `atomicity` + `architect` enfoque cross-RPC).
     - **Fase típica 2:** RLS + multi-tenant + audit (agentes `multi-tenant` + `security` + `architect` enfoque defense-in-depth).
     - **Fase típica 3:** render + snapshot + correctness (agentes `correctness` + `architect` enfoque asimetrías).
     - **Fase típica 4:** a11y + i18n + migration-safety + tests (agentes `a11y` + `i18n` + `migration-safety` + `tests`).
     - Las fases NO son hardcoded · el Paso 0.5 decide según inventario real (Bif 3 = B variable).
4. **Presentar plan al user** con formato canónico:

   ```text
   ## /revisar-main · Plan del scope · run RM-NNN
   - **Modo:** simple | por fases
   - **Fases:** N · cardinalidad según inventario
   - **Fase 1:** <familia técnica> · <# archivos> · <agentes asignados>
   - **Fase 2:** ...
   - **Estimación tokens por fase:** ~$5-10
   - **Estimación sesiones totales:** N (cada fase puede requerir sesión nueva con handoff regla #26)
   - **Próxima acción si firmás:** ejecutar Fase 1 ahora
   ```

5. **Esperar firma 🔵 user antes de gastar tokens.** ABORT si user objeta · re-plantear scope.

### Paso 1 · Pre-flight determinístico

Invocar el preflight (mismo script que `/revisar`):

```bash
bash scripts/local-ultrareview-preflight.sh
```

- **Timeout:** 600s (`Bash` tool con `timeout: 600000`).
- **Output:** `tmp/local-ultrareview-preflight-<timestamp>.txt`.
- **Comportamiento:** ABORT si typecheck o build fallan · WARN no-bloqueante si lint · test:sql · npm-audit fallan · termina con `=== PREFLIGHT OK ===`.

Si retorna exit ≠ 0 → cortar · reportar al user *"Preflight rojo · fixear typecheck/build y re-correr `/revisar-main` después del próximo commit."* · NO spawnear agentes (ahorro neto ~$5-10/fase).

### Paso 2 · Spawn de los 9 agentes review en paralelo (P10 fan-out · scope acotado por fase)

> **Atribución:** patrón P10 fan-out derivado de [addyosmani/agent-skills](../../references/external-doctrine/addyosmani-readme.md) (orchestration paralela + consolidator pattern · paridad heredada de `/revisar`).

**1 solo turno con N `Task` calls** (N según output del Paso 0.4 · típicamente 6, 7, 8 o 9 según flags). Cada `Task` call:

- **`subagent_type: "Explore"`** (paridad `/revisar` · validación empírica en sesión upstream).
- **Modelo:** Opus heredado.
- **`prompt`:** lee `.claude/skills/revisar-main/agents/<name>.md` (copia adaptada al modo holístico) e inyecta como contexto:
  - Reporte preflight completo.
  - **Lista de archivos del scope de la fase actual** (NO diff · output del inventario del Paso 0.5 filtrado por familia técnica asignada a la fase).
  - **NO PRP en curso** (modo holístico · sin scope de PRP individual).
- **Timeout por agente:** 600s.

Lista canónica de los 9 agentes adaptados (paridad `/revisar` con `revisar-main/agents/<nombre>.md` · spawn condicional según output del Paso 0.4):

| # | Agente | Path | Foco no-superpuesto adaptado al modo holístico | Domain-tight |
|---|---|---|---|---|
| 1 | architect | `agents/architect.md` | Simetría cross-módulo en TODO `main` · regla FIRME en call sites del repo completo · drift estructural acumulado | NO · universal · siempre corre |
| 2 | security | `agents/security.md` | OWASP sobre el repo · auth gates · secrets · XSS · SQLi · Zod en bordes (todos los endpoints existentes) | NO · universal · siempre corre |
| 3 | multi-tenant | `agents/multi-tenant.md` | RLS exhaustivo en TODAS las tablas · cross-tenant isolation cross-features · `current_user_has_perm` consistency | **SÍ** · solo si flag `multi-tenant.enabled = yes` |
| 4 | atomicity | `agents/atomicity.md` | RPCs atómicos en TODAS las migraciones · race conditions latentes · audit payload mirror cross-RPCs | **SÍ** · solo si flag `atomicity.enabled = yes` |
| 5 | tests | `agents/tests.md` | Cobertura de specs en `tests/e2e/regression/` + `tests/sql/` · gaps de regression-first FIRME · COVERAGE.md alineado | NO · universal · siempre corre |
| 6 | correctness | `agents/correctness.md` | Asimetrías cross-módulo entre módulos hermanos acumuladas · snapshot histórico · hydration safety · edge cases helpers | NO · universal · siempre corre |
| 7 | a11y | `agents/a11y.md` | WCAG AA en TODAS las superficies UI · target táctil ≥44×44px · keyboard nav · contraste | NO · universal · siempre corre |
| 8 | i18n | `agents/i18n.md` | Vocabulario AR-LATAM en TODO el copy · routing inglés vs copy español · TZ Argentina · currency | NO · amplio · siempre corre |
| 9 | migration-safety | `agents/migration-safety.md` | Idempotencia DDL en TODAS las migraciones · `SECURITY DEFINER` consistency · seeds UPSERT · audit payload completo | **SÍ** · solo si flag `migration-safety.enabled = yes` |

**Anti-pattern:** spawnear los 9 en turnos separados (pierde speedup paralelo · facturación redundante de context refresh).

### Paso 3 · Recolección de outputs

Misma lógica que `/revisar` Paso 3 (paridad estructural · ver [`.claude/skills/revisar/SKILL.md § Paso 3`](../revisar/SKILL.md)):

- Runtime emite notificaciones al completar cada agente.
- Cada agente devuelve bloque `## Agent: <name>` con findings shape SD-cos-N (severity · file · title · description · suggested fix · confidence · checklist item).
- `### No findings` cuenta como `0 findings` para el agente (entra en métricas).
- Timeout/error de un agente NO bloquea consolidator · marca su sección como `no respondió`.
- Concatenar los 9 outputs en 1 bloque separados por `## Agent: <name>` headers.

### Paso 4 · Spawn del consolidator (general-purpose)

**1 `Task` call con `subagent_type: "general-purpose"`** (necesita `Write` para persistir log).

- **Modelo:** Opus heredado.
- **Timeout:** 600s.
- **`prompt`:** lee `.claude/skills/revisar-main/consolidator.md` e inyecta como contexto:
  - Los 9 outputs concatenados.
  - El reporte preflight.
  - **Lista de archivos del scope de la fase** (NO diff stats · modo holístico).
  - **NO path al PRP en curso** (modo holístico · sin scope de PRP individual).
  - Path del log existente `docs/logs/revisar-main-log.md` (SD-cos-N · paridad `revisar-log.md`).

**Tareas del consolidator (paridad `/revisar` consolidator):** parse findings · dedupe · re-clasificar severidad · filtrar señal débil (`nit` con <2 detectores DESCARTA · Bif N = A heredado de `/revisar`) · asignar IDs estables (`RM-NNN.X` por fase del run · `rm_bug_NNN` por bug · SD-cos-N) · priorizar y escribir entrada en `docs/logs/revisar-main-log.md` · output ejecutivo.

**Diferencia clave vs `/revisar` consolidator:**

- **IDs `RM-NNN.X` con sufijo de fase** (X=1...M) en vez de `LR-NNN` (paridad simétrica · SD-cos-N).
- **`RM-NNN.0` reservado para reporte consolidado final** al cierre de la última fase del plan (síntesis de Fases 1...M · DTs nuevas abiertas · áreas verde).
- **Sin diff stats** (modo holístico · scope es lista de archivos por familia técnica).

### Paso 5 · Reporte ejecutivo al user + handoff automático si quedan fases

**Output del consolidator al agente principal:**

```text
## /revisar-main RM-NNN.X · resumen ejecutivo
- **Fase:** X de M (modo por fases) | única (modo simple)
- **Familia técnica auditada:** <ej: RPCs + atomicity>
- **Archivos cubiertos:** <#>
- **Findings consolidados:** <#critical> critical · <#normal> normal · <#nit-bl> nit (backlog) · <#desc> descartados por filtro
- **Cobertura agentes:** 9/9 corrieron · <#> con findings · <#> sin hallazgos
- **Log entry:** docs/logs/revisar-main-log.md § RM-NNN.X
- **Próxima acción:** <"resolver críticos vía PRP nuevo del producto" | "evaluar normales" | "OK · backlog en log">
- **Fases pendientes:** X+1 ... M (si modo por fases con pendientes) | ninguna
```

**Handoff automático entre fases (Bif N = A 🔵 user upstream):**

Si al cierre de la fase quedan fases pendientes del plan firmado en Paso 0.5:

1. El skill invoca regla [`session-handoff.md`](../../rules/session-handoff.md) #26 automático.
2. Genera archivo en `.claude/memory/project/revisar-main-handoff-<YYYY-MM-DD>[-fase-X-cerrada].md` con shape canónico 7 secciones obligatorias.
3. Reportar al user *"Fase X cerrada · pendientes fases X+1...M · handoff generado en `<path>` · próxima sesión retoma con `/revisar-main` (lee plan firmado del log + handoff)."*

Si fue la última fase (X = M · o modo simple), generar reporte consolidado `RM-NNN.0` en el log que sintetiza todas las fases del run + DTs nuevas abiertas + áreas verde · reportar al user *"Run RM-NNN completo · ver `docs/logs/revisar-main-log.md § RM-NNN.0` para reporte consolidado."*

**Regla FIRME que dispara post-reporte (paridad `/revisar`):** [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) — TODOS los findings (`critical` + `normal` + `nit-backlog`) se fixean SIEMPRE · cero diferimiento por severidad · estándar senior con regression-first FIRME ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) · los fixes pueden distribuirse en PRPs nuevos del producto que consuman cada finding del log entry.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Salto el Paso 0.5 planning · arranco los 9 agentes sobre `main` completo directo · ahorro tiempo" | NO. Bif N = B (🔵 user upstream) · cardinalidad variable según inventario · repo grande NO entra en 1 pasada (context overflow · output diluido · hallazgos perdidos en ruido). Saltar Paso 0.5 = gasto de tokens sin señal · típicamente $5-10 perdidos para descubrir que la corrida fue inútil. El Paso 0.5 cuesta minutos · ahorra ese gasto. |
| "Es igual que `/revisar` · uso `/revisar` con base SHA = root del repo y listo" | NO. `/revisar` está calibrado para diff vs main (PRP en curso) · los prompts de los 9 agentes referencian "diff vs main" como input · sin diff los agentes no tienen scope claro. `/revisar-main` tiene COPIA adaptada de los 9 agentes con § Role + § Input modificados al modo holístico (Bif N = A · cero coupling · cero riesgo). |
| "Modifico `/revisar` para que acepte modo holístico también · evito copiar 9 agentes" | NO. `/revisar` es contractual paso 4 del flujo del producto · cualquier modificación rompe el contrato. Bif N = A firmada 🔵 user upstream: copia adaptada cero coupling (paridad regla [`surgical-changes.md`](../../rules/surgical-changes.md) "NO tocar cosas ajenas"). |
| "Skipeo handoff automático entre fases · sigo en la misma sesión todas las fases" | NO. Bif N = A (🔵 user upstream) · handoff automático invocando regla #26. Razones: (a) sesión con M fases acumula contexto · degrada calidad por fatiga del agente (regla #9 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md)). (b) cada fase es 🟢 reversible · cerrar con handoff garantiza punto de retoma limpio. (c) si la sesión muere mid-flight, el handoff es el único contrato con la próxima sesión. |
| "El user firmó modo por fases pero corro modo simple porque me parece más rápido" | NO. La firma 🔵 user del Paso 0.5 es contractual · ejecutar modo distinto al firmado rompe el contrato. Si durante la ejecución descubrís que el plan original era subóptimo, frenar y re-presentar plan al user con justificación · NO improvisar. |
| "Un agente devolvió `### No findings` · skipeo registrarlo" | NO (paridad `/revisar`). Cero findings es señal válida · queda en el log con count `0` para métricas de cobertura agregadas + detección de agentes que sistemáticamente no encuentran nada (señal de calibración débil del prompt). |
| "Corro `/revisar-main` durante el paso 4 del flujo del producto en vez de `/revisar`" | NO. Skills distintos · scopes distintos. `/revisar` audita diff del PRP en curso (contractual paso 4) · `/revisar-main` audita estado holístico de `main`. Confundirlos rompe el flujo del producto y la auditoría holística. |

## Red flags

- 🚩 Estás por correr `/revisar-main` con `git status --porcelain` no vacío (Paso 0 violado · working tree sucio).
- 🚩 La branch actual NO es `main` y no hay firma user explícita de que la branch representa el estado a auditar.
- 🚩 Skipeas Paso 0.5 (planning automático) · vas a spawnear los 9 agentes sin haber inventariado el scope ni firmado plan con user.
- 🚩 El user firmó modo simple en Paso 0.5 pero el inventario sugiere modo por fases (o viceversa) · vas a ejecutar igual sin re-presentar plan.
- 🚩 El preflight retornó exit ≠ 0 y vas a spawnear los 9 agentes anyway.
- 🚩 Estás invocando los 9 `Task` calls en turnos separados (P10 fan-out violado · decisión #1 plan L paridad heredada).
- 🚩 Recibiste 9 outputs y vas a sintetizarlos vos mismo sin invocar el consolidator (filtrado Bif N = A se pierde · IDs `RM-NNN.X` no se asignan · log no se escribe).
- 🚩 Al cierre de fase con pendientes NO invocaste regla #26 (handoff automático violado · Bif 4 = A).
- 🚩 Generaste handoff fuera de `.claude/memory/project/` o con path que no sigue convención `revisar-main-handoff-<YYYY-MM-DD>[-fase-X-cerrada].md`.
- 🚩 Al cierre de la última fase NO generaste reporte consolidado `RM-NNN.0` en el log (síntesis cross-fase perdida).
- 🚩 Estás por intentar usar `/revisar-main` para auditar el diff de un PRP en curso · ese rol es de `/revisar` (paso 4 del flujo del producto · skill hermano).

## Verification

### Gates pre-planning + pre-fan-out

- [ ] **Paso 0 corrido:** working tree limpio · branch = main (o firma user) · `git rev-parse main` resuelve.
- [ ] **Paso 0.5 planning ejecutado:** inventario del repo por familia técnica · modo simple vs por fases decidido según cardinalidad · plan presentado al user · firma 🔵 user recibida antes de gastar tokens.
- [ ] **Preflight ejecutado:** `bash scripts/local-ultrareview-preflight.sh` corrió exit 0 · output guardado.
- [ ] **Paso 0.4 ejecutado:** `.claude/config/agents-applicability.yml` leído antes del Paso 0.5 planning · flags de los 3 agentes domain-tight parseados · cero flag en `unknown` spawneado sin firma user previa · lista de agentes a spawnear emitida al user con transparencia (`habilitados: <lista>` / `skipeados: <lista>`) según regla #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md).
- [ ] **Pieza 2 regla #35 sincronizada (cara humana):** `BUSINESS_LOGIC.md § 8 Constraints del dominio que activan sub-agentes` presente con tabla de los 3 flags (`multi_tenant` · `stock_atomicity` · `relational_db_with_migrations`) + valor (`unknown`/`yes`/`no`) + justificación 1-frase · sincronizada con valores actuales de `agents-applicability.yml` (cero canales divergentes).
- [ ] **Pieza 4a regla #35 verificable (banner top canónico uniforme):** cada uno de los 3 agentes domain-tight (`agents/multi-tenant.md` · `agents/atomicity.md` · `agents/migration-safety.md`) tiene banner top inmediato post-`# Agent:` con texto canónico `**⚠️ Domain-conditional agent.**` + cita a regla #35 + flag específico · texto uniforme entre los 3 (solo varían `<flag>` y `<descripción>`) · paridad con hermano paralelo en `/revisar/agents/`.
- [ ] **Pieza 4b regla #35 verificable (Pre-condition check matriz 3-way):** cada agente domain-tight tiene `## Pre-condition check` al INICIO del § Process con matriz completa: `enabled: no` → output exacto `### No findings · agent skipped (proyecto declara <flag>: no)` · `enabled: unknown` → output exacto `### No findings · agent skipped (proyecto NO declaró <flag>...)` · `enabled: yes` → continuar · backup defensivo si config no disponible.
- [ ] **Smoke `agents-domain-tight-have-precondition.sh` verde:** invariante mecánico de Pieza 4a + 4b validado en CI job `lint` (paridad `rules-shape-p8.sh`).

### Fan-out + consolidator por fase

- [ ] **N agentes spawneados en 1 turno** (N según output del Paso 0.4 · típicamente 6, 7, 8 o 9): P10 fan-out · N `Task` calls paralelas con `subagent_type: "Explore"` · scope acotado a familia técnica de la fase.
- [ ] **N outputs recolectados:** cada agente devolvió bloque `## Agent: <name>` con findings o `### No findings`.
- [ ] **Consolidator invocado:** 1 `Task` call con `subagent_type: "general-purpose"` · IDs `RM-NNN.X` asignados · filtro Bif N = A aplicado (`nit` con <2 detectores DESCARTADOS).
- [ ] **Log persistido:** entrada nueva `RM-NNN.X` en `docs/logs/revisar-main-log.md` con filas en § Resumen de runs + § Hallazgos consolidados + § Cobertura · métricas actualizadas.

### Continuidad multi-fase + reporte final

- [ ] **Handoff automático generado si quedan fases pendientes** en `.claude/memory/project/revisar-main-handoff-<YYYY-MM-DD>[-fase-X-cerrada].md` con shape canónico 7 secciones (regla #26).
- [ ] **Reporte consolidado `RM-NNN.0` generado al cierre de la última fase** del plan firmado · síntesis cross-fase + DTs nuevas abiertas + áreas verde.
- [ ] **Reporte ejecutivo emitido al agente principal** con counts por severidad · path al log entry · próxima acción recomendada.
- [ ] **Regla FIRME aplicada post-reporte:** `critical` + `normal` + `nit-backlog` se fixean ANTES de cerrar el ciclo del lint mensual · regression-first FIRME para cada fix · cero diferimiento por severidad ([`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)) · fixes pueden distribuirse en PRPs nuevos del producto.
- [ ] **NO se corrió durante paso 4 del flujo del producto** (ese rol es de `/revisar` · contractual · skills distintos).

**Cross-reference firme:**

- SoT contractual: [`lint-memory-periodic.md`](../../rules/lint-memory-periodic.md) (paridad operativa · trilogía de saneamiento mensual · `/revisar-main` lint código · `scripts/lint-memory.sh` lint memoria · `/auditar-dt` audit deudas técnicas).
- Hermana arquitectónica: skill [`/revisar`](../revisar/SKILL.md) (paso 4 del flujo del producto · scope diff vs main · misma arquitectura multi-agent · `/revisar-main` es scope holístico).
- Hermana operativa: [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md) (regla #35 · mismo mecanismo de 3/9 agentes domain-tight condicionales al config aplicado a scope holístico).
- Hermana operativa: [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (entrada tipo `lint` en `log.md` al cierre del ciclo mensual + log entry `RM-NNN.X` en `docs/logs/revisar-main-log.md`).
- Hermana operativa: [`session-handoff.md`](../../rules/session-handoff.md) (regla #26 · handoff automático entre fases si el planning Paso 0.5 disparó modo por fases).
- Hermana operativa: [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (post-reporte · todos los findings se fixean en PRPs nuevos del producto · cero diferimiento por severidad).
- Hermana operativa: skill [`/auditar-dt`](../auditar-dt/SKILL.md) (trilogía mensual · audit holístico de deudas técnicas cruzadas contra roadmap).
- Trigger: [`docs/logs/deadlines.md`](../../../docs/logs/deadlines.md) (`/arrancar` Paso 5 auto-propone cuando deadline mensual vence o ≤7 días).
