---
name: revisar
type: skill
description: "Multi-agent code review local del paso 4 del flujo de 6 pasos · 9 agentes Opus paralelos (architect · security · multi-tenant · atomicity · tests · correctness · a11y · i18n · migration-safety) + consolidator general-purpose con checklist 10 ítems + preflight bash determinístico + log persistente en docs/logs/revisar-log.md · default SÍ siempre en Modo C · gratis · cubre A-L de 2B.18 con énfasis en 3 dominios críticos que tu proyecto puede activar via config · 3/9 agentes son **domain-tight** (multi-tenant · atomicity · migration-safety) condicionales al config `.claude/config/agents-applicability.yml` leído en Paso 0.6 con branching yes/no/unknown (regla #35) · ejecución puede emitir ABORT si algún flag está en `unknown` esperando firma user. Activar cuando el usuario dice: revisar, revisalo, revisión, revision, auditá el diff, audita el diff, corré los agentes, corre los agentes, revisión final, revision final, revisá el código, revisa el codigo, checkea el diff, revisión multi-agente, revision multi-agente, auditoría paralela, auditoria paralela, post-ultrareview, post ultrareview, después del ultrareview, despues del ultrareview, post UR, después de UR, despues de UR, auditá agents-applicability, audita agents-applicability, qué agentes están activos, que agentes estan activos, revisá la config de agentes, revisa la config de agentes, auditá el config de agentes, audita el config de agentes."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/revisar` — paso 4 · Revisión del flujo de 6 pasos

> **Skill custom autocontenido** (Bif 1 = A · 🔵 user upstream). Materializa el plan L de `/local-ultrareview` (795 LoC archivadas) en el flujo nuevo · paridad estructural con `/arrancar` · `/planificar` · `/implementar`.
>
> **Inspiración estructural:** plan L original como semilla del SKILL.md + 9 agentes + consolidator + preflight + log · 3/9 agentes review derivan de personas [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) SD-AN (`architect ← code-reviewer` · `security ← security-auditor` · `tests ← test-engineer` · cita inline en cada [`agents/architect.md`](agents/architect.md) + [`agents/security.md`](agents/security.md) + [`agents/tests.md`](agents/tests.md)) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación.

## Overview

> **Propósito:** revisión multi-agente local del diff vs `main`. Spawnea 9 agentes Opus paralelos de foco no-superpuesto + 1 consolidator `general-purpose` con checklist 10 ítems (incluye simetría cross-módulo y verificación de reglas FIRMES en call sites). Preflight bash determinístico antes de gastar tokens · log persistente en `docs/logs/revisar-log.md` con namespace `LR-NNN`. Default SÍ siempre en Modo C · gratis · cubre las 12 categorías empíricas A-L de bugs con énfasis en 3 dominios críticos configurables (multi-tenant · atomicity · migration-safety).
>
> **Cuándo invocar (esquemático):** paso 4 del flujo nuevo de 6 pasos · post-`/implementar` · pre-`/validar`. Invocable manual con `/revisar` o `/revisar <PR-num>` · default automático en Modo C.
>
> **Qué NO hace:** ❌ NO fixea (sólo detecta · "siempre fixear todo, con calidad senior" lo hace el agente principal post-reporte) · ❌ NO sustituye al `/validar` (paso 5 · validación E2E con Playwright + Supabase MCPs) · ❌ NO mergea ni hace push (paso 6 · skill `/entregar`) · ❌ NO calibra prompts (eso es post-PRP-NNN con runs reales sobre PRPs del producto).

## When

**Aplica:** Modo C del flujo (PRP del producto en estado `EN PROGRESO` · post-`/implementar` cierre · pre-`/validar`). User dice *"revisar"* · *"revisalo"* · *"revisión"* · *"auditá el diff"* · *"corré los agentes"* · *"revisión final"* · *"revisá el código"* · *"checkea el diff"* · *"revisión multi-agente"* · *"auditoría paralela"* (SD-cos-N · vocabulario AR-LATAM-friendly).

**NO aplica:** Modo A (task trivial sin código) · Modo B (skill cerrado con flujo propio).

## Process

> **Estructura: 5 fases hardcoded del plan L.** Cada fase tiene gate determinístico antes de avanzar. ABORT temprano ahorra tokens (preflight evita ~$5/run si typecheck/build rompe). Plan L original archivado · cero acción operativa en el pack.

### Paso 0 · Validación de pre-condiciones

Antes de invocar el preflight, verificar 4 invariantes con `Bash`:

1. **Working tree limpio:** `git status --porcelain` retorna vacío. Si hay archivos sin commitear, ABORT con mensaje *"Working tree sucio · commiteá primero (cada fase del bucle cierra con commit local)."*
2. **Branch ≠ main:** `git rev-parse --abbrev-ref HEAD` ≠ `main`. ABORT si está en main (`/revisar` exige diff vs main · estar en main no tiene scope).
3. **Base SHA = main:** `git rev-parse main` resuelve. ABORT si `main` no existe localmente.
4. **Diff vs main no vacío:** `git diff main --name-only | wc -l` ≥ 1. ABORT si cero archivos cambiados.

Las 4 las cubre el preflight bash internamente (jobs 1-2) · esta fase es una pre-verificación antes del invoke del preflight para fail-fast.

**5. Self-check de fatiga · GATE FIRME (NO opcional · refinamiento iterativo upstream):** antes de spawneear los 9 agentes Opus paralelos del Paso 2 (operación costosa · ~5-10 min wall time · ~$5/run en consolidator), invocar mentalmente la regla #7 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · auto-evaluar los 6 indicadores cualitativos contra MI estado actual:

   1. Contexto cargado · re-leyendo archivos que ya leí hace 5+ turnos.
   2. Ambigüedad creciente · improvisando criterios que antes eran claros.
   3. Trabajo grande en una sentada · N acciones impecables + (N+1) se siente "apurada".
   4. Confusión de scope · no estoy seguro si el cambio entra al PRP o es drive-by.
   5. Decisiones repetidas · mismo tradeoff resuelto distinto cada vez.
   6. Sensación de "terminemos" · prisa por cerrar antes de validar.

**Si ≥1 indicador dispara** → emitir aviso formato canónico (estimación 🟢/🟡/🔴 + caminos A continuar / B handoff + recomendación early con sujeto explícito = agente) · esperar decisión user · NO avanzar al Paso 1 sin firma explícita. Skill operativo bajo demanda: [`/fatiga`](../fatiga/SKILL.md). Si user firma B → invocar [`/handoff`](../handoff/SKILL.md) (regla #26 [`session-handoff.md`](../../rules/session-handoff.md) como SoT del shape canónico) para retomar `/revisar` en sesión nueva con contexto liviano.

**Si cero indicadores disparan** → continuar al Paso 0.6.

**Por qué gate obligatorio (NO opcional):** `/revisar` es la operación más cara del skill set · spawnear 9 agentes Opus paralelos consume tokens y wall time no recuperables. Arrancar fatigado degrada la consolidación del Paso 4 (Bif 6 = A filter · IDs estables · escritura de log) y la inversión se pierde silenciosamente. La regla #7 § Anti-rationalization #1 prohíbe explícitamente *"queda poco · sigo y cierro"* — esa anti-excusa aplica simétricamente al arranque (decidir entrar al pipeline costoso fatigado es el mismo error de juicio).

### Paso 0.6 · Leer config de aplicabilidad de agentes domain-tight

> **Por qué obligatorio (NO opcional):** los 3 sub-agentes domain-tight del Paso 2 (`multi-tenant` · `atomicity` · `migration-safety`) asumen condiciones del dominio (multi-tenancy estricto · stock atomicity · BD relacional con migrations) que NO todo proyecto cumple. Si tu proyecto NO cumple la condición, spawnear el agente igual emite false positives + ensucia el log + cuesta tokens sin valor. Doctrina del mecanismo: regla firme #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md).
>
> **Por qué numerado 0.6 (NO 0.4 como en `/revisar-main`):** divergencia arquitectónica justificada · `/revisar` NO tiene Paso 0.5 planning (intermedio) · el paso config va inmediatamente después del Paso 0 pre-condiciones. Hermano paralelo: [`/revisar-main/SKILL.md § Paso 0.4`](../revisar-main/SKILL.md) (mismo behavior · numeración distinta por insertarse antes del Paso 0.5 planning nuevo del modo holístico · Bif 3 = B 🔵 user upstream).

Antes de spawnear sub-agentes (Paso 2), aplicar regla firme #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md) § Process Pieza 3 (5 sub-pasos contractuales): (1) leé el config con `Read` · (2) parseá los 3 flags · (3) si `unknown` → firma user · (4) construí lista a spawnear · (5) emití transparencia. Leé [`.claude/config/agents-applicability.yml`](../../config/agents-applicability.yml) con `Read` y parseá los 3 flags:

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

Continuar al Paso 1 (preflight).

**Backup defensivo:** si `agents-applicability.yml` NO existe o no es parseable → emitir aviso al user *"Config de aplicabilidad NO disponible · cero defaults silenciosos · necesito firma user explícita: ¿activo los 3 agentes domain-tight (`multi-tenant` + `atomicity` + `migration-safety`) o los skipeo todos?"* y ABORT hasta firma.

### Paso 1 · Pre-flight determinístico

Invocar el preflight con `Bash`:

```bash
bash scripts/local-ultrareview-preflight.sh
```

- **Timeout:** 600s (`Bash` tool con `timeout: 600000`).
- **Output:** `tmp/local-ultrareview-preflight-<timestamp>.txt` (path se infiere del stdout del script).
- **Comportamiento:** ABORT si typecheck o build fallan · WARN no-bloqueante si lint · test:sql · npm-audit fallan · termina con `=== PREFLIGHT OK ===` cuando todos los ABORT-jobs pasan.

Si el preflight retorna exit ≠ 0 → cortar el flujo · reportar al user *"Preflight rojo · fixear typecheck/build y re-correr `/revisar` después del próximo commit."* · NO spawnear los 9 agentes (ahorro neto ~$5).

Si el preflight retorna exit 0 → leer el archivo de output con `Read` · pasar el contenido completo como contexto a los 9 agentes en FASE 2.

### Paso 2 · Spawn de los 9 agentes review en paralelo (P10 fan-out)

> **Atribución:** patrón P10 fan-out derivado de [addyosmani/agent-skills](../../references/external-doctrine/addyosmani-readme.md) (orchestration paralela + consolidator pattern) + decisión #1 plan L (validación empírica del speedup ~3-4× sobre secuencial · upstream).

**1 solo turno con N `Task` calls** (N según output del Paso 0.6 · típicamente 6, 7, 8 o 9 según flags). El runtime los ejecuta concurrentemente · ahorro ~3-4× sobre secuencial. Cada `Task` call:

- **`subagent_type: "Explore"`** (decisión #2 plan L · validación empírica upstream · NO re-debatible).
- **Modelo:** Opus (heredado de la sesión · sin override).
- **`description` (3-5 palabras):** ej. *"Architect review diff"*.
- **`prompt`:** lee el archivo del agente correspondiente (`.claude/skills/revisar/agents/<name>.md`) y le inyecta como contexto:
  - Reporte preflight completo (`tmp/local-ultrareview-preflight-<timestamp>.txt`).
  - Diff completo vs main (`git diff main`).
  - Lista de archivos cambiados (`git diff main --name-only`).
  - Path absoluto del PRP en curso (`.claude/PRPs/PRP-NNN-*.md`).
- **Timeout por agente:** 600s (10 min).

Lista canónica de los 9 agentes (orden libre · paralelos · spawn condicional según output del Paso 0.6):

| # | Agente | Path | Foco no-superpuesto | Domain-tight |
|---|---|---|---|---|
| 1 | architect | `agents/architect.md` | Criterios PRP cumplidos · simetría cross-módulo · cambios quirúrgicos · regla FIRME en call sites | NO · universal · siempre corre |
| 2 | security | `agents/security.md` | OWASP · auth gates · secrets · XSS · SQLi · Zod en bordes | NO · universal · siempre corre |
| 3 | multi-tenant | `agents/multi-tenant.md` | RLS exhaustivo · cross-tenant isolation · `current_user_has_perm` | **SÍ** · solo si flag `multi-tenant.enabled = yes` |
| 4 | atomicity | `agents/atomicity.md` | RPCs atómicos · race conditions · audit payload mirror · operaciones atómicas multi-tabla | **SÍ** · solo si flag `atomicity.enabled = yes` |
| 5 | tests | `agents/tests.md` | Specs DoD · regression-first FIRME · COVERAGE.md actualizado · 1-2 filas vecinas | NO · universal · siempre corre |
| 6 | correctness | `agents/correctness.md` | Asimetrías cross-módulo entre módulos hermanos · snapshot histórico · hydration safety · edge cases helpers | NO · universal · siempre corre |
| 7 | a11y | `agents/a11y.md` | WCAG AA · alt · labels · contraste · keyboard nav · target táctil ≥44×44px | NO · universal · siempre corre |
| 8 | i18n | `agents/i18n.md` | Vocabulario canónico del dominio · routing en convención del proyecto · TZ explícita · currency formato consistente | NO · amplio · siempre corre |
| 9 | migration-safety | `agents/migration-safety.md` | Idempotencia DDL · `SECURITY DEFINER` · seeds UPSERT · audit payload completo | **SÍ** · solo si flag `migration-safety.enabled = yes` |

**Anti-pattern:** spawnear los 9 en turnos separados (1 turno por agente). Eso pierde el speedup paralelo y el modelo facturará tokens redundantes en context refresh.

### Paso 3 · Recolección de outputs

El runtime emite notificaciones automáticas cuando cada agente completa (no requiere polling activo del skill). Cada agente devuelve un bloque markdown estructurado siguiendo SD-cos-N:

```markdown
## Agent: <name>

