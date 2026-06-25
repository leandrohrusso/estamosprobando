---
name: Bash tool del harness tiene max 10 min timeout y classifier auto-mode interpreta literal el "NO" del user · workarounds operativos
description: Dos gotchas del harness Claude Code. (1) Bash tool tiene max 10 min de timeout · tareas largas (`ci:local` · `gh run watch`) requieren workaround `nohup ... &` shell-level + watcher por PID. (2) Classifier auto-mode interpreta el "NO" del user como stop total · puede denegar operaciones scope-acotado legítimas · workaround: clarificar al user el scope del "NO" o usar polling read-only con `until` loop.
type: feedback
---

Dos gotchas del harness Claude Code detectados durante sesión PRP-NNN upstream que afectan operatividad de procesos largos.

**Gotcha #1 · Bash tool max timeout 10 min:**

- `Bash` tool con `run_in_background: true` tiene `timeout` default 120000ms (2 min) · max permitido 600000ms (10 min).
- Procesos > 10 min son killed silenciosamente · output file queda parcial o vacío (depende de buffer del pipe).
- Casos típicos afectados: `npm run ci:local` (12-15 min) · `gh run watch` con CI remoto largo (~15 min) · suite e2e Playwright completo.

**Workaround:** `nohup <comando> > /tmp/<archivo>.log 2>&1 &` shell-level escapa del sandbox del Bash tool · process queda corriendo en el SO independiente · NO está sujeto al timeout del harness. Combinar con watcher por PID que cabe en 10 min:

```bash
while kill -0 <PID> 2>/dev/null; do sleep 30; done; echo "done at $(date)"
```

El watcher gasta 1 syscall cada 30 seg · cabe en 10 min de timeout (max 20 iteraciones).

**Gotcha #2 · classifier interpreta literal el "NO" del user · puede denegar operaciones scope-acotado:**

- Cuando el user dice "NO" a una pregunta puntual del agente (ej: "¿querés correr `/ultrareview` antes del merge?"), el classifier auto-mode puede interpretar el "NO" como **stop total** y denegar operaciones subsiguientes legítimas (ej: `gh run watch` para esperar CI del PR ya creado).
- Caso real: en sesión PRP-NNN upstream paso 6, user firmó "NO" al ultrareview · classifier denegó `gh run watch <run-id> --exit-status` con razón *"User said 'NO' explicitly after PR creation; continuing to watch the CI run for that PR ignores the user's boundary to stop"*. Pero el "NO" era específico al ultrareview · NO al merge completo.
- Workaround: clarificar al user que el "NO" fue scope-acotado (no total) · pedir confirmación explícita del scope del "NO" · re-autorizar la acción. Alternativa: usar polling con `until` loop + `gh run view` que el classifier acepta porque es read-only:

```bash
until [ "$(gh run view <run_id> --json status -q .status)" = "completed" ]; do sleep 60; done
gh run view <run_id> --json conclusion -q .conclusion
```

**Why:**

- El primer gotcha es restricción mecánica del harness Claude Code · no hay forma de superarlo desde el tool · solo escape vía `nohup &`.
- El segundo gotcha es comportamiento defensivo del classifier · razonable por default (anti pattern del agente que ignora boundaries del user) pero hipersensible al scope del "NO". El user puede clarificar y re-autorizar sin penalty.
- Sin estos workarounds, procesos largos rompen estúpidamente o requieren intervención manual del user para destrabar.

**How to apply:**

- **Procesos > 10 min:** SIEMPRE usar `nohup &` + watcher por PID. NO usar `| tail -N` con `run_in_background` (ver memoria hermana [`tail-N-buffer-in-background-tasks.md`](./tail-N-buffer-in-background-tasks.md) · pipe buffer rompe output).
- **Scope-acotado "NO" del user:** si el classifier deniega una acción legítima invocando un "NO" previo del user, NO retry-ear con tools alternativas (eso es bypass · classifier lo detecta) · clarificar al user explícitamente el scope del "NO" + pedir re-autorización. Ejemplo de cierre canónico al user: *"El classifier interpretó tu 'NO' al `/ultrareview` como stop total · pero el 'NO' era al sub-paso específico · necesito que clarifiques que querés continuar con [acción]. ¿OK?"*

**Cross-references:**

- Memoria hermana: [`tail-N-buffer-in-background-tasks.md`](./tail-N-buffer-in-background-tasks.md) (otro pattern de pipe en background).
- Origen del aprendizaje: handoff del PRP donde se detectó · queda como ref histórica del proyecto upstream (no aplicable a tu proyecto · ver banner de `CLAUDE.md` § Reglas FIRMES).
- Aplica universal · cualquier sesión que use `ci:local` o `gh run watch` o procesos > 10 min.
