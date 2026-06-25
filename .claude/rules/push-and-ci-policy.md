---
name: push-and-ci-policy
description: 1 push = 1 PR = 1 CI por PRP del producto · validaciones distribuidas durante el bucle · backup automático post-commit · sync-dev post-squash obligatorio · skip-ci prohibido en HEAD del PR · orden operativo paso 6 evita race con dev server · ahorra minutos GitHub Actions
type: rule
applies-to: cierre del paso 6 de cada PRP del producto del Modo C.
---

> ⚙️ **Stack adaptation banner:** esta regla asume stack con **Next.js dev server + Husky hooks + Playwright** en los ejemplos del § Orden operativo paso 6 + § "Si el local CI rompe" (`next dev` · `.next/dev/types/validator.ts` · `ci:local` script con Playwright `webServer` · pre-commit/pre-push hooks Husky con `tsc --noEmit`). Si tu proyecto usa otro stack (Rails con Capybara · Django con pytest · Astro con Vitest · Vite con Cypress · Go con httptest · etc), adaptá los mecanismos: el principio (1 push = 1 PR = 1 CI por PRP del producto · validaciones distribuidas durante el bucle · cero pushes intermedios · cero CI redundantes · skip-ci prohibido en HEAD del PR) es universal · los comandos concretos (`npm run ci:local` · race condition con dev server regenerando `.next/dev/types/`) son ejemplos del stack · reemplazá por equivalentes (ej: pre-commit hooks Python + pytest pre-push · `rails test` con fixture isolation · `go test ./...` + lint pre-push · etc). El sync-dev post-squash + backup automático post-commit aplican igual sobre cualquier stack que use git + GitHub Actions.

## Overview

> **Cada PRP del producto cierra con 1 push a `origin/dev` + 1 PR + 1 CI remoto + 1 local CI gate.** Cero pushes intermedios · cero CI redundantes. Las validaciones se distribuyen durante el bucle (typecheck + build + spec por fase del paso 3 + post-fix CSV paso 5) para que el local CI del paso 6 pase al primer intento.

**Por qué firme:** GitHub Actions free tier son 2000 min/mes · estábamos quemando 1200 por triggers redundantes (push + PR-open + push-tras-fix · 3-4 corridas por PRP). Activada en sesión upstream · ahorro real ~75% de minutos. Garantía estricta de "1 PR = 1 CI sobre el head SHA final" · incluso en camino CON `/ultrareview` con fixes intermedios al PR draft.

## When

**Aplica a:**

- Cierre del paso 6 de cada PRP del producto (Modo C).
- Tanto camino SIN como CON `/ultrareview` (sub-paso 6.◆).

**NO aplica a:**

- Modo A o Modo B (sin pasos formales · cero PRP).
- Branches de backup automático (`origin/dev-backup`) · workflow filtra `pull_request:` only.

## Process

### Las 4 reglas firmes operativas

1. **1 push a `origin/dev` por PRP** · ubicado en paso 6 (cierre del PRP · justo antes del PR). Excepción para fixes inmediatos: en camino CON `/ultrareview`, si el run pesca CUALQUIER bug (`critical` · `normal` · `nit`), +1 push al PR draft con TODOS los fixes consolidados (regla [`always-fix-all-bugs.md`](./always-fix-all-bugs.md)). El loop está acotado a 1 iteración de fix sobre el batch completo de hallazgos.

2. **1 CI remoto por PRP GARANTIZADO** sobre el evento `pull_request` con PR no-draft. NO dispara sobre `push` (trigger `push:` removido del workflow). NO dispara sobre PR en draft (workflow filtra `if: github.event.pull_request.draft == false` en cada job + trigger incluye `ready_for_review`). En camino CON `/ultrareview`, el PR se abre como draft y CI no arranca hasta `gh pr ready` post-fix · garantía estricta de 1 sola corrida sobre el head SHA final, incluso si hubo fixes intermedios.

3. **1 local CI run por PRP** · gate confirmatorio en paso 6 antes del push (`npm run ci:local`). Pasa al primer intento porque las validaciones se distribuyen durante pasos 3-5. En camino CON `/ultrareview`, además se corren jobs aislados (`--only=<job>`) si hubo critical fix, más una pasada completa final como red de seguridad.

4. **Validaciones incrementales distribuidas** durante el bucle: typecheck + build después de cada fase del paso 3, spec-de-la-fase aislado (~30s), typecheck + build + spec asociado después de cada fix del CSV en paso 5.

### Excepción · bootstrap fundacional (1 push por proyecto en toda su vida)

