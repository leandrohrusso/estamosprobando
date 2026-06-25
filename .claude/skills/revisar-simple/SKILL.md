---
name: revisar-simple
type: skill
description: "Revisión rápida del diff por el agente principal · variante reducida de /revisar para diffs acotados (≤5 archivos · 1 capa · sin dominios domain-tight relevantes en el área tocada). Cero spawn de sub-agentes · cero consolidator · cero log persistente · cero edit del codebase. El agente principal lee `git diff` directo + aplica checklist compacto de 5 ítems universales (correctness · security · tests · simplicity-first · surgical-changes) + reporta findings clasificados por severidad al chat. Si mid-skill se detectan señales que justifican multi-agent (cluster de issues · áreas complejas · dominios domain-tight tocados), escala a /revisar completo. Activar cuando el usuario dice: revisalo simple, revisá simple, revisión simple, revisión rápida, revision rapida, revisalo rápido, revisalo rapido, revisión chica, revision chica, revisión liviana, revision liviana, revisá rápido, revisa rapido, audit rápido, audit simple, checkeo rápido, checkeo simple, mini-revisión, mini revision, revisión acotada, revision acotada, revisá el diff chico, revisa el diff chico."
allowed-tools: Read, Grep, Glob, Bash
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá MCP names + patrones + tooling según el banner común del pack. El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera.

# Skill: `/revisar-simple` — paso 4 (variante simple) · Revisión rápida del flujo de 6 pasos

> **Skill custom autocontenido · variante reducida de [`/revisar`](../revisar/SKILL.md).** Mismo rol estructural (paso 4 del flujo de 6 pasos · review pre-merge del diff de un PRP) pero con proceso simplificado para diffs acotados. Sin spawn de los 9 sub-agentes paralelos · sin consolidator general-purpose · sin log persistente en `docs/logs/revisar-log.md` · sin Paso 0.6 de lectura de config domain-tight con branching `yes/no/unknown` (cero relevancia cuando el scope ya es acotado por contrato del skill · gate de escalación atrapa el caso "diff toca dominio domain-tight" antes de continuar).
>
> **Paridad arquitectónica con [`/planificar-simple`](../planificar-simple/SKILL.md):** mismo shape canónico (4 pasos · gate de escalación firme · `Task` excluido de `allowed-tools` por contrato · cero overhead operativo). Cuando el flujo abre paso 4 con un diff acotado venido de `/planificar-simple` cerrado en paso 2 + `/implementar` paso 3, paridad simétrica simple→simple aplica natural.
>
> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida).

## Overview

> **Propósito:** revisar el diff del PRP recién cerrado por el agente principal directamente en 4 pasos (vs 6 del skill completo + spawn de 9 sub-agentes paralelos) · cero multi-agent · cero overhead operativo cuando el scope real es acotado. Si durante el proceso aparecen señales de cluster de bugs · dominios domain-tight tocados · UI nueva no trivial · u otras señales codificadas en el gate, el skill **escala** a [`/revisar`](../revisar/SKILL.md) completo con firma explícita del user · cero degradación silenciosa de la calidad del review.

**Cuándo invocar:**

- **Triggers explícitos del user** — *"revisalo simple"* · *"revisión rápida"* · *"revisión chica"* · *"audit simple"* · *"mini-revisión"*.
- **Auto-orient del agente principal al cerrar `/implementar`** — paso 3 cerrado · `git diff main --stat` muestra scope acotado (≤5 archivos · 1 capa · cero dominio domain-tight tocado según `.claude/config/agents-applicability.yml`) → proponer `/revisar-simple` con rec early · esperar firma A/B del user.
- **Paridad simétrica simple→simple** — el PRP vino de [`/planificar-simple`](../planificar-simple/SKILL.md) y cerró paso 3 sin haber disparado el gate de escalación mid-`/implementar`.

**Qué NO hace:**