### Finding 1
- **Severity:** critical | normal | nit
- **File:** path/to/file.ts:LINE
- **Title:** <1 línea descriptiva>
- **Description:** <2-4 líneas: qué está mal · por qué · root cause si aplica>
- **Suggested fix:** <2-4 líneas concretas>
- **Confidence:** high | medium | low
- **Checklist item:** <ítem del checklist del agente que el finding violó>

### Finding 2
...
```

Si un agente termina con `### No findings`, registrar `0 findings` para ese agente (entra en métricas del run · NO se omite).

Si un agente devuelve timeout o error, NO bloquear el consolidator · el consolidator marca su sección como `no respondió` y continúa con los 8 restantes (resilencia ante fallos individuales · decisión plan L § 2 paso 9).

Concatenar los 9 outputs en 1 bloque único (separados por los headers `## Agent: <name>`).

### Paso 4 · Spawn del consolidator (general-purpose)

**1 `Task` call con `subagent_type: "general-purpose"`** (necesita `Write` · subagent `Explore` no permite escribir el log).

- **Modelo:** Opus heredado.
- **Timeout:** 600s.
- **`prompt`:** lee `.claude/skills/revisar/consolidator.md` y le inyecta como contexto:
  - Los 9 outputs concatenados.
  - El reporte preflight (`tmp/local-ultrareview-preflight-<timestamp>.txt`).
  - Diff stats (`git diff main --stat`).
  - Path del PRP en curso.
  - Path del log existente (`docs/logs/revisar-log.md`).

