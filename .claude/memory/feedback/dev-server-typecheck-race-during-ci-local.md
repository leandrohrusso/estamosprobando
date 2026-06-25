---
name: race "next dev ↔ tsc --noEmit" durante ci:local en background
description: Si corrés ci:local en background (Playwright arranca next dev) y commiteás/pusheás en paralelo, el pre-commit/pre-push hook típecheck ve `.next/dev/types/validator.ts` regenerado a medias y rompe con TS2304 RouteHandlerConfig. Bloqueante real, no flaky.
type: feedback
---

> ⚙️ **Stack adaptation banner:** esta memoria es **stack-tight Next.js App Router** (Next.js 16+ con Turbopack · `tsconfig.json` incluyendo `.next/dev/types/**/*.ts` por design del Next 16 typecheck flow). Asume que `next dev` regenera `.next/dev/types/validator.ts` con tipos auto-derivados (`RouteHandlerConfig`) durante runtime. Si tu proyecto NO usa Next.js App Router (ej: Remix · Astro · Vite · framework distinto del stack), la memoria NO aplica · el race que codifica es específico de la mecánica `dev server ↔ pre-commit hook typecheck` que Next.js introduce.

`ci:local` arranca el dev server de Next como webServer de Playwright (config: `webServer: { command: 'npm run dev', reuseExistingServer: true }`). Mientras corre, Next regenera `.next/dev/types/validator.ts` cada vez que detecta cambios en route handlers o se reinicia el HMR. El validator generado contiene tipos auto-derivados como `type __IsExpected<Specific extends RouteHandlerConfig<"/api/...">> = Specific` que dependen del tipo `RouteHandlerConfig` exportado por el runtime de Next.

Si en paralelo intentás `git commit` o `git push`, los hooks `husky` corren `tsc --noEmit` (vía lint-staged en pre-commit, vía `npm run typecheck` en pre-push). El typecheck incluye `.next/dev/types/**/*.ts` por config de tsconfig.json. Si lee el archivo regenerado a medias (Next aún no terminó de escribir todos los imports), tira:

```text
.next/dev/types/validator.ts(442,38): error TS2304: Cannot find name 'RouteHandlerConfig'.
... (uno por cada route handler en el repo, 10-30 errores típicamente)
```

El error es **determinístico mientras el dev server esté regenerando**. NO es flaky transient — desaparece sólo cuando el dev server termina (ci:local job e2e finalizado) o cuando se mata el proceso.

**Why:** `.next/dev/types/` es generated state acoplado al ciclo de vida del dev server. tsconfig.json incluye ese path por design del Next 16 typecheck flow para que el editor (VSCode) tenga types frescos del routing. Pero ese acoplamiento entra en conflicto con cualquier consumer del typecheck que corra concurrentemente (pre-commit/pre-push hooks, IDE typecheck en paralelo, CI job que comparte filesystem). Bloqueó el push del commit `<hash>` (.gitignore) durante UR-NNN PRP-NNN del último paso — typecheck del pre-push corrió mientras ci:local en bg estaba en e2e job (dev server activo), failure forzó replan del orden de operaciones.

**How to apply:**

**Regla operativa firme** durante paso 6 del flujo Modo C (cierre PRP):

1. **Commit y push ANTES de arrancar `ci:local` en background**, no después. La secuencia correcta es:

   ```bash
   git add <files>
   git commit -m "..."   # pre-commit hook typecheck OK · sin race
   git push origin dev   # pre-push hook typecheck OK · sin race
   source .env.test
   npm run ci:local      # arranca dev server · cualquier commit paralelo va a romper
   ```

2. Si `ci:local` está corriendo y necesitás commitear/pushear urgente, hay 2 opciones:
   - **Esperar** al `<task-notification>` del background process (~11min). Es lo más limpio.
   - **Matar el dev server**: `pkill -f "next dev"` (rompe ci:local pero permite commit). Re-arrancar después.

   **Cero opción `--no-verify`** (paridad regla firme [`push-and-ci-policy.md`](../../rules/push-and-ci-policy.md) + CLAUDE.md *"NEVER skip hooks (--no-verify) or bypass signing unless the user has explicitly asked"* · cero excepción por urgencia · si el hook falla → investigar y fixear el underlying issue · cero bypass silencioso).

3. **Cuando ci:local rompe en e2e** y tenés que fixear specs:
   - Aplicá fix.
   - Re-corré **solo los 2-3 specs afectados** (`npx playwright test <archivo1> <archivo2>`) — esto NO arranca dev server fresh si ya hay uno corriendo, así que no race. Si es la primera invocación, sí arranca dev server.
   - Cuando los aislados pasen, hacé `commit + push` ANTES del próximo `ci:local` completo de red de seguridad.
   - Después corré `ci:local` completo en bg como red final.

**Lo que NO funciona:**

- Esperar 30-60s entre `ci:local` start y commit (race-condition seguirá si dev server regenera durante esos 30s).
- Borrar `.next/` antes del commit (dev server lo regenera al toque).
- Excluir `.next/dev/types/` del tsconfig (rompe el typecheck del routing en VSCode editing).

**Origen:** UR-NNN PRP-NNN upstream · sesión vivió este race 2 veces antes de codificar la regla.