- ❌ NO modifica el código (solo Read · reporta findings al user · cero `Edit`/`Write` en `allowed-tools`).
- ❌ NO ejecuta tests reales (preflight bash mínimo · cero spawn de runners).
- ❌ NO escribe log persistente en `docs/logs/revisar-log.md` (paridad con `/planificar-simple` cero overhead).
- ❌ NO spawnea sub-agentes (cero `Task` calls · `allowed-tools` lo excluye intencionalmente).
- ❌ NO aplica checklist completo del consolidator 10 ítems · solo 5 universales (los 5 que cubren correctness/security/tests/simplicity/surgical-changes · los 5 omitidos son los que disparan el gate de escalación: a11y · i18n · multi-tenant · atomicity · migration-safety).

## When

| Caso | Aplica `/revisar-simple` |
|---|---|
| El user dice triggers explícitos *"revisalo simple"* · *"revisión rápida"* · *"audit simple"* · *"mini-revisión"* · etc | ✅ SÍ |
| Auto-orient del agente principal post-`/implementar`: `git diff main --stat` muestra ≤5 archivos · 1 capa · cero dominio domain-tight tocado · el user firmó la propuesta | ✅ SÍ |
| PRP que vino de [`/planificar-simple`](../planificar-simple/SKILL.md) cerrado en paso 3 sin gate de escalación disparado durante implementación | ✅ SÍ (paridad simétrica simple→simple) |
| Refactor mecánico con scope conocido (rename · adopción de patrón existente · extracción de helper para 2 callers) | ✅ SÍ |
| Bug fix con root cause claro · scope ≤5 archivos · regression-first FIRME aplicado | ✅ SÍ |
| Diff **>5 archivos** | ❌ NO → escalar a [`/revisar`](../revisar/SKILL.md) completo |
| Diff **toca ≥2 capas** (BD + API + UI · O cualquier combinación multi-capa) | ❌ NO → escalar a [`/revisar`](../revisar/SKILL.md) completo |
| Diff **toca área de dominio domain-tight habilitado** en `.claude/config/agents-applicability.yml` (multi-tenant · atomicity · migration-safety con `enabled: yes` Y el diff toca el área correspondiente) | ❌ NO → escalar a [`/revisar`](../revisar/SKILL.md) completo (regla #35 [`agents-conditional-by-domain.md`](../../rules/agents-conditional-by-domain.md) · los sub-agentes domain-tight de `/revisar` valen acá) |
| Diff incluye **UI nueva no trivial** (componentes React/Vue/etc nuevos · cambios visuales significativos · matriz [`claude-design-matrix.md`](../../rules/claude-design-matrix.md) dispararía SÍ) | ❌ NO → escalar a [`/revisar`](../revisar/SKILL.md) completo (a11y agent vale) |
| Diff incluye **cambios en archivos críticos** (RLS policies · auth boundaries · pagos · core helpers compartidos por N callers) | ❌ NO → escalar a [`/revisar`](../revisar/SKILL.md) completo (security + multi-tenant + atomicity agents valen) |

## Process

> **Skill autocontenido · 4 pasos vs 6 del skill completo + cero spawn de sub-agentes.** Las reglas firmes que enmarcan el review son las mismas que [`/revisar`](../revisar/SKILL.md) (referencias por leyenda · doctrina vive en los satélites): [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) · [`regression-first-on-fix`](../../rules/regression-first-on-fix.md) · [`simplicity-first`](../../rules/simplicity-first.md) · [`surgical-changes`](../../rules/surgical-changes.md) · [`quality-standard-senior`](../../rules/quality-standard-senior.md) · [`agents-conditional-by-domain`](../../rules/agents-conditional-by-domain.md) (regla #35 · gate de escalación lo invoca como SoT para señal "dominio domain-tight habilitado tocado").

### Paso 1 · Pre-flight + carga de diff (~30s)

- `git status --short` para confirmar working tree limpio (o que las modificaciones pertenecen al PRP cerrado · cero archivos ajenos).
- `git diff main --stat` para inventario mecánico (cuántos archivos · cuántas líneas).
- `git diff main --name-only` para lista exacta de archivos del diff.
- `Read` de `.claude/config/agents-applicability.yml` (regla #35) para identificar dominios domain-tight habilitados en el proyecto · necesario para evaluar señal (c) del gate del Paso 2.
- Identificar **capas tocadas** mecánicamente: paths bajo `db/` o `supabase/migrations/` → BD · paths bajo `src/app/api/` o `app/api/` → API · paths bajo `src/components/` o `app/(routes)/` o `pages/` → UI · paths bajo `tests/` → tests · paths bajo `docs/` o `.claude/` o root `*.md` → docs.

### Paso 2 · Gate de escalación firme (6 señales · cualquiera dispara aborto)

> **Gate contractual del skill simple.** Si durante el Paso 1 se detecta ≥1 de las siguientes señales, el skill **DEBE abortar** y proponer al user pasar a `/revisar` completo con firma explícita. Cero "ya arranqué simple, sigo simple". El gate protege la calidad del review de la racionalización *"el diff parece chico, lo paso solo"*.

**Las 6 señales (cualquiera dispara · cero excepción):**

1. **>5 archivos en el diff** (`git diff main --stat` retorna >5 filas).
2. **≥2 capas tocadas** (BD + API · BD + UI · API + UI · cualquier combinación multi-capa según mapeo del Paso 1).
3. **≥1 dominio domain-tight habilitado en config Y el diff toca el área correspondiente:**
   - `multi-tenant.enabled: yes` Y diff toca tablas con tenant_id / organization_id / RLS policies con auth filter.
   - `atomicity.enabled: yes` Y diff toca operaciones de stock · transacciones · pagos · RPCs concurrentes.
   - `migration-safety.enabled: yes` Y diff toca `db/migrations/` o `supabase/migrations/`.
4. **UI nueva no trivial** (componentes React/Vue/etc nuevos · cambios visuales que la matriz [`claude-design-matrix.md`](../../rules/claude-design-matrix.md) clasificaría SÍ o CHICO · cero "form simple de 2 campos").
5. **Cluster ≥3 issues detectados mid-review** (durante el Paso 3 abajo · señal de complejidad oculta · el agente principal aborta antes de seguir solo).
6. **Cambios en archivos críticos del proyecto:** RLS policies · auth boundaries · pagos · core helpers compartidos por N callers · cualquier archivo que un cambio quirúrgico mal cerrado puede romper N módulos del producto.

**Protocolo del gate (binario · cero ambigüedad):**

1. **Aborto del skill** sin emitir reporte de findings.
2. **Presentar al user con formato canónico** ([`metodologia-iteracion`](../../rules/metodologia-iteracion.md)):

   > Detecté señal(es) de complejidad: [lista de señales disparadas · cuál(es) aplicó · evidencia concreta del Paso 1].
   >
   > **Mi rec: escalar a [`/revisar`](../revisar/SKILL.md) completo** porque [razón 1-frase basada en las señales].
   >
   > ¿OK firmás escalación? (A: escalar a `/revisar` completo · B: continuar con `/revisar-simple` con override explícito tuyo asumiendo el riesgo de review acotado para diff que no lo es).
3. **Si A** → invocar `/revisar` completo con el contexto recolectado en Paso 1 como input (cero re-investigación del diff) · el flujo completo arranca en su Paso 0 (validación de pre-condiciones).
4. **Si B** → continuar con `/revisar-simple` Paso 3 · documentar el override del user en el reporte ejecutivo del Paso 4 con firma `🔵 user · YYYY-MM-DD · "<justificación>"` (paridad firma de bifurcaciones del skill completo).

### Paso 3 · Revisión inline del diff (checklist compacto de 5 ítems universales)

> **Subset compactado del checklist 10 ítems del consolidator de `/revisar`.** Los 5 ítems acá son los **universales** que aplican a cualquier diff (cero gating por dominio del proyecto). Los 5 omitidos (a11y · i18n · multi-tenant · atomicity · migration-safety) son los que dispararían el gate de escalación del Paso 2 si aplicaran al diff → si llegaste al Paso 3 es porque cero de esos 5 aplica.

Por cada archivo del diff (orden libre · agente principal lee `git diff <archivo>` y evalúa los 5 ítems):

1. **Correctness** — ¿el código hace lo que el PRP especificó? ¿criterios de éxito binarios verificables se cumplen? Alineado con [`goal-driven-execution`](../../rules/goal-driven-execution.md). Anti-patterns típicos: lógica equivocada · branches sin cubrir · condiciones con bug latente.
2. **Security básica** — ¿hay input sin validar? ¿strings sin sanitizar? ¿secrets hardcoded? ¿endpoints públicos sin rate limiting? Cero análisis de auth/RLS profundo (eso lo cubre el security agent del `/revisar` completo cuando el diff toca auth/RLS · cae en señal 6 del gate).
3. **Tests del DoD** — ¿el diff incluye tests codificados que verifican los criterios de éxito del PRP? ([`tests-as-dod-per-phase`](../../rules/tests-as-dod-per-phase.md)). Si es bug fix: ¿hay spec de regresión que reproduce el bug pre-fix? ([`regression-first-on-fix`](../../rules/regression-first-on-fix.md)).
4. **Simplicity-first** — ¿hay abstracciones nuevas sin caller real? ¿código basura (TODOs vacíos · console.log · comentarios obsoletos)? ¿complejidad innecesaria que se podía resolver con mitad de LoC? ([`simplicity-first`](../../rules/simplicity-first.md)).
5. **Surgical-changes** — ¿cada línea del diff se trazea al request del PRP? ¿hay drive-by refactoring (cleanup de código adyacente · rename de variables ajenas · modernización oportunista)? ¿el estilo del diff matchea el resto del archivo? ([`surgical-changes`](../../rules/surgical-changes.md)).

**Clasificación de findings por severidad** (paridad regla [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) · escala canónica del pack):

- 🔴 **critical** — bug funcional · security · datos · multi-tenancy · stock fundamental. Bloquea paso 5 (`/validar`) y paso 6 (`/entregar`).
- 🟡 **normal** — comportamiento inesperado · cobertura insuficiente · convención violada con impacto observable.
- 🟢 **nit** — cosmético con impacto real (typo en error message visible · espacio extra que rompe paridad con módulos hermanos) · NO triviales sin impacto.

**Gate de escalación mid-review (señal 5 del Paso 2):** si durante el Paso 3 el agente acumula ≥3 findings de severidad `critical` o `normal` → el scope es más complejo de lo asumido al inicio · disparar el gate de escalación al Paso 2 (aborto + propuesta de escalar a `/revisar` completo · cero "lo cierro yo solo igual").

### Paso 4 · Reporte ejecutivo al user (chat · cero log persistente)

Emitir reporte al user con shape canónico (paridad simplificada con el reporte ejecutivo de `/revisar` Paso 5 · cero archivo en `docs/logs/`):

```markdown
## /revisar-simple · reporte (paridad con /revisar completo · cero log persistente)

**Diff revisado:** N archivos · M líneas (`git diff main --stat`).
**Capas tocadas:** [lista mecánica del Paso 1 mapeo].
**Dominios domain-tight habilitados Y NO tocados:** [lista del config Paso 1 · justificación de por qué simple aplica].
**Gate de escalación evaluado:** las 6 señales chequeadas · cero disparada (O firma override `🔵 user · YYYY-MM-DD` si el user firmó B en Paso 2).

### Findings clasificados

🔴 **critical** ({N}):
- [Finding 1] · `<archivo>:<línea>` · descripción 1-2 frases · regla firme aplicable.
- [Finding 2] · ...

🟡 **normal** ({M}):
- [Finding 1] · `<archivo>:<línea>` · descripción 1-2 frases.
- ...

🟢 **nit** ({K}):
- [Finding 1] · `<archivo>:<línea>` · descripción 1-2 frases.
- ...

**Cero findings** en alguna severidad → reportar literal *"cero critical · cero normal · cero nit"*.

### Próximo paso

- **Si cero findings totales** → recomendar arrancar paso 5 (`/validar`) directo · review limpio.
- **Si ≥1 critical o normal** → fixear según regla [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) (todos los niveles antes del merge · regression-first FIRME para cada fix) ANTES de arrancar paso 5. Re-correr `/revisar-simple` post-fix para verificar cero regresión.
- **Si solo nit** → fixear según mismo principio (todos los niveles · cero diferimiento por severidad) · pero costo marginal es chico · puede agruparse con fixes del bucle de validación si emerge algo en paso 5.
```

**Cero escritura a `docs/logs/`** · el reporte es chat-only por contrato del skill simple. Si el user quiere trazabilidad cross-sesión del review → usa `/revisar` completo (paridad firmada Bif 2 = B del diseño · `allowed-tools` excluye `Write`/`Edit` para enforcement mecánico).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Me llamaron al simple pero veo señales de complejidad mid-proceso · sigo con simple porque ya arranqué" | NO. El Paso 2 es **gate contractual** del skill · cero excepción. Si aparecen señales (≥1 de las 6) → abortar + escalar a `/revisar` completo con firma user explícita. El "ya arranqué" es exactamente la racionalización que el gate atrapa · seguís simple solo si el user firma override B explícito asumiendo el riesgo. La señal 5 (cluster ≥3 issues mid-review) cubre el caso donde la complejidad se reveló durante el Paso 3 · cero auto-engaño "lo cierro yo solo igual". |
| "Skipeo el checklist de 5 ítems porque el diff es obvio · reporto directo" | NO. Los 5 son **contractuales** (subset compactado del checklist 10 ítems del consolidator · ninguno más se puede omitir sin romper la calidad mínima del review). "Obvio" es subjetivo · el costo de los 5 ítems es minutos · el costo de un review con ítems omitidos es bug crítico en producción. Si el diff es tan obvio que no necesita review, el paso 4 del flujo es N/A · documentar la razón al user y saltar al paso 5 con firma explícita (cero invocación del skill simple ni del completo). |
| "Genero el reporte sin clasificar findings por severidad · es lista plana" | NO. La clasificación 🔴/🟡/🟢 es **contractual** (paridad regla [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) · escala canónica del pack). Sin clasificación, el user no puede aplicar el orden firme de fix (critical → normal → nit) ni decidir si arrancar paso 5 directo o fixear primero. Reporte sin severidad = reporte sin valor operativo. |
| "Spawneo Task para 1 agente puntual del `/revisar` (ej: security) sin escalar el skill entero" | NO. El frontmatter `allowed-tools` excluye `Task` intencionalmente · si genuinamente necesitás 1 agente puntual, eso ya es señal de que el diff merece review completo · escalar a `/revisar`. La justificación "es solo 1 agente puntual" es exactamente el camino de pendiente resbaladizo que el contrato del skill simple atrapa. |
| "Escribo el reporte como archivo en `docs/logs/revisar-simple-log.md` para trazabilidad" | NO. `allowed-tools` excluye `Write`/`Edit` por enforcement mecánico de Bif 2 = B firmada. Trazabilidad cross-sesión es valor del `/revisar` completo (log persistente RM-NNN) · simple es chat-only por contrato · cero overhead. Si necesitás trazabilidad, usás el completo. |
| "El user me dijo 'revisalo simple' explícito · skip el gate de escalación aunque vea señales" | NO. El override del user al inicio (trigger explícito) NO es licencia para skip del gate · el gate es la red defensiva contra invocación equivocada. Si las señales aparecen genuinamente, el aviso al user en Paso 2 vale igual · cuesta 1 round-trip · evita review con cobertura inadecuada. El user puede firmar B (override) sabiendo el riesgo · pero NO se le oculta la detección. |

## Red flags

- 🚩 Detectaste ≥1 señal del gate de escalación (>5 archivos · ≥2 capas · domain-tight habilitado tocado · UI nueva no trivial · cluster ≥3 issues · archivos críticos) y NO ejecutaste el aborto + propuesta al user.
- 🚩 Estás emitiendo el reporte ejecutivo (Paso 4) sin haber aplicado el checklist de 5 ítems en el Paso 3 (uno o más ítems omitido).
- 🚩 El reporte no clasifica findings por severidad 🔴/🟡/🟢 (escala canónica `critical`/`normal`/`nit`).
- 🚩 Spawneaste sub-agente vía `Task` (el frontmatter `allowed-tools` excluye `Task` intencionalmente · si lo necesitás genuinamente, escalá a `/revisar` completo).
- 🚩 Escribiste log persistente en `docs/logs/` (el frontmatter `allowed-tools` excluye `Write`/`Edit` · paridad Bif 2 = B del diseño · trazabilidad es valor del completo).
- 🚩 El user firmó override B del gate de escalación pero NO documentaste el override en el reporte con firma `🔵 user · YYYY-MM-DD · "<justificación>"`.
- 🚩 Acumulaste ≥3 findings `critical` o `normal` mid-Paso 3 y NO disparaste señal 5 del gate (continuaste solo en lugar de escalar).
- 🚩 Saltaste al paso 5 (`/validar`) sin haber reportado findings al user O sin haber fixeado los `critical`/`normal` reportados (regla [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) · todos los niveles antes del merge).

## Verification

- [ ] Paso 1 hecho: `git status --short` + `git diff main --stat` + `git diff main --name-only` + Read de `.claude/config/agents-applicability.yml` ejecutados · capas tocadas mapeadas mecánicamente.
- [ ] **Paso 2 evaluado** (cero salto silencioso): ninguna de las 6 señales disparada → continuar al Paso 3. O si disparada → aborto + propuesta de escalación al user con firma A (escalar) o B (override documentado).
- [ ] Paso 3 hecho: los 5 ítems universales del checklist aplicados a cada archivo del diff (correctness · security básica · tests del DoD · simplicity-first · surgical-changes) · señal 5 del gate evaluada (cluster ≥3 issues `critical`/`normal` → aborto inmediato).
- [ ] Paso 4 hecho: reporte ejecutivo emitido al user con shape canónico (diff resumido + capas + gate evaluado + findings clasificados 🔴/🟡/🟢 + próximo paso recomendado) · chat-only · cero archivo escrito en `docs/logs/`.
- [ ] Si el user firmó override B en Paso 2: reporte incluye sub-sección *"Override de gate de escalación"* con firma `🔵 user · YYYY-MM-DD · "<justificación>"`.
- [ ] Cero `Task` calls ejecutadas (verificable con auditoría del transcript · `allowed-tools` lo excluye mecánicamente).
- [ ] Cero `Write`/`Edit` ejecutados sobre el codebase ni sobre `docs/logs/` (verificable con `git status --short` post-skill · debe estar idéntico al pre-skill).

**Cross-reference firme:**

- Hermana operativa: [`/revisar`](../revisar/SKILL.md) (variante completa · escalación cuando aparece complejidad mid-skill · mismo rol estructural paso 4 del flujo de 6 pasos · paridad shape del reporte ejecutivo · cero divergencia de los 5 ítems universales del checklist).
- Hermana arquitectónica: [`/planificar-simple`](../planificar-simple/SKILL.md) (paridad simétrica del shape simple→simple · gate de escalación firme · `Task` excluido de `allowed-tools` · cero overhead · cuando el PRP vino del simple y cerró paso 3 sin complejidad detectada, `/revisar-simple` aplica natural).
- Hermana doctrinal: las mismas reglas firmes que enmarcan `/revisar` (referencias por leyenda · doctrina vive en los satélites): [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md) · [`regression-first-on-fix`](../../rules/regression-first-on-fix.md) · [`simplicity-first`](../../rules/simplicity-first.md) · [`surgical-changes`](../../rules/surgical-changes.md) · [`quality-standard-senior`](../../rules/quality-standard-senior.md) · [`goal-driven-execution`](../../rules/goal-driven-execution.md) · [`agents-conditional-by-domain`](../../rules/agents-conditional-by-domain.md) (regla #35 · gate de escalación señal (c) la invoca como SoT para "dominio domain-tight habilitado tocado").
- Predecesor: skill [`/implementar`](../implementar/SKILL.md) (paso 3 · cierra con `git diff` que `/revisar-simple` lee en Paso 1).
- Sucesor: skill [`/validar`](../validar/SKILL.md) (paso 5 · arranca cuando el reporte del simple es 100% verde O cuando los findings `critical`/`normal` fueron fixeados según regla [`always-fix-all-bugs`](../../rules/always-fix-all-bugs.md)).