> **Única excepción documentada a las 4 reglas operativas arriba.** El **bootstrap-commit** del proyecto (commit inicial post-template que materializa `BUSINESS_LOGIC.md` + `CLAUDE.md` + `agents-applicability.yml` + `product-roadmap.md` + scripts + `package.json` con info real del producto · ver regla [`product-docs-as-bootstrap-sot.md`](./product-docs-as-bootstrap-sot.md)) **SÍ se pushea directo a `origin/dev` + `origin/dev:dev-backup`** sin PR · sin CI · sin gates · porque el bootstrap NO es PRP del producto · es **config fundacional del proyecto** (1 vez en toda la vida del proyecto post-template).

**Comandos contractuales del push fundacional:**

```bash
git push origin dev
git push origin dev:dev-backup
```

**Por qué la excepción es legítima:**

1. El workflow CI (`.github/workflows/ci.yml`) está configurado **solo en `pull_request` event** · `git push origin dev` directo NO triggerea CI remoto (cero quema de minutos GitHub Actions · paridad con la regla general).
2. El bootstrap NO tiene PR asociado · es trabajo de config fundacional · cero feature del producto en este commit · cero merge a `main` (eso se hace recién en el paso 6 del PRP inicial cuando cierre).
3. Sin push, el work del bootstrap queda solo local · si la máquina muere antes de TASK-002 (`npm install` que activa Husky), se pierde TODO el llenado de placeholders (BUSINESS_LOGIC.md · agents-applicability.yml · roadmap · etc).
4. El hook `post-commit` (backup automático a `dev-backup`) está **dormido durante el bootstrap** porque `node_modules/.bin/husky` no existe todavía (deps vacías en `package.json` template · `npm install` no se ejecutó · `git config core.hooksPath .husky/` nunca se aplicó). Sin push manual de las 2 ramas, `dev-backup` queda en `Initial commit` y el backup automático del hook no aporta nada hasta TASK-002.

**Cuándo se cumple esta excepción:**

- Estado post-template detectado por `/arrancar` (5 condiciones del disparador binario · ver [`product-docs-as-bootstrap-sot.md`](./product-docs-as-bootstrap-sot.md) § When).
- User firmó OK al resumen 5-7 bullets del sub-paso 1.b.3.
- Sub-paso 1.b.4 ejecutado · 7 sub-pasos del bootstrap mecánico completados.
- Commit del bootstrap firmado por el user (mensaje sugerido tipo `chore(bootstrap): adopt workflow-base pack + PRD vN as SoT`).
- → **Push fundacional ejecutado** (paso 8 del sub-paso 1.b.4 del skill `/arrancar`).

**Después del bootstrap-commit · regla general vuelve a aplicar:** todo commit posterior pertenece a un PRP del producto · sigue la política "1 push = 1 PR = 1 CI por PRP". Esta excepción es **1 sola vez** por proyecto · cero re-aplicación.

### Excepción · commit administrativo post-merge (cierre del paso 6 del PRP)

> **Segunda excepción documentada a las 4 reglas operativas arriba.** El **commit administrativo post-merge** del PRP (header del PRP a `COMPLETADO` + entry `prp-close` en `.claude/memory/log.md` post-merge a `main`) **SÍ se pushea directo a `origin/dev`** sin PR · sin CI · sin gates · porque es **doc-only update del estado del PRP** que ya cerró su CI con verde sobre el PR original.

**Comandos contractuales:**

```bash
git add .claude/PRPs/PRP-NNN-<slug>.md .claude/memory/log.md
git commit -m "chore(prp-NNN): header COMPLETADO + entry prp-close · cierre administrativo paso 6"
git push origin dev
```

**Por qué la excepción es legítima:**

1. El workflow CI (`.github/workflows/ci.yml`) filtra `pull_request:` only · `git push origin dev` directo NO triggerea CI remoto (cero quema de minutos · paridad con la regla general).
2. El cambio es **doc-only** (header del PRP + entry `log.md`) · cero código de aplicación · cero impacto operativo.
3. La regla [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) § Mapping prescribe que el header del PRP pase a `COMPLETADO` **post-merge a `main`** · pero esos cambios NO pueden vivir en el squash de `main` (que ya cerró al tomarse el merge) · necesitan persistir en algún commit posterior.
4. "1 CI por PRP garantizado" se cumple igual · ese 1 CI ya corrió y pasó verde sobre el PR original · este commit administrativo es **trazabilidad documental, NO nueva validación**.

**Cuándo se cumple esta excepción:**

