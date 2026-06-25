---
name: entregar
type: skill
description: "Entrega final de un PRP del producto al cierre del paso 6 del flujo nuevo de 6 pasos. Orquesta: pre-flight 'npm run ci:local' 6/6 verde como gate → push único a 'origin/dev' → pregunta '/ultrareview <PR#>' al user (decisión 100% del user) → CI remoto único garantizado → merge '--squash' a 'main' → 'bash scripts/sync-dev-after-squash-merge.sh'. Activar después de /validar y REGLA DE ORO cierre-validación. También activar cuando el usuario dice: 'entregar', 'entregá el PRP', 'entrega el PRP', 'armá el PR', 'arma el PR', 'pasamos al paso 6', 'merge a main', 'cerrá el PRP', 'cerra el PRP', 'push y merge', 'run ci:local', 'ci local', 'subí los cambios', 'subi los cambios', 'vamos al paso 6', 'entrega final', 'merge final', 'cierre del PRP', 'llevalo a Production', 'cerrá y mergeá', 'cerra y mergea', 'paso 10'."
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

> **⚙️ Stack adaptation banner.** Este SKILL es **template universal**. Los ejemplos concretos en el cuerpo asumen un stack típico (Next.js · Supabase · Playwright · GitHub Actions · Husky). Si tu proyecto usa otro stack, adaptá:
>
> - **MCP names** del frontmatter `allowed-tools` (`mcp__claude_ai_Supabase__*` · `mcp__playwright__*` · `mcp__next-devtools__*`) a los MCPs disponibles en tu proyecto.
> - **Patrones de código** mencionados en `## Process` (Server Actions · RLS policies · RPCs · revalidatePath · etc) al equivalente de tu framework.
> - **Tooling externo** (`npm run ci:local` · `bash scripts/local-ci.sh` · `gh pr merge`) a los comandos reales de tu proyecto.
>
> El **shape canónico P8** (Overview · When · Process · Anti-rationalization · Red flags · Verification) NO se altera · solo las referencias concretas a stack.

# Skill: `/entregar` — paso 6 · Entrega del flujo de 6 pasos

> **Skill custom autocontenido** (Bif 1 = B · 🔵 user). Brand-new sin antecedente directo · paridad estructural con `/arrancar` (PRP-NNN) · `/planificar` (PRP-NNN) · `/implementar` (PRP-NNN) · `/revisar` (PRP-NNN) · `/validar` (PRP-NNN) ya inaugurados.

> **Inspiración estructural:** [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) (mapeo SD-A3: `git-workflow-and-versioning` + `ci-cd-and-automation` + `shipping-and-launch`) · ver [doctrina estructural compartida](../README.md#doctrina-estructural-compartida) en `skills/README.md` para convención de adaptación · refinamientos específicos: Husky hooks · sync-dev script · skip-ci rule · race `ci:local`↔dev server.

## Overview

> **Propósito:** orquestar el cierre operativo de un PRP del producto. Pre-flight `npm run ci:local` 6/6 verde como gate → push único a `origin/dev` → pregunta SIN/CON `/ultrareview <PR#>` al user (decisión 100% del user) → CI remoto único garantizado → merge `--squash` a `main` → `bash scripts/sync-dev-after-squash-merge.sh`. La sesión termina cuando el PR está mergeado a `main` (o queda explícitamente diferido con razón documentada).
>
> **Posición en el flujo nuevo de 6 pasos:** paso 6 Entrega · post paso 5 Verificación (`/validar`) · último paso del flujo Modo C. Paridad inaugural Capítulo F sostenida en 5 PRPs consecutivos PRP-NNN → PRP-NNN (`/arrancar` · `/planificar` · `/implementar` · `/revisar` · `/validar`).
>
> **Predecesor obligatorio:** paso 5 Verificación cerrado (`/validar` · CSV 100% verde · reporte archivado · cada bug PRINCIPIO 6 con spec en `tests/e2e/regression/` o `tests/sql/` commiteado) + REGLA DE ORO cierre validación cumplida ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) · checklist 6 ítems · roadmap del producto actualizado · PRP COMPLETADO · memorias persistentes · DT timing bidireccional · ultrareview-log timing bidireccional).
>
> **Sucesor:** PRP del producto entregado a Production · `dev` re-alineado con `main` post-squash · sesión cerrada. Próximo PRP del producto arranca desde `/arrancar` con `dev` y `main` sincronizados.
>
> **Anclaje filosófico SD-V4 (Bif 2 = A · 1 línea · 🔵 user):** Anthropic mergeó 22.000 líneas en ~1 día con la misma confianza que cualquier merge — paso 6 es donde se materializa esa confianza · ver [`WORKFLOW.md § 2 · Por qué este flujo`](../../../WORKFLOW.md).

## When

**Aplica a:** Modo C del flujo (PRP del producto en estado `EN PROGRESO` · post paso 5 Verificación cerrado · post REGLA DE ORO cierre validación commiteada localmente · pre merge a `main`).

**Cuándo activar:**

