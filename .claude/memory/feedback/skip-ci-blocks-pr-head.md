---
name: '`[skip ci]` en HEAD del PR bloquea workflow_run de pull_request'
description: GitHub Actions skipea TODOS los eventos (push Y pull_request) si el subject del commit HEAD del PR contiene `[skip ci]`. La política "1 CI por PRP" se rompe silenciosamente cuando el último commit del paso 6 es docs-only con `[skip ci]`.
type: feedback
---

`[skip ci]` (y sus variantes `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]`) en el subject del **HEAD commit del PR** instruye a GitHub Actions a NO disparar workflows para ningún evento — incluyendo `pull_request: opened/synchronize/ready_for_review`. NO es solo para `push`.

**Why:**

- Doc oficial de GitHub: "the head commit of a pull request" (<https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs>).
- Detectado durante el cierre del paso 6 de un PRP upstream (commit del HEAD del PR con `[skip ci]` al final del subject → PR abierto OPEN no-draft pero CI nunca disparó · ningún job, ninguna check API, ningún error visible).
- La política firme del proyecto (CLAUDE.md § Política de pushes y CI runs) dice "1 CI remoto por PRP GARANTIZADO sobre `pull_request` no-draft". Si HEAD del PR tiene `[skip ci]`, esa garantía se rompe **sin error**: el PR queda OPEN, los checks rollup muestran solo Vercel, y el merge puede ejecutarse sin cobertura CI.
- La nota anterior en CLAUDE.md ("no daña porque sacamos `push:` del workflow") era **incorrecta**: `[skip ci]` bypassea ambos eventos.

**How to apply:**

- **Regla firme**: el último commit del paso 6 (el que se vuelve HEAD del PR) NUNCA lleva `[skip ci]` en el subject — aunque sea docs-only.
- Si necesitás un commit docs-only al cierre del PRP, materializá cualquier doc fix pendiente en ese commit (no quede solo "trigger note") y omití el marker.
- Commits intermedios del PRP sí pueden llevar `[skip ci]` — solo el HEAD final cuenta para el trigger del PR.
- Si descubrís el bug post-PR-open: añadí un commit nuevo sin `[skip ci]` y pushá. El nuevo HEAD triggerea `pull_request: synchronize` y CI corre. Es la única forma sin force-push (que viola las reglas FIRMES de safety git).
- Detección rápida del bug: después de abrir PR, si `gh pr checks <N>` solo muestra Vercel después de 2-3 min, miré el subject del HEAD: `git log -1 --format=%s` — si tiene `[skip ci]`, ese es el bloqueo.

**Aliases que también skipean** (mismo efecto en HEAD):

- `[skip ci]` / `[ci skip]`
- `[no ci]`
- `[skip actions]` / `[actions skip]`
- `***NO_CI***` (deprecated pero soportado)

**Por qué fue easy de missear**: la docstring del proyecto asumía que `[skip ci]` solo se aplicaba a `push:` event listeners. Pero GitHub interpreta el marker a nivel **del run**, no del trigger event — corta el dispatch antes de evaluar qué workflow se dispara con qué event. Resultado: ningún job, ninguna check API, ningún error visible.

**Historial**: la política "[skip ci] defensivo" se introdujo cuando se removió `push:` del workflow CI (commit del flow-policy upstream). El razonamiento fue "si re-habilitamos push: en el futuro, este marker protege el doble-trigger". Lo correcto es: **defensivo solo para commits intermedios**, nunca para el HEAD del PR.