- `gh pr merge <N> --squash` ejecutado · `main` al SHA del squash.
- `bash scripts/sync-dev-after-squash-merge.sh` (o workaround manual cuando el script ABORTA por falso positivo) ejecutado · `dev` y `dev-backup` sincronizados al SHA de `main`.
- Header del PRP todavía en `EN PROGRESO (paso 5 cerrado · 6 pendiente)` · necesita pasar a `COMPLETADO` (paridad regla [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) § Mapping).
- → **Commit administrativo + push directo a `dev`** (paridad shape con bootstrap fundacional · doc-only sin CI).

**Diferencia clave con la excepción del bootstrap fundacional:**

- **Bootstrap fundacional:** pre-PRP-001 · 1 vez por proyecto en toda su vida · materializa identidad del producto.
- **Commit admin post-merge:** post-PRP cualquiera · 1 vez por PRP del producto · materializa cierre administrativo del flujo de 6 pasos · acepta repetirse (1 ocurrencia por PRP cerrado).

### Backup automático

Hook `.husky/post-commit` ejecuta `git push --quiet origin HEAD:dev-backup` después de cada commit local. La branch `origin/dev-backup` NO triggerea CI (workflow filtra a `pull_request:` only). **Recovery si WSL2 muere:** `git fetch origin dev-backup && git checkout dev-backup`.

### Re-sincronizar `dev` con `main` después de cada `--squash` merge (obligatorio)

`gh pr merge <N> --squash` colapsa los N commits del PR en 1 solo commit sobre `main`, pero `dev` mantiene la historia original. Aunque el contenido sea idéntico, git ve dos historias divergentes → el próximo merge `dev → main` genera N conflictos sobre los mismos archivos → GitHub bloquea CI dispatch silencioso (`mergeable_state: dirty` · "Checks awaiting conflict resolution"). **Inmediatamente después de `gh pr merge <N> --squash`** correr desde local dev:

```bash
bash scripts/sync-dev-after-squash-merge.sh
```

El script force-resetea `dev` a `origin/main` con confirmación interactiva y fast-forward de local main a origin/main (cero "main local behind" post-merge · guard skipea el ff si el user está en main). Sin esto, el próximo PRP debugea horas el "por qué CI no arranca". Memoria persistente: [`feedback/squash-merge-dev-divergence.md`](../memory/feedback/squash-merge-dev-divergence.md).

**NUNCA agregar `--delete-branch` al comando de merge.** `dev` es rama persistente del proyecto — no una feature branch efímera. `--delete-branch` la elimina antes de que el script de sync pueda correr → `fatal: ambiguous argument 'origin/dev'`. Detectado en un Pull Request upstream (DT-NNN). El script ya es resiliente (recrea `dev` si no existe), pero la causa raíz es el flag prohibido.

### Si el local CI rompe en paso 6 (alternativa pragmática)

1. Fix local del bug.
2. Re-correr SOLO el job que rompió: `npm run ci:local -- --only=<job>`.
3. Iterar hasta verde.
4. Re-correr completo (sin args) una última vez como red final.
5. Documentar gap del flujo como memoria nueva.

### `[skip ci]` SOLO en commits que NO van a ser HEAD del PR

GitHub Actions skipea workflows cuando `[skip ci]` está en el subject del HEAD commit del PR · afecta `pull_request` events tal cual `push`, no solo el segundo. Si el último commit del PRP termina con `[skip ci]` (típico del cierre del paso 5 docs-only), el `pull_request: opened` NO triggerea CI remoto y la política "1 CI por PRP garantizado" se rompe silenciosamente.

**Regla derivada:** el último commit del paso 6 (el que se vuelve HEAD del PR) NO debe llevar `[skip ci]` aunque sea docs-only · si los cambios son docs, hacé un commit "trigger" sin `[skip ci]` que materialice cualquier doc fix pendiente. Memoria persistente: [`feedback/skip-ci-blocks-pr-head.md`](../memory/feedback/skip-ci-blocks-pr-head.md).

### Orden operativo durante paso 6 (evitar race con dev server)

`ci:local` arranca el dev server de Next como webServer de Playwright. Mientras corre, regenera `.next/dev/types/validator.ts` que el typecheck del pre-commit/pre-push hook lee · si lo lee a medias, rompe con `TS2304 Cannot find name 'RouteHandlerConfig'` (10-30 errores). Bloqueante determinístico, no flaky. Para evitarlo:

1. **Commit + push ANTES de arrancar `ci:local` en background**, no después. Secuencia correcta:

   ```bash
   git add <files>
   git commit -m "..."   # hook typecheck OK · sin race
   git push origin dev   # hook typecheck OK · sin race
   source .proyecto-test.env
   npm run ci:local      # arranca dev server · cualquier commit paralelo va a romper
   ```

