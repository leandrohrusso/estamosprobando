# WORKFLOW del proyecto — flujo de 6 pasos + modos A/B/C

> Cómo trabajamos en el proyecto. Este documento es **doctrina**: el flujo · los modos · las decisiones cerradas · los criterios operativos. Las reglas firmes que enmarcan cada paso viven en [`.claude/rules/`](.claude/rules/) (shape P8) e indexadas en [`CLAUDE.md`](CLAUDE.md). Los skills que ejecutan cada paso viven en [`.claude/skills/`](.claude/skills/).

## § 1 · Punto de entrada

Toda sesión arranca con el skill [`/arrancar`](.claude/skills/arrancar/SKILL.md):

- Lee los 3 archivos canónicos del proyecto (`BUSINESS_LOGIC.md` · `WORKFLOW.md` · `CLAUDE.md`) + la extensión operativa (`docs/logs/technical-debt.md`).
- Mapea estado del repo (PRPs activos · DTs abiertas · deadlines vencidos · handoffs en `.claude/memory/project/`).
- Aplica el protocolo de auto-orient embebido en su § Process.
- Propone próximo paso al user en formato **Modo A/B/C** (ver § 5 abajo).

## § 2 · Por qué este flujo

El flujo de 6 pasos está derivado de doctrina externa adoptada explícitamente · cero invención propia · cada paso cita inline su SoT.

> **Anclaje filosófico (Erik Schluntz · Anthropic):** *"Cuando tenés 22k líneas de código generado por LLMs en un solo PR, no podés revisar línea por línea. Tenés que verificar **comportamiento** — stress tests · end-to-end tests · validaciones a nivel de sistema."*
>
> El flujo de 6 pasos materializa ese principio: cada paso tiene su criterio de éxito **binario y verificable**, no subjetivo. La verificación de comportamiento (paso 5 `/validar` con matriz CSV exhaustiva) y la revisión multi-agente (paso 4 `/revisar` con 9 agentes Opus paralelos) son los dos gates pre-merge que aseguran calidad cuando el volumen de código generado excede la capacidad humana de review línea-por-línea.

Snapshots inmutables de la doctrina fuente viven en [`.claude/references/external-doctrine/`](.claude/references/external-doctrine/):

| Snapshot | Doctrina que aporta al pack |
|---|---|
| [`karpathy-claude-md.md`](.claude/references/external-doctrine/karpathy-claude-md.md) | Gobierno del agente · 7 principios (think-before-coding · simplicity-first · surgical-changes · goal-driven-execution) |
| [`karpathy-examples.md`](.claude/references/external-doctrine/karpathy-examples.md) | Ejemplos antes/después de los 7 principios · escenarios concretos para internalizar el patrón |
| [`karpathy-llm-wiki.md`](.claude/references/external-doctrine/karpathy-llm-wiki.md) | Paradigma llm-wiki · 3 capas (índice · entries · pointers externos) · 4 ops empíricas (`ingest` · `query` · `lint` · `bulk-ingest`) |
| [`karpathy-llm-wiki-video.md`](.claude/references/external-doctrine/karpathy-llm-wiki-video.md) | Cita inline contractual del skill `/memory-manager` · narrative completo de las 4 ops |
| [`addyosmani-readme.md`](.claude/references/external-doctrine/addyosmani-readme.md) | Shape autocontenido P8 (Overview · When · Process · Anti-rationalization · Red flags · Verification) · invocabilidad por skill |
| [`addyosmani-agents.md`](.claude/references/external-doctrine/addyosmani-agents.md) | Multi-agent paralelo + consolidator pattern · base del shape de `/revisar` y `/revisar-main` |
| [`vibe-coding-schluntz.md`](.claude/references/external-doctrine/vibe-coding-schluntz.md) | Verificación de comportamiento · gates pre-merge · spec-driven development (anclaje filosófico del flujo de 6 pasos) |

## § 3 · Los 6 pasos del flujo (Modo C · PRP del producto)