| Condición | Detalle |
|---|---|
| **Paso 5 cerrado** | `/validar` ejecutado · CSV 100% verde (todas las filas `Funciona` o `Diferido` justificado) · reporte archivado en `tests/manual/PRP-NNN_*.csv` · spec PRINCIPIO 6 codificado por cada bug arreglado en `tests/e2e/regression/` o `tests/sql/` · `tests/e2e/regression/COVERAGE.md` actualizado. |
| **REGLA DE ORO cierre validación cumplida** | Checklist 6 ítems ([`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md)) · roadmap del producto con entrada `[x]` + notas + archivos · PRP marcado COMPLETADO con criterios `[x]` + sección "Aprendizajes" con gotchas · memorias persistentes nuevas en `.claude/memory/feedback\|reference\|project/` con `MEMORY.md` actualizado · DT abierta o cerrada en `docs/logs/technical-debt.md` · commit local con resumen + aprendizajes en mensaje. |
| **Working tree limpio** | `git status --short` retorna solo archivos del scope del PRP en curso · cero cambios ajenos (regla [`surgical-changes.md`](../../rules/surgical-changes.md)). |
| **PRP entregó código de aplicación** | El PRP tocó `src/` · `db/migrations/` · Server Actions · RLS policies · UI · API endpoints · tests del producto · y por lo tanto necesita merge a `main` (Production). PRP puramente documental sigue camino "Entrega manual" sin push. |
| **User invoca con triggers** | *"entregar"* · *"entregá el PRP"* · *"armá el PR"* · *"pasamos al paso 6"* · *"merge a main"* · *"cerrá el PRP"* · *"push y merge"* · *"run ci:local"* · *"ci local"* · *"subí los cambios"* · *"vamos al paso 6"* · *"entrega final"* · *"merge final"* · *"cierre del PRP"* · *"llevalo a Production"* · *"cerrá y mergeá"* · *"paso 10"* (SD-cos-N · español argentino LATAM-friendly · voseo · variantes con/sin tilde para captura robusta). |

**NO activar:**

| Condición | Razón |
|---|---|
| **Paso 5 Verificación NO cerrado** | El skill `/validar` debe correr antes con CSV 100% verde · sin esto, mergear a `main` es entregar comportamiento sin validar · rompe rector "cero pérdida de cobertura anti-bug". Resolver `/validar` primero. |
| **REGLA DE ORO cierre validación NO cumplida** | Sin checklist 6 ítems cumplido (roadmap actualizado · PRP COMPLETADO · memorias · DT · ultrareview-log) la doc queda inconsistente con el estado real · el siguiente PRP arranca con contexto desfasado. Resolver REGLA DE ORO primero. |
| **PRP sin código entregado a producción** | PRP puramente documental o de definición · NO requiere merge a `main` · NO usa `/entregar`. La doc se commitea con la sesión cerrada y listo. |
| **Modo A o Modo B** | Tasks triviales (Modo A · ej: rename · 1 línea · adopciones livianas) o skills cerrados con flujo propio (Modo B · ej: `/add-emails` · `/website-3d`) NO usan `/entregar`. Cierran con su propia mecánica. |
| **Working tree con cambios ajenos** | Si `git status --short` muestra archivos que no son del scope del PRP del producto en curso · FRENAR · NO incluir por inercia (regla [`surgical-changes.md`](../../rules/surgical-changes.md)). Resolver primero (commit aparte · stash · descartar) y después invocar `/entregar`. |

## Process

> **Doctrina canónica:** descripción nominal del paso 6 vive en [`WORKFLOW.md § 3 Paso 6 · Entrega · skill /entregar`](../../../WORKFLOW.md) (SoT) · doctrina operativa completa vive en [`WORKFLOW.md § 6 · Política de pushes y CI runs`](../../../WORKFLOW.md) (SoT). Este § Process embebe el flujo completo de entrega (Bif 1 = B autocontenido · 🔵 user) — el skill queda autocontenido y legible sin abrir WORKFLOW.md.

### Tabla de herramientas y contexto

| Herramienta | Para qué se usa |
|---|---|
| `Bash` (`git`, `gh`, `npm`) | Toda la orquestación: `git status` · `git push origin dev` · `gh pr create` · `gh pr merge --squash` · `gh pr ready <PR#>` · `npm run ci:local` · `bash scripts/sync-dev-after-squash-merge.sh`. |
| `Read` / `Grep` / `Glob` | Verificar estado del PRP del producto (REGLA DE ORO cierre validación cumplida · CSV reporte archivado · roadmap del producto actualizado · checkpoint memoria) antes del push. |
| `Edit` / `Write` | Actualizar `docs/logs/ultrareview-log.md` § Decisiones por PRP (al tomarse la decisión SÍ/NO) y eventualmente § Hallazgos consolidados (camino CON `/ultrareview`). |

**Cero MCPs** (SD-cos-N · 🔵 user). El paso 6 es 100% git + gh + npm via Bash. Playwright fue paso 5 (`/validar`) · Supabase fue paso 5 · Next.js DevTools fue paso 3 (`/implementar`) · introspección de errores TS no aplica acá.

---

### Las 4 reglas firmes operativas del paso 6

> Mismas 4 reglas que [`WORKFLOW.md § 6 § "Las 4 reglas firmes para PRPs del producto"`](../../../WORKFLOW.md) (SoT operativo). **Doctrina canónica:** regla firme [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) (regla #27) · cero divergencia · esta sub-sección embebe las 4 reglas para que el skill sea autodescriptivo end-to-end (refinamiento iterativo upstream · cita inline a la regla satélite).

#### REGLA 1 — 1 push a `origin/dev` por PRP (en el paso 6)

**Un único `git push origin dev` por PRP**, ubicado en este paso 6 al cierre operativo del PRP del producto. NO se pushea durante pasos 1-5.

- **Excepción camino CON `/ultrareview`:** si el run pesca CUALQUIER bug (`critical`, `normal` o `nit`), +1 push al PR draft con TODOS los fixes consolidados (no 1 push por bug · ver regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) · *"siempre fixear todo, sin importar severidad"*). El loop está acotado a **1 iteración de fix sobre el batch completo de hallazgos**.
- **Resultado neto:** 1 push (camino SIN) · 2 pushes (camino CON · uno inicial draft + uno consolidado de fixes). En ningún caso N+1 pushes en cascada.

#### REGLA 2 — 1 CI remoto por PRP GARANTIZADO

**Un único run de CI remoto** sobre el evento `pull_request` con PR no-draft.

- NO dispara sobre `push` (trigger `push:` removido del workflow).
- NO dispara sobre PR en draft (workflow filtra `if: github.event.pull_request.draft == false` en cada job · trigger incluye `ready_for_review`).
- **Camino SIN `/ultrareview`:** PR creado no-draft → CI dispara automáticamente al `gh pr create` → corre 1 vez sobre HEAD del PR.
- **Camino CON `/ultrareview`:** PR creado en draft → CI NO arranca → user invoca `/ultrareview` → fixes consolidados pusheados → `gh pr ready <PR#>` dispara CI → corre 1 vez sobre HEAD final post-fix.
- **Garantía estricta:** 1 sola corrida de CI remoto sobre el head SHA final, incluso si hubo fixes intermedios.

#### REGLA 3 — 1 local CI run por PRP (gate confirmatorio)

**`npm run ci:local` 6/6 jobs verde** ANTES del push único como gate confirmatorio. Pasa al primer intento porque las validaciones se distribuyeron durante pasos 3-5:

- Paso 3 (`/implementar`): typecheck+build per-fase + spec-de-la-fase aislado (~30s).
- Paso 5 (`/validar`): typecheck+build+spec asociado después de cada fix del CSV (PRINCIPIO 6).

Si rompe en paso 6 (alternativa pragmática):

1. Fix local del bug.
2. Re-correr SOLO el job que rompió: `npm run ci:local -- --only=<job>`.
3. Iterar hasta verde.
4. Re-correr completo (sin args) una última vez como red final.
5. Documentar gap del flujo como memoria nueva en `.claude/memory/feedback/`.

#### REGLA 4 — Validaciones incrementales distribuidas

Garantía de que la REGLA 3 pasa al primer intento. Los gates están repartidos durante pasos 3-5 (typecheck+build+spec a cada fase / fix · NO concentrados al cierre). Esto deja la responsabilidad del paso 6 acotada a la pasada completa final + verificación remoto.

---

### Orden operativo · race condition `ci:local` ↔ dev server

`ci:local` arranca el dev server de Next como `webServer` de Playwright. Mientras corre, regenera `.next/dev/types/validator.ts` que el typecheck del pre-commit/pre-push hook lee. Si lo lee a medias, rompe con `TS2304 Cannot find name 'RouteHandlerConfig'` (10-30 errores). Bloqueante determinístico, no flaky.

**Para evitarlo, secuencia correcta:**

```bash
# 1. Commit + push ANTES de arrancar ci:local en background
git add <files>
git commit -m "..."          # hook typecheck OK · sin race
git push origin dev          # hook typecheck OK · sin race

# 2. Después del push, recién acá arrancar ci:local
source .env.test             # asume convención `.env.test` del stack típico del pack · adaptá al naming de envs de tu stack
npm run ci:local             # arranca dev server · cualquier commit paralelo va a romper
```

**Si `ci:local` rompe en e2e y tenés que iterar (ALTERNATIVA pragmática):**

1. Aplicá fix.
2. Re-corré sólo los specs afectados con `npx playwright test <archivo>` (el dev server ya está vivo · no hay arranque fresh).
3. Cuando pasen aislados, hacé `commit + push` (dev server sigue vivo · pero los hooks no rompen porque NO se está regenerando schema · es estable).
4. Después corré `ci:local` completo en bg como red final.

Detalle del race + alternativas pragmáticas en [`dev-server-typecheck-race-during-ci-local.md`](../../memory/feedback/dev-server-typecheck-race-during-ci-local.md).

**Resumen del orden** (memorizar): **commit + push ANTES de arrancar `ci:local` en background**. NO al revés.

---

### Paso 1 — PRE-FLIGHT `ci:local` 6/6 verde (gate)

**Objetivo:** confirmar que el código está listo para entregarse. Sin 6/6 verde, NO se pushea.

**Pre-condiciones que el agente verifica primero (lectura · cero side-effect):**

1. PRP del producto en estado `EN PROGRESO` con paso 5 Verificación cerrado (`/validar` · CSV 100% verde · reporte archivado en `tests/manual/PRP-NNN_*.csv` · spec de cada bug PRINCIPIO 6 commiteado).
2. REGLA DE ORO cierre validación cumplida (checklist 6 ítems · ver [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md)). Roadmap del producto actualizado · PRP marcado COMPLETADO con criterios `[x]` + sección "Aprendizajes" con gotchas · memorias persistentes nuevas en `.claude/memory/feedback|reference|project/` con MEMORY.md actualizado · DT abierta o cerrada en `docs/logs/technical-debt.md`.
3. **Working tree limpio · cero cambios ajenos al PRP en curso:** `git status --short` retorna solo archivos del scope del PRP · si hay archivos ajenos → FRENAR · NO incluir por inercia (ver § Red flags).
4. Commits locales del PRP listos (`git log origin/dev..dev --oneline` muestra los commits del PRP).

**Proceso del gate:**

```bash
source .env.test  # asume convención `.env.test` del stack típico del pack · adaptá al naming de envs de tu stack
npm run ci:local
```

Esperar 6/6 jobs verde:

- `lint` · `typecheck` · `build` · `e2e` · `sql`.

Si rompe → ver REGLA 3 alternativa pragmática (fix local + re-correr solo el job + pasada completa final). Si NO se puede arreglar en esta sesión, FRENAR y abrir DT en `docs/logs/technical-debt.md` con disparador explícito · NO mergear con CI rojo.

**Validación binaria de cierre Paso 1:** `ci:local` exit code 0 · 6/6 verde reportado al user.

---

### Paso 2 — Push único a `origin/dev`

**Objetivo:** llevar todos los commits locales del PRP a remoto en un único push.

**Proceso:**

```bash
# Gate mecánico pre-push · refinamiento iterativo upstream
# Materializa § "[skip ci] rule · NO en HEAD del PR" + memoria persistente skip-ci-blocks-pr-head.md
# El subject del HEAD commit NO debe contener [skip ci] (sino pull_request:opened/ready_for_review
# NO triggerean CI · REGLA 2 "1 CI remoto por PRP GARANTIZADO" rota silenciosamente).
if git log -1 --pretty=%s | grep -qE '\[skip ci\]|\[ci skip\]'; then
  echo "ABORT: HEAD commit contiene [skip ci] · CI remoto NO triggerea · REGLA 2 violada"
  echo "Fix: amend del subject sin [skip ci] · o commit nuevo 'trigger' sin [skip ci] que materialice cualquier doc fix pendiente"
  exit 1
fi

git push origin dev
```

**Orden operativo crítico** (ver § "Orden operativo · race `ci:local` ↔ dev server" justo arriba del Paso 1): este push se ejecuta DESPUÉS del gate Paso 1. Si Paso 1 dejó el dev server vivo en background, el race del hook typecheck pre-push puede romper.

**Backup automático paralelo:** el hook `.husky/post-commit` ya replicó cada commit local en `origin/dev-backup` (NO bloqueante · NO triggerea CI). Ver § "Backup automático" abajo para detalle + comando de recovery.

**Validación binaria de cierre Paso 2:** `git log origin/dev..dev --oneline` retorna vacío post-push (todos los commits del PRP están en remoto) · gate `[skip ci]` pre-push retornó exit 0 (subject del HEAD limpio).

---

### Paso 3 — Pregunta SIN/CON `/ultrareview <PR#>` al user (decisión 100% del user)

**Objetivo:** el agente PREGUNTA explícitamente al user qué camino tomar. La decisión es 100% del user (es user-triggered y billed · $5-$20 por run después de los free) — el agente NO puede invocarlo solo. La pregunta es contractual.

**Proceso:**

1. **Crear el PR primero** (en uno de dos modos según se anticipe la respuesta · cualquiera funciona porque el modo se puede ajustar después):

   - **Si el user típicamente dice NO** (PRPs chicos · scope acotado · cobertura local robusta): crear PR no-draft directo. CI remoto arranca al instante.

     ```bash
     gh pr create --base main --head dev --title "<título PRP>" --body "<descripción>"
     ```

   - **Si el user típicamente dice SÍ** o el agente quiere reservar la opción: crear PR draft. CI remoto NO arranca hasta `gh pr ready <PR#>` post-fix.

     ```bash
     gh pr create --draft --base main --head dev --title "<título PRP>" --body "<descripción>"
     ```

2. **Preguntar al user textualmente:**
   > *"PR #N creado · ¿Corre `/ultrareview <PR#>` sobre este PR?"*

3. **Esperar respuesta SÍ/NO. Cero asunciones.** Cero "queda obvio que NO" (ver § Anti-rationalization). Cero "lo decido yo".

4. **Registro obligatorio inmediato** (REGLA DE ORO ítem 4.7 a0): agregar fila en `docs/logs/ultrareview-log.md` § Decisiones por PRP **al tomarse la decisión** (SÍ o NO · ambos casos · cero excepción).

5. **Si el user dice SÍ pero el PR fue creado no-draft**, convertir a draft: `gh pr ready <PR#> --undo` (o crear nuevo si gh CLI no soporta undo).

6. **Si el user dice NO pero el PR fue creado draft**, sacar de draft inmediatamente: `gh pr ready <PR#>`.

**Validación binaria de cierre Paso 3:**

- PR creado en GitHub.
- Decisión del user registrada en `docs/logs/ultrareview-log.md` § Decisiones por PRP (fila nueva con PRP · SÍ/NO · fecha · razón breve).
- Modo del PR (draft / no-draft) coincide con la decisión.

---

### Paso 4 — CI remoto único garantizado

**Objetivo:** que CI remoto corra **1 sola vez** sobre el HEAD final del PR, en cualquiera de los dos caminos.

**Camino SIN `/ultrareview`** (PR no-draft):

1. CI remoto arranca automáticamente al `gh pr create` no-draft.
2. Esperar verde (`gh pr checks <PR#>` · `gh pr view <PR#>` para status).
3. Si rompe: triage como cualquier bug · regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (siempre fixear todo) · 1 push consolidado al PR · CI re-corre.
4. Avanzar a Paso 5 cuando verde.

**Camino CON `/ultrareview`** (PR draft):

1. User invoca `/ultrareview <PR#>` (no es responsabilidad del agente · el agente NO ejecuta el comando · solo informa el `<PR#>` y espera el reporte).
2. Recibir reporte de hallazgos (`critical` · `normal` · `nit`).
3. **Triage con regla firme [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md):** todos los hallazgos se fixean SIEMPRE, sin importar severidad. Orden de prioridad: `critical` → `normal` → `nit`. Cero diferimiento por "es solo nit" / "es scope de otro PRP" / "es solo defense-in-depth" (ver § Anti-rationalization).

   **Procedimiento DT en el acto · OBLIGATORIO (regla #24 [`register-out-of-scope-as-dt.md`](../../rules/register-out-of-scope-as-dt.md) · refinamiento iterativo upstream):** durante el triage de hallazgos del ultrareview, si un hallazgo pertenece **GENUINAMENTE** a otro PRP/feature/stack que NO toca el PRP actual (ej: hallazgo en `<payment-gateway> real` cuando el PRP actual corre en `simulated` · hallazgo en módulo que el diff NO modifica), aplicar el siguiente protocolo SIN excepción · ANTES de avanzar al siguiente hallazgo del triage.

   **Auto-pregunta binaria al clasificar cada hallazgo:** *"¿Este hallazgo está dentro del scope técnico del PRP actual (= archivos que el diff toca + features que el PRP firmó) y puedo fixearlo quirúrgicamente sin dispersar el cierre?"*

   - **SÍ → fixear ahora** en el flujo normal del Paso 4 (sub-paso 4 regression-first FIRME + sub-paso 5 push consolidado).
   - **NO → DT en el acto · ANTES de continuar con el siguiente hallazgo del triage** · agregar fila en `docs/logs/technical-debt.md` con los **8 campos contractuales obligatorios** (regla #24 § Process Paso 2):

      | Campo | Contenido obligatorio |
      |---|---|
      | **ID** | `DT-NNN` autoincremental (siguiente disponible · NO reusar IDs resueltas) |
      | **Síntoma** | 1-2 frases del hallazgo del ultrareview (NO root cause · eso va en notas) |
      | **Archivo / área afectada** | Path concreto del módulo fuera del scope · NO "el sistema" |
      | **PRP destino tentativo** | `PRP-XXX` si ya hay candidato · `ad-hoc futuro` si no · `mini-PRP separado` si es infra |
      | **Severidad estimada** | `critical` · `normal` · `nit` (heredada del reporte del `/ultrareview`) |
      | **Mitigación temporal aplicada hoy** | `ninguna` si no aplica · o descripción 1-frase del workaround en el PRP actual |
      | **Disparador para cerrar** | Condición objetiva (ej: *"al migrar a `<payment-gateway>` real"* · *"al refactorear módulo X"* · *"cuando llegue PRP-NNN"*) |
      | **Detectada en sesión / commit** | Referencia `UR-NNN` del run del `/ultrareview` + commit hash del PRP en curso |

   **Criterio firme para "hallazgo está fuera del scope del PRP actual"** (regla #24 § Process Paso 1 · alguna de las 4 condiciones):

   1. Hallazgo pertenece a feature/stack/módulo distinto del que toca el diff del PRP.
   2. Arreglarlo requiere decisiones de diseño que el PRP actual no firmó.
   3. Arreglarlo expande el diff más allá de lo trazable al request del PRP (paridad regla [`surgical-changes.md`](../../rules/surgical-changes.md)).
   4. Hay disparador objetivo para diferirlo (depende de feature futura · migración externa · PRP que aún no arrancó).

   **Cuidado anti-rationalization:** el sub-paso 3 dice *"Cero diferimiento por 'es scope de otro PRP'"* · esa excusa se atrapa cuando el bug ESTÁ dentro del scope técnico del PRP actual pero el agente quiere postergarlo. El procedimiento DT en el acto es distinto: aplica cuando el bug GENUINAMENTE NO pertenece al scope técnico (las 4 condiciones de regla #24 se cumplen). NO es excusa para diferir bugs del PRP actual · es el canal correcto para hallazgos out-of-scope reales.

   **Adicional · ultrareview-log cross-reference (REGLA DE ORO ítem 4.7c):** agregar field `dt_id: DT-NNN` al hallazgo en `docs/logs/ultrareview-log.md` § Hallazgos consolidados · cross-reference bidireccional ultrareview-log ↔ technical-debt.md.

4. **Cada fix con regression-first FIRME** ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md) · spec en `tests/e2e/regression/` o `tests/sql/` ANTES del fix · verificar que el spec falle con código bugueado y pase con fix aplicado).
5. **1 push consolidado** al PR draft con TODOS los fixes (commit por bug está OK · push final 1 solo).
6. `gh pr ready <PR#>` saca el PR de draft → CI remoto arranca por primera vez sobre HEAD final post-fix.
7. Esperar verde.
8. Avanzar a Paso 5.

**Loop acotado:** **1 iteración de fix sobre el batch completo de hallazgos**. Si un fix introduce un bug nuevo, documentar como gap del flujo en memoria nueva en `.claude/memory/feedback/` y fixear en el mismo commit. Cero loop infinito sobre el mismo PR draft.

**Validación binaria de cierre Paso 4:** `gh pr checks <PR#>` retorna todos los checks verdes (incluido CI remoto único).

---

### Paso 5 — Merge `--squash` a `main` + `sync-dev-after-squash-merge.sh`

**Objetivo:** colapsar los N commits del PRP en 1 commit sobre `main` (Production) y re-alinear `dev`.

**Proceso:**

**Gate operativo firme:** los 3 sub-pasos son una **secuencia atómica del agente** · cero pausa intermedia esperando confirmación del user · cero "lo corre el user después". Si el sub-paso 2 (sync) falla, FRENA el flujo · NO declara el PRP entregado · reporta al user con exit code para resolver manualmente.

1. **Merge `--squash`:**

   ```bash
   gh pr merge <PR#> --squash --subject "<resumen 1-frase del PRP del producto>"
   ```

   El `--subject` es el commit message resultante en `main` (1 commit que colapsa los N del PR). **NUNCA agregar `--delete-branch`** — `dev` es rama persistente del proyecto, no una feature branch efímera. `--delete-branch` la elimina antes de que `sync-dev-after-squash-merge.sh` pueda correr → script aborta con `fatal: ambiguous argument 'origin/dev'`. Detectado en PR anterior (DT-NNN).

2. **Sync `dev` con `main` INMEDIATAMENTE post-squash · ejecución automática del agente** (regla firme · obligatorio · sin excepción · cero delegación al user):

   El agente **DEBE ejecutar el script en el mismo turno que el merge** · esta es responsabilidad operativa del skill `/entregar` · NO se delega al user (caso real PRP-NNN: skill describía el script pero el user manual lo olvidó · próximo PRP debugeó conflictos fantasma).

   ```bash
   bash scripts/sync-dev-after-squash-merge.sh
   ```

   **Manejo de exit code (gate bloqueante):**
   - **Exit 0** → `dev` re-alineado a `origin/main` · continuar al sub-paso 3.
   - **Exit ≠ 0** → ABORT del flujo · NO declarar PRP entregado · reportar al user textualmente: *"`sync-dev-after-squash-merge.sh` falló con exit `<código>` · revisar output · ejecutar manualmente `bash scripts/sync-dev-after-squash-merge.sh` antes de arrancar próximo PRP · sino próximo PR sufrirá `mergeable_state: dirty`."*
   - **Script no existe** (proyecto nuevo sin el script) → FRENA y crear el script según [`squash-merge-dev-divergence.md`](../../memory/feedback/squash-merge-dev-divergence.md) ANTES de hacer el merge.

   **Razón:** `gh pr merge --squash` colapsa N commits del PR en 1 sobre `main`, pero `dev` mantiene la historia original. Aunque el contenido sea idéntico, git ve dos historias divergentes → próximo merge `dev` → `main` genera N conflicts sobre los mismos archivos → GitHub bloquea CI dispatch silencioso (`mergeable_state: dirty` · "Checks awaiting conflict resolution"). Sin esto, el próximo PRP debugea horas el "por qué CI no arranca". Memoria persistente: [`squash-merge-dev-divergence.md`](../../memory/feedback/squash-merge-dev-divergence.md).

3. **Verificar entrega:**

   ```bash
   git checkout main
   git pull origin main
   git log -1 --oneline  # debe mostrar el squash merge con el subject del PRP
   ```

**Validación binaria de cierre Paso 5:**

- PR mergeado en GitHub (`gh pr view <PR#>` muestra `MERGED`).
- `bash scripts/sync-dev-after-squash-merge.sh` **ejecutado automáticamente por el agente** con exit 0 · `dev` re-alineado a `main` · verificable con `git log origin/dev..origin/main` retornando vacío.
- Local `main` actualizado con el squash commit · `git log origin/main..main` retorna vacío.
- PRP del producto entregado a Production.

---

### Tabla bifurcación SIN/CON `/ultrareview` (sub-paso 6.◆)

| Camino | Acción del agente | CI remoto | Resultado |
|---|---|---|---|
| **SIN** `/ultrareview` | `gh pr create dev → main` (PR **no-draft**) → CI remoto dispara automático → esperar verde → `gh pr merge <PR#> --squash` → `bash scripts/sync-dev-after-squash-merge.sh` | 1 run único sobre HEAD del PR | PRP mergeado a `main` · `dev` re-alineado |
| **CON** `/ultrareview` | `gh pr create --draft dev → main` (PR **EN DRAFT** · CI no arranca) → user invoca `/ultrareview <PR#>` → triage findings con regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) · 1 iteración fix · regression-first FIRME por bug → 1 push consolidado al PR draft con TODOS los fixes → `gh pr ready <PR#>` dispara CI remoto sobre HEAD final → esperar verde → `gh pr merge <PR#> --squash` → `bash scripts/sync-dev-after-squash-merge.sh` | 1 run único garantizado (no +1 aunque haya push extra · CI no corrió en draft) | PRP mergeado a `main` · `dev` re-alineado · log con hallazgos en `docs/logs/ultrareview-log.md` |

Decisión 100% del user en ambos casos · agente PREGUNTA · cero asunciones (ver Paso 3).

**Por qué la bifurcación funciona · garantía mecánica de 1 CI único (refinamiento iterativo upstream):**

La garantía "1 CI remoto por PRP" de la regla rectora [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) (REGLA 2) NO depende de disciplina · descansa en 3 mecanismos del workflow `.github/workflows/ci.yml` que ambos caminos respetan:

| Mecanismo del workflow | Camino SIN | Camino CON |
|---|---|---|
| **Trigger `pull_request: [opened, synchronize, ready_for_review]`** (workflow escucha SOLO estos 3 eventos · NO `push:`) | `opened` dispara CI 1 vez al `gh pr create` no-draft. Si CI rompe → 1 push consolidado de fixes (regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)) dispara `synchronize` · 1 re-run | `opened` NO dispara (PR está draft). `synchronize` del push consolidado de fixes NO dispara (sigue draft). `ready_for_review` dispara CI 1 vez al `gh pr ready <PR#>` final |
| **Filtro `if: github.event.pull_request.draft == false`** (presente en cada job) | PR no-draft desde `gh pr create` · filtro pasa · todos los jobs corren | PR draft → filtro NO pasa · jobs skipean en silencio. Tras `gh pr ready` → filtro pasa · jobs corren |
| **`[skip ci]` prohibido en HEAD del PR** (memoria persistente [`skip-ci-blocks-pr-head.md`](../../memory/feedback/skip-ci-blocks-pr-head.md)) | Subject del último commit pre-`gh pr create` NO debe contener `[skip ci]` (sino `opened` no triggerea · CI nunca corre · violación silenciosa de REGLA 2) | Subject del último commit pre-`gh pr ready` NO debe contener `[skip ci]` (sino `ready_for_review` no triggerea · ídem) |

**Failure modes asimétricos del swap PR draft↔no-draft (Paso 3 sub-pasos 5/6):**

| Escenario | Costo | Recuperación |
|---|---|---|
| PR creado **no-draft** + user dice **SÍ** a `/ultrareview` | 🔴 ALTO · CI remoto ya arrancó al `gh pr create` · 1 run "perdido" antes del triage de findings | NO se puede des-disparar · esperar verde del run perdido · seguir con triage · push consolidado dispara `synchronize` · 1 run válido. **Total: 2 runs · violación de REGLA 2** (cero pérdida solo si gh CLI soporta `--undo` antes del primer green) |
| PR creado **draft** + user dice **NO** a `/ultrareview` | 🟢 BAJO · CI NO arrancó al `gh pr create` · user espera verde indefinidamente sin que haya disparador | `gh pr ready <PR#>` (Paso 3 sub-paso 6) dispara CI 1 vez · total 1 run · cero pérdida |

**Default conservador al anticipar el camino** (Paso 3 sub-paso 1): si el agente NO puede anticipar la respuesta del user con alta confianza, crear el PR **draft** · failure mode 🟢 (draft cuando user dice NO) es recuperable sin costo · failure mode 🔴 (no-draft cuando user dice SÍ) pierde 1 CI run garantizado y rompe REGLA 2.

---

### Backup automático (`.husky/post-commit` hook)

Hook activo en el repo: después de cada `git commit`, ejecuta `git push --quiet origin HEAD:dev-backup` en background.

- Branch `origin/dev-backup` NO triggerea CI (workflow filtra a `pull_request:` only).
- NO bloquea el commit si el push falla (red caída · auth issue) · log a `.git/post-commit.log`.
- **Recovery si WSL2 muere o tu máquina se pierde:**

  ```bash
  git fetch origin dev-backup
  git checkout dev-backup
  ```

- Convención cubierta por regla firme [`husky-hooks-smoke-tests.md`](../../rules/husky-hooks-smoke-tests.md) (cualquier cambio al hook obliga actualizar smoke test asociado).

El skill `/entregar` NO modifica el hook · solo respeta su comportamiento. Verificable post-push: `git log origin/dev-backup..origin/dev` retorna vacío (backup tiene los mismos commits que dev).

---

### `[skip ci]` rule · NO en HEAD del PR

GitHub Actions skipea workflows cuando `[skip ci]` está en el subject del HEAD commit del PR — afecta `pull_request` events tal cual `push`, no solo el segundo.

- **Anti-pattern detectado en PR upstream** (commit del HEAD con `[skip ci]` bloqueó el trigger): el `pull_request: opened` NO triggerea CI remoto y la política "1 CI por PRP garantizado" se rompe silenciosamente. Memoria persistente: [`skip-ci-blocks-pr-head.md`](../../memory/feedback/skip-ci-blocks-pr-head.md).
- **Regla operativa:** el último commit del paso 6 (el que se vuelve HEAD del PR) NO debe llevar `[skip ci]` aunque sea docs-only. Si los cambios son docs, hacer un commit "trigger" sin `[skip ci]` que materialice cualquier doc fix pendiente.
- **Verificación pre-push:** `git log -1 --pretty=%s` no debe contener `[skip ci]`.

---

### Reglas firmes mapeadas (leyenda+link · doctrina vive en los satélites · refinamiento iterativo upstream)

| Regla satélite | Cuándo aplica al paso 6 |
|---|---|
| [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) | **Regla rectora del skill entero.** Política firme operativa codificada como satélite: 1 push = 1 PR = 1 CI por PRP del producto · validaciones distribuidas durante el bucle (paso 3 + paso 5) · backup automático post-commit · sync-dev post-squash obligatorio · `[skip ci]` prohibido en HEAD del PR · orden operativo paso 6 evita race con dev server. El skill `/entregar` **materializa** las 4 reglas firmes operativas (REGLA 1 push único · REGLA 2 CI remoto garantizado · REGLA 3 local CI gate · REGLA 4 validaciones incrementales distribuidas) que viven en la cabeza de § Process. |
| [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) | Camino CON `/ultrareview` · triage findings · TODOS los hallazgos se fixean (`critical` + `normal` + `nit`) · sin importar severidad · cero diferimiento. Orden de prioridad: `critical` → `normal` → `nit`. |
| [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) | REGLA DE ORO cierre validación · checklist 6 ítems pre-merge (roadmap actualizado · PRP COMPLETADO · memorias persistentes · CSV verde archivado · DT timing bidireccional · ultrareview log timing bidireccional). Verificación al cierre del PR (mismo checklist post-merge para confirmar paridad doc/estado real). |
| [`goal-driven-execution.md`](../../rules/goal-driven-execution.md) | Criterio binario "CI remoto verde + merge a `main` ejecutado" · loop hasta verificarlo. La sesión NO termina hasta que el PR está mergeado o queda explícitamente diferido con razón documentada. |
| [`husky-hooks-smoke-tests.md`](../../rules/husky-hooks-smoke-tests.md) | Hooks Husky activos: `pre-commit` (typecheck+lint sobre staged) · `pre-push` (typecheck+build) · `post-commit` (backup automático a `origin/dev-backup` · NO bloqueante). El skill `/entregar` solo los respeta · NO los modifica. |
| [`status-tracker-visible.md`](../../rules/status-tracker-visible.md) | `/entregar` se invoca SIEMPRE en Modo C (paso 6 del flujo de 6 pasos · último paso del PRP) · el agente mantiene el status tracker visible al inicio de cada respuesta principal con los 6 ítems canónicos hasta que el PR esté mergeado o quede diferido con razón documentada. Al arrancar `/entregar` el tracker imprime `[ ] 6. /entregar (ci:local 6/6 → push único → DECISIÓN user → camino SIN/CON → CI remoto 1 vez → merge --squash a main) ← in_progress` · al cerrar Paso 5 del skill (merge ejecutado) el tracker termina con `[✓] 6. /entregar · merge ejecutado <hash> · PR cerrado` y la sesión termina · tracker NO se imprime más. |

## Anti-rationalization

> Excusas comunes que el agente puede racionalizar durante el paso 6 + rebuttal firme. Si el agente nota que está por aplicar una de estas excusas, **frena**.

**Bif 3 = B firmada user 🔵 · 8 entradas:** 3 derivadas de la regla firme [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (camino CON `/ultrareview` triage findings · #1-3) + 5 específicas del paso 6 (#4-8 · operativas del flujo).

| Excusa | Rebuttal |
|---|---|
| **1. "Es solo un `nit`, lo dejo para el próximo PR"** | NO. Regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) · *siempre fixear todo, sin importar severidad*. El `nit` de hoy se vuelve la asimetría que mañana es bug `normal` en otro módulo (caso real: 2/3 bugs UR-NNN fueron asimetrías módulo-X↔módulo-Y · ej: product↔ticket en un dominio ticketing). Costo marginal ahora: minutos. Costo de diferirlo: interés compuesto. Cierre antes del `gh pr ready` / merge. |
| **2. "Es scope de otro PRP, no del mío"** | NO. Regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) · si fue detectado durante TU PRP, TU PRP lo cierra. Excepción real: bug en `<payment-gateway> real` cuando estás en `simulated` o bug en `<email-service>` cuando todavía no integrás email → fila en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) con disparador explícito + mitigación temporal aplicada hoy. La excusa "otro PRP" sin DT con disparador y mitigación es diferimiento encubierto. |
| **3. "Es solo defense-in-depth, no es bug real"** | NO. Regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) · si la regla del proyecto dice *"defensa en capas"* (RLS + Server Action + UI · audit log · validación cruzada), todas las capas se fixean — no se elige cuál. Caso real DT-NNN PRP-NNN: marcado ✅ Resuelta en CLAUDE.md mientras 2/4 endpoints seguían rotos. |
| **4. "Saltarse `ci:local` porque ya pasó typecheck per-fase"** | NO. REGLA 3 · `ci:local` es **gate confirmatorio** · 6/6 jobs verde antes del push. Typecheck per-fase NO sustituye el run completo (`build` + `e2e` + `sql` + `lint` corren además del typecheck). Las validaciones distribuidas durante pasos 3-5 son la razón por la que `ci:local` pasa al primer intento — NO una excusa para saltarlo. |
| **5. "Push directo a `main` saltando el PR · ahorro tiempo"** | NO. REGLA 2 · 1 PR por PRP es contractual. CI remoto solo dispara sobre `pull_request` · `push` directo a `main` bypasea CI completamente. Política "1 CI remoto por PRP GARANTIZADO" se rompe silenciosamente. Además `gh pr merge --squash` requiere PR. La doctrina vive en [`WORKFLOW.md § 6`](../../../WORKFLOW.md). |
| **6. "Mergear con CI rojo · es solo un test flaky"** | NO. Merge bloqueado por CI hasta verde. Si un test es flaky (no flaky por bug del PRP · sino por infraestructura), fixearlo o marcarlo `SKIP` con justificación textual + fila en [`docs/logs/technical-debt.md`](../../../docs/logs/technical-debt.md) con disparador. Regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) aplica a tests también: cero diferimiento por *"flaky"*. |
| **7. "No preguntar `/ultrareview` decisión al user porque queda obvio que NO"** | NO. Decisión 100% del user (es user-triggered y billed · $5-$20 por run después de los free) · agente PREGUNTA literal post-PR pre-merge · cero asunciones. La pregunta es contractual. Registro obligatorio inmediato en [`docs/logs/ultrareview-log.md`](../../../docs/logs/ultrareview-log.md) § Decisiones por PRP **al tomarse la decisión** SÍ o NO (REGLA DE ORO ítem 4.7 a0). La fila existe siempre, pase lo que pase. |
| **8. "Saltarse `bash scripts/sync-dev-after-squash-merge.sh` post-squash · 'el próximo PRP lo arregla'"** | NO. Regla firme: re-sincronizar `dev` con `main` después de cada `--squash` merge. Sin esto, el próximo PR sufre `mergeable_state: dirty` (N conflicts heredados) · GitHub bloquea CI dispatch silencioso · próximo PRP debugea horas el *"por qué CI no arranca"*. Costo marginal: ~5 segundos. Costo de saltarlo: ~horas. Caso real upstream con N conflicts heredados de un PRP previo squash. Memoria persistente: [`squash-merge-dev-divergence.md`](../../memory/feedback/squash-merge-dev-divergence.md). |
| **9. "Agrego `--delete-branch` para limpiar automáticamente la rama mergeada"** | NO. `dev` es la rama de desarrollo persistente del proyecto, no una feature branch efímera. `--delete-branch` la elimina antes de que el script de sync corra → `fatal: ambiguous argument 'origin/dev'`. El comando canónico es `gh pr merge <PR#> --squash` sin ningún flag adicional. Caso real detectado en PR anterior (DT-NNN). |
| **10. "User firmó SÍ `/ultrareview` · creé el PR no-draft igual · esperamos CI verde y seguimos"** | NO. Failure mode 🔴 explícito de la tabla bifurcación SIN/CON: camino CON `/ultrareview` + PR creado no-draft + user dijo SÍ = CI remoto arranca sobre el HEAD pre-fix antes de que `/ultrareview` pesque hallazgos · si después hay critical/normal fix, se quema **1 CI run extra** + se rompe la regla [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) REGLA 2 "1 PR = 1 CI sobre el head SHA final". El default conservador es **PR draft cuando NO se anticipa con alta confianza decisión NO** · el filtro `if: github.event.pull_request.draft == false` del workflow es el mecanismo que materializa la garantía · saltarlo "para ahorrar 1 click `gh pr ready`" cuesta ~5 min de CI + dinero billable + ruido en `docs/logs/ultrareview-log.md`. |

