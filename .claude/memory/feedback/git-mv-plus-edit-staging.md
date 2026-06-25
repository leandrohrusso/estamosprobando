---
name: git mv + Edit sobre el archivo renombrado pierde el header en el commit final
description: Cuando se hace `git mv <file>` y luego `Edit` sobre el archivo recién renombrado, el rename queda staged pero el contenido editado queda unstaged. lint-staged hace `git stash --keep-index` y se lleva el edit · el commit final NO incluye el header histórico. Workaround documentado.
type: feedback
last_verified: YYYY-MM-DD (lint-staged v15.x · husky v9.x · git v2.39+)
verification_note: gotcha vigente con esas versiones. Si actualizás lint-staged o husky a versiones que cambien el modelo de stash/restore (verificar release notes), re-validar la memoria con un test mínimo (git mv + Edit + commit · verificar diff post-commit) antes de confiar.
---

> ℹ️ **Banner de verificación.** El comportamiento descrito vale con lint-staged v15.x · husky v9.x · git v2.39+ (verificado al codificar la memoria). Si tu proyecto actualizó cualquiera de las 3 a versiones que muten el modelo de stash/restore (ver release notes de cada paquete), correr test mínimo de re-validación: `git mv old new && Edit new && git commit` · verificar que el diff del commit incluye tanto el rename como el contenido editado. Si pasa, agregar fila `last_verified: <fecha> (<versiones>)` arriba. Si NO pasa, la memoria necesita refactor con el nuevo comportamiento.

**Regla:** después de un `git mv <archivo>`, **siempre stagear explícitamente con `git add <archivo>` ANTES del commit** si vas a editar el archivo renombrado en el mismo flow (típicamente para agregar header histórico).

**Why:** `git mv` deja el rename staged, pero un `Edit` posterior sobre el archivo renombrado deja los cambios de contenido **unstaged**. Cuando lint-staged corre en pre-commit, hace `git stash --keep-index` para aislar los cambios unstaged durante `eslint --fix` · ese stash se lleva el edit del header · el commit final tiene el rename pero NO el header. (Hay un bug paralelo de `git stash --keep-index` con sesiones múltiples · ambos son síntomas distintos del mismo round-trip stash/restore frágil.)

**How to apply:**

1. `git mv <viejo> <nuevo>` — rename staged.
2. `Edit <nuevo>` para agregar header histórico (formato típico de archivado: `> **ARCHIVADO** · YYYY-MM-DD · PRP-NNN · razón · commit <hash>`).
3. **`git add <nuevo>`** — stagear explícitamente el edit del header (paso clave · sin esto el header queda unstaged).
4. `git status --short` — verificar que el archivo aparece como `R` (renamed + content modified) staged, no como `R` staged + `M` unstaged.
5. `git commit -m "..."` — hook lint-staged corre limpio · header incluido en el commit final.

**Triggers para detectar el bug retroactivamente:**

- Post-commit, `git show <hash> -- <nuevo>` muestra solo el rename (sin diff de contenido) cuando esperabas ver también el header.
- `git log --follow <nuevo>` arranca con el contenido viejo, sin la línea del header.
- Hace falta un commit fix separado para meter el header (caso real upstream: commit de archivado quedó sin header · commit fix posterior agregó header después).

**Recovery si ya pasó:**

1. `Edit <nuevo>` re-agregando el header (probablemente sigue en working tree pero staged-pero-no-commiteado por el stash).
2. `git add <nuevo>` — stagear explícitamente.
3. `git commit -m "<tipo>(PRP-NNN): fix · header de archivado de <archivo>"` — commit fix separado documenta la mezcla.

**Alternativa pragmática:** aceptar el commit mixto (rename + header en el mismo commit) staged manualmente: `git add <nuevo>` + verificar con `git diff --staged <nuevo>` que ambos cambios (rename + edit) están staged · entonces el commit es atómico y no hace falta fix separado.

**Origen:** durante una Fase 1 de archivado en un PRP upstream · un archivo quedó sin header histórico después del `git mv` + `Edit` · forzó commit fix separado. Aprendizaje original documentado en sección Self-Annealing del PRP de origen · promovido a memoria persistente en revisión post-hoc.

**Cuándo se aplica esta regla:** cualquier flow de archivado que usa el patrón "git mv → agregar header histórico → commit". Aplica a archivado de skills · plans · scripts · memorias previas. Patrón replicable en cualquier PRP del producto que archive código a `_archive/`.