| Paso | Skill | Rol | DoD binario |
|---|---|---|---|
| **1** | [`/arrancar`](.claude/skills/arrancar/SKILL.md) | Contexto · carga del estado del proyecto + roadmap + modo A/B/C propuesto | User decide Modo A/B/C |
| **2** | [`/planificar`](.claude/skills/planificar/SKILL.md) | Planificación · genera PRP con bifurcaciones firmadas 🔵 user · 4 sub-agentes pre/post-draft (`architect-planning` · `complexity` · `historical-precedent` · `skeptic`) | PRP en estado APROBADO con bifurcaciones firmadas |
| **3** | [`/implementar`](.claude/skills/implementar/SKILL.md) | Implementación · bucle agéntico por fases con DoD por fase + commit local por fase + tests del DoD | Última fase cerrada · `typecheck` + `build` verde · commit local final |
| **4** | [`/revisar`](.claude/skills/revisar/SKILL.md) | Revisión · 9 sub-agentes Opus paralelos (`architect` · `security` · `multi-tenant` · `atomicity` · `tests` · `correctness` · `a11y` · `i18n` · `migration-safety`) + consolidator `general-purpose` con checklist 10 ítems | 0 findings `critical` + `normal` + `nit` (regla #10 [`always-fix-all-bugs`](.claude/rules/always-fix-all-bugs.md)) |
| **5** | [`/validar`](.claude/skills/validar/SKILL.md) | Verificación · matriz CSV exhaustiva 100% verde + Playwright MCP + credenciales reales + spec PRINCIPIO 6 (regression-first) por cada Falla | CSV 100% verde (Funciona · Diferido justificado) · reporte archivado |
| **6** | [`/entregar`](.claude/skills/entregar/SKILL.md) | Entrega · `ci:local` 6/6 jobs verde + push único a `origin/dev` + PR + decisión user `/ultrareview <PR#>` SÍ/NO + merge `--squash` a `main` + `sync-dev-after-squash-merge.sh` | PR mergeado a `main` · `dev` sincronizado · entrada `prp-close` en `log.md` |

> **Status tracker visible** (regla #25 [`status-tracker-visible.md`](.claude/rules/status-tracker-visible.md)): durante toda sesión en Modo C, el agente mantiene visible un tracker de los 6 pasos al inicio de cada respuesta principal hasta que la sesión cierre.

## § 4 · Auto-evaluación al cierre

Al cerrar cualquier paso del flujo, el agente aplica el checklist obligatorio de la **REGLA DE ORO docs y memoria** (regla #18 [`golden-rule-docs-memory.md`](.claude/rules/golden-rule-docs-memory.md)): 6 ítems indispensables (roadmap · PRP · JSDoc · memoria · CSV/DT/ultrareview log · canónicos · commit local). El ítem aplicable depende del paso (ver § Mapping de la regla).

**Auto-evaluación de fatiga** (regla #9 [`fatigue-self-evaluation.md`](.claude/rules/fatigue-self-evaluation.md)): el agente monitorea su propio estado (MI contexto cargado · MI acumulación de turnos · MI sensación de "terminemos"). Cuando ≥1 indicador cualitativo se dispara, emite aviso obligatorio al user con sujeto explícito = agente + estimación 🟢/🟡/🔴 + 2 caminos (A continuar / B handoff) + recomendación early. El user decide A o B. Skill bajo demanda: [`/fatiga`](.claude/skills/fatiga/SKILL.md).

**Handoff entre sesiones** (regla #26 [`session-handoff.md`](.claude/rules/session-handoff.md)): si el user firma camino B o el agente cierra fase 🔴 punto-de-no-retorno, generar archivo handoff en `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` con shape canónico de 7 secciones. Skill bajo demanda: [`/handoff`](.claude/skills/handoff/SKILL.md).

## § 5 · Modos A / B / C

El skill `/arrancar` propone uno de 3 modos por turno:

| Modo | Cuándo aplica | Skill que ejecuta |
|---|---|---|
| **Modo A** | Task trivial · sin fases · sin riesgo · ≤30 LoC · scope claro | Edits directos con `Edit` · `Bash` · sin PRP |
| **Modo B** | Skill cerrado con flujo propio (ej: `/fatiga` · `/handoff` · `/documentar` · `/memory-manager <subcmd>` · `/auditar-dt`) | Invocar el skill correspondiente |
| **Modo C** | PRP del producto · feature compleja · bucle agéntico · gates pre-merge | Pasos 1-6 del flujo arriba |

**Decisión binaria:** si la task entra en Modo A o B → ejecutar directo. Si entra en Modo C → arrancar con `/planificar` (paso 2). El user firma el modo si hay ambigüedad.

## § 6 · Política de pushes y CI runs

> Política firme operativa codificada como satélite [`push-and-ci-policy.md`](.claude/rules/push-and-ci-policy.md) (regla #27 · activa desde el día 1 del proyecto).

**Resumen ejecutivo:**

- **1 push = 1 PR = 1 CI por PRP del producto.** Cero pushes intermedios · cero CI redundantes.
- **Validaciones distribuidas durante el bucle** (typecheck + build per-fase del paso 3 · spec PRINCIPIO 6 per-fix del paso 5) para que `ci:local` del paso 6 pase al primer intento.
- **Backup automático** post-cada-commit a `origin/dev-backup` vía hook `.husky/post-commit` (workflow filtra `pull_request:` only · cero CI sobre backup).
- **`sync-dev-after-squash-merge.sh` obligatorio** inmediato post `gh pr merge --squash` (sin él, próximo PRP debugea horas el "por qué CI no arranca").
- **`[skip ci]` prohibido en HEAD del PR** (rompe trigger CI remoto silenciosamente).
- **Orden operativo paso 6:** commit + push ANTES de arrancar `ci:local` en background (evita race con dev server typecheck).

Detalle completo (escenarios · anti-rationalization · verification · recovery) en el satélite.

## § 6.5 · Matriz de desempate de triggers conversacionales ambiguos

> **Por qué esta sección:** algunos triggers conversacionales aparecen en 2+ skills sin qualifier explícito (`auditá` · `cerrá` · `revisar` · `verificá`). Sin matriz canónica, el agente o el harness elige inconsistentemente y el user obtiene invocación incorrecta. Esta matriz es la SoT de desempate · prevalece sobre cualquier interpretación implícita de los triggers individuales en frontmatter de skills.

| Palabra base | Skill invocado | Condición/qualifier típico | Ejemplos canónicos |
|---|---|---|---|
| **auditá / audita** | `/revisar` | qualifier "diff" · "PRP" · "código" · paso 4 del flujo activo | "auditá el diff" · "auditá el código del PRP" · "auditoría paralela" |
| | `/revisar-main` | qualifier "main" · "holístico" · "todo el repo" · cadencia mensual | "auditá main" · "auditoría holística" · "auditá todo el repo" |
| | `/auditar-dt` | qualifier "DTs" · "deudas" · "technical-debt" · cadencia mensual | "auditá las DTs" · "qué deudas tenemos" · "auditá technical-debt" |
| | `/documentar` | qualifier "checklist" · "regla de oro" · cierre de paso | "auditá el checklist" · "auditá la regla de oro" |
| **verificá / verifica** | `/validar` | qualifier "funcionamiento" · "PRP" · "app" · paso 5 del flujo | "verificá funcionamiento" · "verificá que funciona el PRP" |
| | `/documentar` | qualifier "checklist" · "cierre" | "verificá el checklist" · "verificá el cierre" |
| **revisar** (sin qualifier) | `/revisar` | default · paso 4 del flujo activo · sobre diff actual | "revisar" solo · "revisalo" · "revisión final" |
| | `/revisar-main` | qualifier "main" · "el repo" · "holístico" | "revisar main" · "revisar el repo" · "revisión holística" |
| **cerrá / cerra** | `/handoff` | qualifier "sesión" · "y handoff" · "mid-flight" · "pasame a sesión nueva" | "cerrá la sesión" · "cerrá y handoff" · "cortemos acá" |
| | `/documentar` | qualifier "paso" · "prolijo" · dentro de paso 3/5 | "cerrá el paso" · "cerrar prolijo" · "cierre del paso" |
| | `/entregar` | qualifier "PRP" · "y mergeá" · paso 6 del flujo | "cerrá el PRP" · "cerrá y mergeá" · "cierre del PRP" |

**Regla operativa:** cuando el user invoca un trigger ambiguo sin qualifier (ej: solo "auditá" o solo "cerrá"), el agente DEBE pedir desambiguación corta antes de invocar skill (1 línea · ej: *"¿auditá el diff (/revisar) · main (/revisar-main) · DTs (/auditar-dt) · o el checklist (/documentar)?"*). Cero ejecución de skill default sin confirmación cuando hay ambigüedad real.

**Defaults declarados (cuando NO hay qualifier y el contexto del flujo es claro):**

- Si el paso actual del flujo es **paso 4**: `revisar` solo → `/revisar`.
- Si el paso actual es **mensual / lint** sin PRP activo: `revisar` solo → `/revisar-main`.
- Si el contexto es **cierre de fase del paso 3 o paso 5**: `cerrá` solo → `/documentar`.
- Si el contexto es **paso 6**: `cerrá` solo → `/entregar`.
- Si el contexto es **fatiga firmada camino B o user pidió handoff explícito**: `cerrá` solo → `/handoff`.

## § 7 · Decisiones cerradas sobre el flujo

> **Vacío al boot del pack.** Cuando el proyecto cierre una decisión que aplique a sesiones futuras (ej: bifurcación arquitectónica firmada 🔵 user que cambia cómo se trabaja un área del codebase · refinamiento de política de pushes · etc), agregar fila acá con pointer a la memoria correspondiente en `.claude/memory/project/`.

| Fecha | Decisión | Bif | Pointer |
|---|---|---|---|
| *(vacío al boot · agregar fila cuando el proyecto cierre una decisión que aplique a sesiones futuras)* | — | — | — |

## § 8 · Mantenimiento periódico

Trilogía de saneamiento mensual + cadencia indexada en [`docs/logs/deadlines.md`](docs/logs/deadlines.md):

| Skill / Script | Scope | Cadencia | Output |
|---|---|---|---|
| [`/revisar-main`](.claude/skills/revisar-main/SKILL.md) | Lint mensual de **código** · auditoría holística del estado completo de `main` · 9 agentes Opus + consolidator | Mensual + ad-hoc | `docs/logs/revisar-main-log.md` (paridad `revisar-log.md`) |
| [`scripts/lint-memory.sh`](scripts/lint-memory.sh) | Lint mensual de **memoria** · 6 criterios (contradicciones · stale · orphan · etc) · read-only | Mensual | Reporte + entry `lint` en `.claude/memory/log.md` |
| [`/auditar-dt`](.claude/skills/auditar-dt/SKILL.md) | Audit mensual de **deudas técnicas** · cruza DTs activas contra roadmap + PRPs · 3 baldes (urgentes / latentes / obsoletas) · cero side effects | Mensual + ad-hoc | Reporte estructurado · fixes via PRPs nuevos |

**Archivado periódico de `log.md`** (cada 14 días · regla #20 [`log-chronology-append-only.md`](.claude/rules/log-chronology-append-only.md) § Archivado periódico): cuando el log crece, `bash scripts/archive-log.sh` mueve entries a `.claude/memory/_archive/log-<YYYY-MM-DD>.md` y deja cross-ref en el log activo.

`/arrancar` Paso 5 auto-propone ejecución cuando un deadline vence o está ≤7 días.

## § 9 · Convenciones

- **Naming de PRPs:** `PRP-NNN-<feature-corta>.md` bajo `.claude/PRPs/` · NNN correlativo.
- **Estados del PRP** (header al cierre de cada paso del flujo de 6 · regla #18 § Mapping):
  - Paso 2 cerrado → `APROBADO` (bifurcaciones firmadas).
  - Paso 3 cerrado → `EN PROGRESO (paso 3 cerrado · 4 + 5 + 6 pendientes)`.
  - Paso 4 cerrado → `EN PROGRESO (paso 4 cerrado · 5 + 6 pendientes)`.
  - Paso 5 cerrado → `EN PROGRESO (paso 5 cerrado · 6 pendiente)`.
  - Paso 6 cerrado → `COMPLETADO` (post-merge a `main`).
- **Auto-blindaje:** el agente debe pre-validar regresión heredada (regla #16 [`pre-validation-inherited-regression.md`](.claude/rules/pre-validation-inherited-regression.md)) antes de la Fase 1 del bucle · matriz de 4 escenarios (A/B/C/D) decide gate level.
- **Validación al cierre:** `npm run ci:local` 6/6 jobs verde es gate confirmatorio paso 6 antes del push (regla #27).
- **Constraints no negociables del proyecto destino:** vivien en [`BUSINESS_LOGIC.md § 8`](BUSINESS_LOGIC.md). El agente las consulta al inicio de cada PRP y verifica que el scope no las viola.

## § 10 · Glosario de skills del pack

Los 15 skills del pack viven en [`.claude/skills/`](.claude/skills/) con shape canónico P8 + frontmatter `name + description + allowed-tools`. Cada uno autocontenido · invocable vía `/<skill>` desde el agente principal.

**6 skills del flujo de 6 pasos · pasos 2 y 4 con 2 variantes cada uno:**

| Paso | Skill | Resumen |
|---|---|---|
| 1 | [`/arrancar`](.claude/skills/arrancar/SKILL.md) | Boot de sesión · carga contexto + propone modo (A/B/C · C-simple vs C-complejo) |
| 2 | [`/planificar`](.claude/skills/planificar/SKILL.md) | Variante **compleja** · genera PRP con 4 sub-agentes pre/post-draft |
| 2 | [`/planificar-simple`](.claude/skills/planificar-simple/SKILL.md) | Variante **simple** · mini-PRP sin multi-agent · gate de escalación a `/planificar` mid-skill |
| 3 | [`/implementar`](.claude/skills/implementar/SKILL.md) | Bucle agéntico por fases con DoD + commit local |
| 4 | [`/revisar`](.claude/skills/revisar/SKILL.md) | Variante **compleja** · 9 agentes Opus paralelos + consolidator + log persistente |
| 4 | [`/revisar-simple`](.claude/skills/revisar-simple/SKILL.md) | Variante **simple** · revisión rápida del agente principal sin multi-agent · cero log · gate de escalación a `/revisar` mid-skill |
| 5 | [`/validar`](.claude/skills/validar/SKILL.md) | Matriz CSV 100% verde con Playwright MCP |
| 6 | [`/entregar`](.claude/skills/entregar/SKILL.md) | `ci:local` + push único + merge `--squash` |

**7 skills auxiliares:**

| Skill | Resumen |
|---|---|
| [`/fatiga`](.claude/skills/fatiga/SKILL.md) | Self-check de fatiga del agente bajo demanda · invoca regla #9 como SoT |
| [`/handoff`](.claude/skills/handoff/SKILL.md) | Generar handoff entre sesiones · invoca regla #26 como SoT |
| [`/documentar`](.claude/skills/documentar/SKILL.md) | Aplicar REGLA DE ORO docs/memoria bajo demanda · invoca regla #18 como SoT |
| [`/memory-manager`](.claude/skills/memory-manager/SKILL.md) | Sistema de memoria · 4 sub-comandos (`ingest` · `query` · `lint` · `bulk-ingest`) |
| [`/auditar-dt`](.claude/skills/auditar-dt/SKILL.md) | Audit mensual de deudas técnicas · cero side effects |
| [`/revisar-main`](.claude/skills/revisar-main/SKILL.md) | Lint mensual de código · auditoría holística de `main` |
| [`/consultor`](.claude/skills/consultor/SKILL.md) | Rol consultor en sesión paralela read-only · invoca regla #37 como SoT · cero edits del estado del producto · user-as-bridge con la sesión ejecutora |

**Stack adaptation banner** ⚙️ inyectado en los 7 SKILLs principales: los ejemplos del cuerpo asumen Next.js + Supabase + Playwright + GitHub Actions + Husky. Si tu stack difiere, adaptá MCP names + patrones + tooling según el banner.

**Mecanismo de aplicabilidad de sub-agentes domain-tight** (regla firme #35 [`agents-conditional-by-domain.md`](.claude/rules/agents-conditional-by-domain.md)): los skills [`/revisar`](.claude/skills/revisar/SKILL.md) y [`/revisar-main`](.claude/skills/revisar-main/SKILL.md) spawnean 9 sub-agentes Opus paralelos · 6 universales/amplios siempre corren · 3 domain-tight (`multi-tenant` · `atomicity` · `migration-safety`) corren SOLO si el proyecto declara `<flag>: yes` en [`.claude/config/agents-applicability.yml`](.claude/config/agents-applicability.yml) (alimentado desde [`BUSINESS_LOGIC.md § 8 Constraints del dominio que activan sub-agentes`](BUSINESS_LOGIC.md)). El bootstrap del proyecto destino llena los 3 flags durante el Paso 1.5 del checklist de [`README.md`](README.md). Cero false positives en proyectos donde el dominio no aplica · cero defaults silenciosos (flag en `unknown` dispara firma user explícita).

---

*Documento canónico del flujo de 6 pasos del pack workflow-base · convención firmada 2026-05-22.*