## Red flags

> Señales que disparan **FRENO inmediato** durante el paso 6 (no avanzar por inercia · NO racionalizar).

- 🚩 Estás por ejecutar `git push origin dev` sin haber corrido `npm run ci:local` 6/6 verde primero.
- 🚩 `ci:local` reportó 1+ jobs rojos y estás por mergear igual ("lo arreglo después" / "es solo un test flaky").
- 🚩 PR creado pero NO preguntaste al user `/ultrareview <PR#>` decisión SÍ/NO antes de avanzar a CI remoto.
- 🚩 PR mergeado sin entrada en [`docs/logs/ultrareview-log.md`](../../../docs/logs/ultrareview-log.md) § Decisiones por PRP (rompe REGLA DE ORO ítem 4.7 a0 · timing bidireccional inmediato).
- 🚩 Último commit del paso 6 (HEAD del PR) lleva `[skip ci]` (rompe `pull_request: opened` trigger silenciosamente · anti-pattern detectado en PR upstream).
- 🚩 Estás por arrancar `ci:local` en background ANTES de hacer `commit + push` (race condition dev server typecheck `TS2304` · 10-30 errores bloqueantes).
- 🚩 Merge `--squash` ejecutado y NO corriste `bash scripts/sync-dev-after-squash-merge.sh` inmediatamente (próximo PRP heredará N conflicts · `mergeable_state: dirty`).
- 🚩 Usaste `gh pr merge --squash --delete-branch` — `dev` es rama persistente del proyecto, NO una feature branch efímera. `--delete-branch` la elimina antes de que el script de sync corra → aborta con `fatal: ambiguous argument 'origin/dev'`. El flag **nunca va** en este comando (DT-NNN).
- 🚩 Camino CON `/ultrareview` y findings tienen `nit` o `normal` y estás difiriéndolos a "próximo PR" (rompe regla [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)).
- 🚩 PR creado como NO-draft cuando user dijo SÍ a `/ultrareview` (debe ser DRAFT · CI no debe arrancar hasta `gh pr ready` post-fix · sino se quema 1 run extra).
- 🚩 Working tree tiene cambios ajenos al PRP del producto en curso (rompe regla [`surgical-changes.md`](../../rules/surgical-changes.md) · todo diff trazable al request · cero drive-by refactoring).