2. **Si `ci:local` rompe en e2e y tenés que iterar:**
   - Aplicá fix.
   - Re-corré sólo los specs afectados con `npx playwright test <archivo>` (el dev server ya está vivo, no hay arranque fresh).
   - Cuando pasen aislados, hacé `commit + push` (dev server sigue vivo, pero los hooks no rompen porque NO se está regenerando schema · es estable).
   - Después corré `ci:local` completo en bg como red final.

Detalle del race + alternativas pragmáticas en [`feedback/dev-server-typecheck-race-during-ci-local.md`](../memory/feedback/dev-server-typecheck-race-during-ci-local.md).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Hago un push intermedio rápido para chequear que CI pasa antes de seguir" | NO. Eso quema 1 corrida CI completa (~5-7 min · ~10-15 min de minutos contables). La política firme dice 1 push = 1 CI por PRP. Si necesitás validar antes, corré `npm run ci:local` localmente. |
| "Es solo docs · le pongo `[skip ci]` para ahorrar minutos" | OK pero NUNCA en el commit que va a ser HEAD del PR. Si tu último commit tiene `[skip ci]`, el `pull_request: opened` NO dispara CI y rompés "1 CI garantizado". Hacé un commit "trigger" sin `[skip ci]` después. |
| "Skipeo `sync-dev-after-squash-merge.sh` · git lo va a resolver solo" | NO. Git ve dos historias divergentes después del squash · el próximo merge `dev → main` genera N conflictos fantasma sobre los mismos archivos · GitHub bloquea CI dispatch silencioso. El script tarda 30 segundos · la alternativa es debuggear horas. |
| "Arranco `ci:local` y mientras tanto hago más commits para no perder tiempo" | NO. El dev server de `ci:local` regenera schemas que el typecheck del hook lee a medias · rompe determinísticamente con `TS2304`. Commit + push ANTES de arrancar `ci:local`, no después. |

## Red flags

- 🚩 Hiciste 2+ pushes a `origin/dev` durante un mismo PRP (excepción única: camino CON `/ultrareview` con fixes consolidados al PR draft).
- 🚩 CI remoto corrió 2+ veces sobre el mismo PRP (señal de trigger redundante · revisar workflow filters).
- 🚩 El último commit del PRP (HEAD del PR) lleva `[skip ci]` · el `pull_request: opened` NO dispara CI.
- 🚩 Hiciste `gh pr merge --squash` y NO corriste `bash scripts/sync-dev-after-squash-merge.sh` · próximo PRP va a romper con conflictos fantasma.
- 🚩 Arrancaste `ci:local` ANTES de commit + push · race con typecheck del hook va a tirar `TS2304`.
- 🚩 `npm run ci:local` rompió en paso 6 al primer intento · señal de que las validaciones distribuidas durante el bucle (paso 3 + paso 5) se omitieron.

## Verification

- [ ] `git log origin/main..origin/dev --oneline | wc -l` muestra 1 push consolidado por PRP (no 3-4 pushes incrementales).
- [ ] `gh pr list --state all --limit 5` muestra 1 PR por PRP · no draft al momento del merge.
- [ ] `gh run list --branch dev --limit 5` muestra 1 CI run por PRP (sobre el head SHA final · no múltiples sobre commits intermedios).
- [ ] `npm run ci:local` exit 0 al primer intento del paso 6 (validaciones distribuidas funcionaron).
- [ ] Post-`gh pr merge --squash` ejecutaste `bash scripts/sync-dev-after-squash-merge.sh` y `dev` quedó alineado a `origin/main`.
- [ ] El último commit del PRP NO lleva `[skip ci]` aunque sea docs-only.
- [ ] Backup `origin/dev-backup` actualizado post-cada commit (verificable con `git log origin/dev-backup --oneline -1`).

**Cross-reference firme:**

- Hermana operativa: [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) (excepción +1 push en camino CON `/ultrareview` con fixes consolidados).
- Hermana operativa: [`husky-hooks-smoke-tests.md`](./husky-hooks-smoke-tests.md) (los 3 hooks Husky implementan parte de esta política · `pre-commit` typecheck · `pre-push` typecheck+lint · `post-commit` backup).
- Refuerza: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) ítem 6 (push solo en paso 6 del Modo C · 1 push por PRP).
- Memoria del cambio:.
- Memorias asociadas: [`squash-merge-dev-divergence.md`](../memory/feedback/squash-merge-dev-divergence.md) · [`skip-ci-blocks-pr-head.md`](../memory/feedback/skip-ci-blocks-pr-head.md) · [`dev-server-typecheck-race-during-ci-local.md`](../memory/feedback/dev-server-typecheck-race-during-ci-local.md).

---

*Regla codificada vía extracción del contenido inline de `CLAUDE.md` a satélite con shape P8 · paridad arquitectónica con resto de reglas del flujo.*