**Tareas del consolidator (7 pasos · ver consolidator.md § Procedure):**

1. Parse findings de cada agente.
2. Dedupe (mismo `file:line` · títulos Levenshtein <30%).
3. Re-clasificar severidad (max entre detectores · `architect_override` permitido).
4. **Filtrar señal débil (Bif 6 = A · obligatorio):** `nit` con <2 detectores → DESCARTAR · `nit` con ≥2 → backlog · `normal`/`critical` siempre pasan.
5. Asignar IDs estables (`LR-NNN` por run · `lr_bug_NNN` por bug).
6. Priorizar (severidad descendente · confidence high→low · # detectores) + **mini-checklist quality-senior 6 puntos por finding (refinamiento iterativo upstream · regla #8 [`quality-standard-senior.md`](../../rules/quality-standard-senior.md))** → asignar `quality_review: passed | PENDING | REJECTED` por finding + escribir entrada en `docs/logs/revisar-log.md` siguiendo el shape canónico plan L § 6 (10 secciones · field `quality_review` en § Hallazgos consolidados).
7. Output ejecutivo al agente principal: counts por severidad + counts `quality_review` · top critical · link al log entry · próxima acción recomendada.

**Manejo de error de log:** si `docs/logs/revisar-log.md` existe pero NO es parseable, el consolidator escribe en `docs/logs/revisar-log.tmp.md` y emite alerta · NO sobrescribe el log corrupto.

### Paso 5 · Reporte ejecutivo al user

El skill recibe el output del consolidator y lo presenta al agente principal con esta estructura:

```text
## /revisar LR-NNN · resumen ejecutivo
- **PRP:** <path>
- **Commit revisado:** <hash> (<files> files · +<add>/-<del> LoC)
- **Findings consolidados:** <#critical> critical · <#normal> normal · <#nit-bl> nit (backlog) · <#desc> descartados por filtro
- **Calidad de suggested fixes:** <#quality_passed> passed · <#quality_PENDING> PENDING · <#quality_REJECTED> REJECTED (mini-checklist quality-senior 6 puntos · regla #8 [`quality-standard-senior.md`](../../rules/quality-standard-senior.md))
- **Cobertura agentes:** 9/9 corrieron · <#> con findings · <#> sin hallazgos
- **Log entry:** docs/logs/revisar-log.md § LR-NNN
- **Próxima acción:** <"resolver críticos antes del merge" | "evaluar normales" | "OK · backlog en log" | "re-validar quality_review PENDING antes de aplicar fix">
```

**Regla FIRME que dispara post-reporte:** [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) — TODOS los bugs detectados (`critical` + `normal` + `nit-backlog`) se fixean SIEMPRE antes de avanzar al paso 5 del flujo (`/validar`) · cero diferimiento por severidad · estándar senior con regression-first FIRME ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Salto el preflight · arranco los 9 agentes directo · ahorro 65s" | NO. Bif 2 = A (🔵 user upstream): preflight es gate determinístico · 6 jobs secuenciales · si typecheck/build rompe, el preflight ABORTA antes de spawnear los 9 agentes (ahorro neto ~$5/run). Saltar el preflight = pagar ~$5 para descubrir que el código no compila · señal degradada porque los agentes revisan código roto. |
| "1 agente detectó un finding · fixeo directo sin esperar al consolidator" | NO. Bif 6 = A (🔵 user upstream) y la lógica de dedup viven en el consolidator: `nit` con 1 detector se descarta · `normal`/`critical` requieren al menos parse del consolidator para asignar IDs estables (`LR-NNN`/`lr_bug_NNN`) y persistir en `docs/logs/revisar-log.md`. Saltar el consolidator rompe trazabilidad y deja el log incompleto. |
| "Skipeo escritura del log porque el bug es trivial" | NO. El log persistente es la fuente de verdad de cobertura · sin entrada en `docs/logs/revisar-log.md`, próximas runs no pueden cruzar (`§ Cobertura` falla) · re-revisión sobre el mismo scope se vuelve ciega. La REGLA DE ORO ítem 4.7 ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md)) aplica con timing bidireccional · cero excepciones. |
| "Un agente devolvió `### No findings` · skipeo registrarlo" | NO. Cero findings es señal informativa válida · queda en el log con count `0` para métricas de cobertura agregadas (`§ Métricas agregadas`) y para detectar agentes que sistemáticamente no encuentran nada (señal de calibración débil del prompt · disparador del workflow `## Apéndice § Cómo calibrar prompts`). |
| "Corro los 9 agentes en turnos separados (1 por turno) · más controlable" | NO. P10 fan-out = 1 turno con 9 `Task` calls paralelas · decisión #1 plan L (validación empírica upstream). Turnos separados pierden el speedup ~3-4× · facturan tokens redundantes en context refresh · y rompen el contrato del consolidator que espera los 9 outputs concatenados. |
| "Vibe Coding SD-V3: copy-paste sin entender · skip review porque 'es chico' · ignorar warnings del consolidator que entran al backlog" | NO. Las 3 anti-vibe (Vibe Coding sub-decisión SD-V3 · firmada user upstream · **derivadas de [`vibe-coding-schluntz.md`](../../references/external-doctrine/vibe-coding-schluntz.md) § 5 "Errores comunes"** · Erik Schluntz · Anthropic) son disparador inmediato de freno · el output del consolidator existe para que NINGUNA de las 3 ocurra. Si pegaste código sin entender, el `architect` o `correctness` lo va a marcar como `normal` · si "salteás review porque es chico", la regla FIRME ([`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)) NO admite excepción por tamaño · si ignorás backlog, lo escribís en `docs/logs/technical-debt.md` con disparador (NO es "ignorar"). |
| "El consolidator pescó un `nit` con 1 detector pero se ve importante · lo salvo igual y lo subo a `normal`" | NO. Bif 6 = A (🔵 user upstream) filtro contractual del consolidator: `nit` con 1 detector se **descarta** sin excepción · `normal`/`critical` con cualquier count pasan. La doctrina del umbral `<2` está embebida en `consolidator.md` step 4 (EXE-NNN): **calidad de señal** (2+ detectores independientes = señal real · 1 detector = posible falso positivo del agente individual). "Se ve importante" es exactamente la racionalización que el filtro atrapa · si genuinamente es importante, otro agente debería haberlo detectado también · si no lo detectó nadie más, la severidad real es `nit` (no `normal` artificialmente subido). Excepción única: `architect_override` degrada un finding (critical→normal · normal→nit) pero NUNCA lo inmuniza al filtro `<2 detectores` · el `nit` downgraded sigue descartándose si no acumula segundo detector. Cross-ref: regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) § Anti-rationalization #4 "no diferir por severidad" rebate el caso simétrico (subir nit en vez de cerrarlo) · este filtro previene el ruido downstream antes del fix. |

## Red flags

- 🚩 Estás por correr `/revisar` con `git status --porcelain` no vacío (FASE 0 violada · working tree sucio).
- 🚩 La branch actual es `main` (FASE 0 violada · `/revisar` exige branch ≠ main).
- 🚩 `git diff main --name-only | wc -l` retorna `0` y vas a invocar el preflight igual.
- 🚩 Estás por invocar el preflight sin haber ejecutado el self-check de fatiga del Paso 0 ítem 5 (regla #7 [`fatigue-self-evaluation.md`](../../rules/fatigue-self-evaluation.md) · gate obligatorio · NO opcional).
- 🚩 Self-check de fatiga emitió aviso 🟡/🔴 y arrancaste el preflight sin firma del user en camino A continuar o B handoff.
- 🚩 El preflight retornó exit ≠ 0 (typecheck o build rojo) y vas a spawnear los 9 agentes anyway.
- 🚩 Estás invocando los 9 `Task` calls en turnos separados en vez de 1 turno con P10 fan-out (decisión #1 plan L violada).
- 🚩 Recibiste 9 outputs y vas a sintetizarlos vos mismo sin invocar el consolidator (filtrado Bif 6 = A se pierde · IDs estables no se asignan · log no se escribe).
- 🚩 El consolidator escribió en `docs/logs/revisar-log.tmp.md` (señal de error de log existente) y NO emitiste alerta al user.
- 🚩 El reporte ejecutivo final NO incluye `LR-NNN` o el path al log entry · trazabilidad rota.
- 🚩 Estás por avanzar al paso 5 del flujo (`/validar`) con findings `critical` o `normal` sin fixear (regla FIRME [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) violada).
- 🚩 Estás corriendo `/revisar` sobre algo que no es un PRP del producto en Modo C · `/revisar` aplica solo a PRPs del producto en Modo C.

## Verification

### Gates pre-fan-out

- [ ] **FASE 0 corrida:** working tree limpio (`git status --porcelain` empty) · branch ≠ main · `git rev-parse main` resuelve · diff vs main no vacío · self-check de fatiga ejecutado (cero indicadores cualitativos disparando O aviso canónico emitido + user firmó camino A continuar).
- [ ] **Preflight ejecutado:** `bash scripts/local-ultrareview-preflight.sh` corrió y emitió output a `tmp/local-ultrareview-preflight-<timestamp>.txt` · exit 0.
- [ ] **Paso 0.6 ejecutado:** `.claude/config/agents-applicability.yml` leído al inicio · flags de los 3 agentes domain-tight parseados · cero flag en `unknown` spawneado sin firma user previa · lista de agentes a spawnear emitida al user con transparencia (`habilitados: <lista>` / `skipeados: <lista>`) según regla #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md).
- [ ] **Pieza 2 regla #35 sincronizada (cara humana):** `BUSINESS_LOGIC.md § 8 Constraints del dominio que activan sub-agentes` presente con tabla de los 3 flags (`multi_tenant` · `stock_atomicity` · `relational_db_with_migrations`) + valor (`unknown`/`yes`/`no`) + justificación 1-frase · sincronizada con valores actuales de `agents-applicability.yml` (cero canales divergentes).
- [ ] **Pieza 4a regla #35 verificable (banner top canónico uniforme):** cada uno de los 3 agentes domain-tight (`agents/multi-tenant.md` · `agents/atomicity.md` · `agents/migration-safety.md`) tiene banner top inmediato post-`# Agent:` con texto canónico `**⚠️ Domain-conditional agent.**` + cita a regla #35 + flag específico · texto uniforme entre los 3 (solo varían `<flag>` y `<descripción>`).
- [ ] **Pieza 4b regla #35 verificable (Pre-condition check matriz 3-way):** cada agente domain-tight tiene `## Pre-condition check` al INICIO del § Process con matriz completa: `enabled: no` → output exacto `### No findings · agent skipped (proyecto declara <flag>: no)` · `enabled: unknown` → output exacto `### No findings · agent skipped (proyecto NO declaró <flag>...)` · `enabled: yes` → continuar · backup defensivo si config no disponible.
- [ ] **Smoke `agents-domain-tight-have-precondition.sh` verde:** invariante mecánico de Pieza 4a + 4b validado en CI job `lint` (paridad `rules-shape-p8.sh`).

### Fan-out + consolidator

- [ ] **N agentes spawneados en 1 turno** (N según output del Paso 0.6 · típicamente 6, 7, 8 o 9): P10 fan-out · N `Task` calls paralelas con `subagent_type: "Explore"` · modelo Opus · timeout 600s.
- [ ] **N outputs recolectados:** cada agente devolvió bloque `## Agent: <name>` con findings o `### No findings` · timeouts/errores marcados explícito en el consolidator (`no respondió`).
- [ ] **Consolidator invocado:** 1 `Task` call con `subagent_type: "general-purpose"` · 7 tareas en orden (parse → dedupe → re-clasificar → filtrar Bif 6 = A → IDs estables → priorizar+escribir log → output ejecutivo).
- [ ] **Filtrado Bif 6 = A aplicado:** `nit` con <2 detectores DESCARTADOS · `nit` con ≥2 al backlog · `normal`/`critical` siempre pasan · counts reportados en métricas del run.
- [ ] **Grep doc obsoleta normaliza diferimiento aplicado (consolidator sub-paso 6.7 · refinamiento iterativo upstream):** `git diff main --name-only -- '*.md'` listado · `grep -nE "diferible|fix oportunista|para próximo PR|deferred|skipear por ahora"` corrido por cada `.md` modificado · si algún match, finding nuevo agregado al log con severity `normal` (bypass filtro Bif 6 = A · grep determinístico cuenta como detector real · paridad regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) § Red flags + § Verification).

### Persistencia + reporte

- [ ] **Log persistido:** entrada nueva en `docs/logs/revisar-log.md` con `LR-NNN` correlativo · filas en § Resumen de runs + § Hallazgos consolidados + § Cobertura · métricas agregadas actualizadas.
- [ ] **Reporte ejecutivo emitido al agente principal** con counts por severidad · log entry path · próxima acción recomendada.
- [ ] **Regla FIRME aplicada post-reporte:** `critical` + `normal` + `nit-backlog` se fixean ANTES de avanzar al paso 5 (`/validar`) · regression-first FIRME para cada fix · cero diferimiento por severidad ([`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)).

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 4`](../../../WORKFLOW.md) (multi-agent paralelo · 9 agentes Opus + consolidator · gates pre-merge sobre el diff).
- Hermana operativa: [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md) (regla #35 · 3/9 agentes domain-tight condicionales al config `.claude/config/agents-applicability.yml` con branching yes/no/unknown).
- Hermana operativa: [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (todos los hallazgos críticos + normales + nit-backlog se fixean antes del paso 5 · cero diferimiento por severidad).
- Hermana operativa: [`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) (cada fix de hallazgo viene con spec antes del fix + 1-2 filas vecinas).
- Hermana operativa: [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) (hallazgo out-of-scope detectado por consolidator · DT en el acto con 8 campos contractuales).
- Hermana arquitectónica: skill [`/revisar-main`](../revisar-main/SKILL.md) (lint mensual de código · scope holístico sobre `main` · misma arquitectura multi-agent).
- Predecesor: skill [`/implementar`](../implementar/SKILL.md) (paso 3 · cierre del bucle agéntico genera el diff a revisar).
- Sucesor: skill [`/validar`](../validar/SKILL.md) (paso 5 · arranca cuando consolidator emite 0 críticos/normales/nit-backlog).