## Verification

> Checklist que el agente verifica al cierre del paso 6 antes de declarar el PRP entregado a Production.

- [ ] **Pre-condiciones del paso 6:** PRP del producto con paso 5 cerrado (`/validar` · CSV 100% verde · reporte archivado · specs PRINCIPIO 6 commiteados) + REGLA DE ORO cierre validación cumplida ([checklist 6 ítems](../../rules/golden-rule-docs-memory.md) · roadmap actualizado · PRP COMPLETADO con criterios `[x]` + Aprendizajes · memorias persistentes en `feedback|reference|project/` con MEMORY.md · DT timing bidireccional · ultrareview-log timing bidireccional).
- [ ] **`npm run ci:local` 6/6 jobs verde** ANTES del push (gate confirmatorio · `lint` · `typecheck` · `build` · `e2e` · `sql`).
- [ ] **Working tree limpio post-gate:** `git status --short` retorna solo archivos del PRP en curso (cero cambios ajenos · regla [`surgical-changes.md`](../../rules/surgical-changes.md)).
- [ ] **`git push origin dev` único** ejecutado · cero pushes intermedios al PR (excepción única: camino CON `/ultrareview` permite +1 push consolidado al PR draft con TODOS los fixes · NO N+1 pushes en cascada).
- [ ] **Gate `[skip ci]` pre-push aplicado (refinamiento iterativo upstream):** `git log -1 --pretty=%s | grep -qE '\[skip ci\]|\[ci skip\]'` retorna exit ≠0 (subject del HEAD limpio) · si el grep matchea, push abortado + amend o commit "trigger" sin `[skip ci]` antes de re-push (paridad memoria persistente [`skip-ci-blocks-pr-head.md`](../../memory/feedback/skip-ci-blocks-pr-head.md) + REGLA 2 "1 CI remoto por PRP garantizado").
- [ ] **Decisión `/ultrareview` registrada** en [`docs/logs/ultrareview-log.md`](../../../docs/logs/ultrareview-log.md) § Decisiones por PRP (SÍ o NO · ambos casos · al tomarse la decisión · fecha + razón breve).
- [ ] **PR creado** con `gh pr create` · descripción menciona PRP-NNN del producto cerrado · modo del PR (draft / no-draft) coincide con la decisión SIN/CON.
- [ ] **Camino SIN `/ultrareview`:** PR no-draft · CI remoto verde 1 run único · `gh pr merge <PR#> --squash` ejecutado.
- [ ] **Camino CON `/ultrareview`:** PR draft · `/ultrareview <PR#>` invocado por user · TODOS los findings (`critical` + `normal` + `nit`) fixeados ([`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md)) · cada fix con regression-first FIRME ([`regression-first-on-fix.md`](../../rules/regression-first-on-fix.md)) · 1 push consolidado al PR draft · `gh pr ready <PR#>` dispara CI remoto · CI verde · `gh pr merge <PR#> --squash`.
- [ ] **`bash scripts/sync-dev-after-squash-merge.sh` ejecutado** post-merge inmediato (re-alinea `dev` con `main` · evita `mergeable_state: dirty` heredado).
- [ ] **Backup automático activo y verificado:** `git log origin/dev-backup..origin/dev` retorna vacío post-push (hook `post-commit` pusheó cada commit a `origin/dev-backup`).

**Cross-reference firme:**

- SoT contractual: [`WORKFLOW.md § 3 Paso 6`](../../../WORKFLOW.md) + [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) (regla #27 · 1 push = 1 PR = 1 CI por PRP).
- Hermana operativa: [`husky-hooks-smoke-tests.md`](../../rules/husky-hooks-smoke-tests.md) (3 hooks Husky operan durante el paso 6 · `pre-commit` typecheck · `pre-push` typecheck+lint · `post-commit` backup `origin/dev-backup`).
- Hermana operativa: [`golden-rule-docs-memory.md`](../../rules/golden-rule-docs-memory.md) ítem 4.7 (ultrareview log timing bidireccional · entrada UR-NNN al lanzar + hallazgos al completar + estado por bug al fixear).
- Hermana operativa: [`log-chronology-append-only.md`](../../rules/log-chronology-append-only.md) (entrada `prp-close` en `log.md` post-merge a `main`).
- Hermana operativa: [`always-fix-all-bugs.md`](../../rules/always-fix-all-bugs.md) (camino CON `/ultrareview` · todos los findings fixeados antes del merge).
- Hermana operativa: [`migrations-idempotency.md`](../../rules/migrations-idempotency.md) (job `migrations-idempotency` en CI remoto · verde requerido pre-merge).
- Predecesor: skill [`/validar`](../validar/SKILL.md) (paso 5 · CSV 100% verde + REGLA DE ORO cierre validación commiteada).
- Sucesor: `/arrancar` en sesión nueva · `dev` re-alineado con `main` post-squash · próximo PRP del producto.
