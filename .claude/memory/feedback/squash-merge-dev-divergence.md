---
name: Squash merge crea divergencia entre dev y main · CI dispatch se bloquea con mergeable_state=dirty
description: Cada `gh pr merge --squash` deja dev con la historia original (N commits) y main con 1 commit colapsado. Aunque el contenido sea idéntico, git ve dos historias divergentes y el próximo merge produce N conflictos. GitHub bloquea CI dispatch (`Checks awaiting conflict resolution`) hasta que se resuelvan los conflictos.
type: feedback
---

Después de cada `gh pr merge <N> --squash` a `main`, **dev queda divergente con main aunque el contenido sea idéntico**. El squash colapsa los commits del PR en 1, mientras dev preserva los originales. Git compara historias, no contenido — ergo el siguiente intento de mergear `dev → main` genera conflictos sobre TODOS los archivos que tocó el PRP anterior.

**Why:**

- Detectado durante el cierre del paso 6 de un PRP upstream: ~N conflictos al re-mergear porque el PR anterior había sido squashed a `main` pero `dev` seguía con los ~M commits originales del bucle previo (cada archivo tocado aparecía como conflicto fantasma).
- El bloqueo es **silencioso**: GitHub muestra `mergeable_state: "dirty"` y la UI del PR dice "Checks awaiting conflict resolution · 2 successful checks". Los checks-as-en-Vercel sí corren porque son checks externos. **El workflow CI propio NO dispara** hasta que los conflicts se resuelvan, aunque opens/synchronize/reopened events sí lleguen al webhook.
- Sin esta regla, cada PRP requiere un merge laborioso de main → dev al inicio + resolución manual de N conflicts. Y peor, el debugging del "por qué no arranca CI" cuesta horas (caso real: 2 horas de PRP-NNN, descartando hipótesis falsas — `[skip ci]`, billing, GitHub Apps, workflow YAML — antes de detectar el cartel "Checks awaiting conflict resolution").

**How to apply:**

- **Inmediatamente después** de `gh pr merge <N> --squash`, correr desde local dev:

  ```bash
  bash scripts/sync-dev-after-squash-merge.sh
  ```

- El script hace: fetch + fast-forward de local main a origin/main (`fast-forward` = avance lineal de rama sin merge commit) + reset dev a origin/main + push `--force-with-lease` (push forzado con salvaguarda · aborta si remoto cambió desde el último fetch). Pide confirmación interactiva. Aborta si dev tiene commits no mergeados a main (defensa contra pérdida de trabajo).
- Para proyectos **solo-dev** (único contribuyente), el force-push a `dev` es seguro — no hay ramas de feature paralelas que dependan de dev. **Para proyectos con equipo** (>1 contribuyente trabajando concurrente sobre `dev` con feature branches paralelas), el force-push rompe el trabajo de otros · adaptar estrategia: (a) cada feature en branch propia hacia `main` directo (no via `dev`) · O (b) comunicación previa al force-push + coordinación con el equipo para que rebaseen sus branches post-sync · O (c) abandonar el flujo squash a favor de merge commits si la concurrencia es alta.
- Si por error te olvidás y empezaste a trabajar en el siguiente PRP sobre dev divergente: `git fetch origin main && git merge origin/main` y resolver los conflicts tomando dev (`git checkout --ours <archivos>`). dev siempre tiene contenido superset de main (los commits originales + nuevos).

**Trigger del script en el flujo:** paso 6 final, después de `gh pr merge <N> --squash` y antes de iniciar el próximo PRP. Idealmente codificado como sub-paso del cierre del PRP en CLAUDE.md § Política de pushes y CI runs.

**Detección rápida del bug:** si `gh pr checks <N>` solo muestra Vercel después de varios pushes y opens/reopens, mirá `gh pr view <N> --json mergeable,mergeable_state`. Si `mergeable_state == "dirty"` o "blocked", son conflicts bloqueando dispatch — no es problema del workflow, no es billing, no es `[skip ci]`. Es la divergencia squash. Aplicá `git merge origin/main` + resolver con `--ours`.

**Alternativas descartadas:**

- Cambiar a `--rebase` o `--merge` strategy: rompe la convención "1 PR = 1 commit en main".
- Hook automático post-merge: requiere bot + permisos elevados; el script manual con confirmación es más seguro para solo-dev.
- Eliminar dev y recrear: equivalente al script pero más fricción.

---

## Extensión · `dev-backup` también requiere force reset post-squash

**Bug derivado:** `sync-dev-after-squash-merge.sh` original solo reseteaba `dev` local + push a `origin/dev`, **sin tocar `origin/dev-backup`**. Resultado: post-squash, `dev-backup` queda en linaje muerto (commits squash-eados ya no son ancestros de la nueva base de dev). El hook `.husky/post-commit` que intenta `git push origin HEAD:dev-backup` después de cada commit local **falla con non-fast-forward** (`non-fast-forward` = rechazo de push porque el remoto tiene historia divergente que el push borraría) y `--quiet 2>&1` esconde el error · backup roto silenciosamente.

**Detección:** `dev-backup` quedó días estancado en el último commit pre-squash de PRP-NNN mientras `dev` local avanzó commits del refactor del flujo. Si WSL2 hubiera muerto en ese intervalo, se perdían ~3 días de trabajo del refactor. Garantía operativa "NO push durante refactor · backup automático protege" rota silenciosamente sin que la regla notara.

**Fix aplicado:** extender el script con un paso 7 que también haga `git push origin dev:dev-backup --force-with-lease` después del push de `dev`. Mantiene simetría: cada vez que `dev` se resetea a `main`, `dev-backup` se resetea con él. El hook `post-commit` siguiente hace fast-forward normal.

**Lección operativa:** cualquier branch derivada de `dev` (backups · staging · etc.) que se mantiene "en sync" automáticamente vía hook necesita ser **explícitamente reseteada** cada vez que `dev` cambia de base topológicamente (post-squash · post-rebase · post-reset). El hook automático asume fast-forward · cuando deja de aplicar, falla en silencio.

**Verificación post-fix:** después del próximo squash merge, correr el script y confirmar que tanto `git ls-remote origin dev` como `git ls-remote origin dev-backup` apuntan al mismo SHA. Si difieren, el script tiene un bug nuevo.
