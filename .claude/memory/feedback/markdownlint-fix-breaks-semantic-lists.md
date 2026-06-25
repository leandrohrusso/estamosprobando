---
name: markdownlint --fix puede romper listas numeradas con semántica cargada · NO es 100% seguro
description: `markdownlint --fix` aplica auto-corrección agresiva que NO distingue listas estructurales (cosméticas) de listas con semántica (orden cargado por contexto · ej: "4to archivo de entrada del proyecto" · "7mo paso del flujo"). La regla MD029 (ordered list prefix) renumera silenciosamente listas semánticas a `1. 2. 3. ...` rompiendo el significado original. NUNCA correr `markdownlint --fix` sobre el repo sin diff post-fix + revisión manual.
type: feedback
---

`markdownlint --fix` es la auto-corrección de la herramienta para 11+ reglas estructurales (MD009 trailing spaces · MD010 hard tabs · MD012 multiple blanks · MD029 ordered list prefix · MD030 list marker space · MD031/MD032 blank lines around lists/code · etc). La mayoría son seguras porque tocan whitespace o formato puramente cosmético. **Pero MD029 NO es segura cuando hay listas numeradas con semántica del contenido.**

**Síntoma observable:**

Tenés un documento markdown con una lista numerada cuyo número tiene significado del contexto. Ejemplos típicos:

- *"Toda sesión arranca con los 3 archivos canónicos. Después, el cuarto archivo de entrada operativa es..."* seguido de `4. [archivo.md] ...`.
- *"Los pasos 1-3 corresponden al setup. El paso 7 cierra el ciclo: ..."* seguido de `7. ...`.
- *"Las reglas firmes #22, #23 y #24 cierran el bloque de docs. La regla #36 es la última:* seguido de `36. ...`.

Corrés `markdownlint --fix file.md` y el `4.` queda renumerado a `1.` (porque MD029 considera que toda lista numerada debe empezar en `1` o ser estrictamente incremental). El significado original se pierde silenciosamente. El diff es invisible para review naive porque "es solo un número que cambió".

**Why:**

- `markdownlint --fix` opera sobre 11+ reglas configurables simultáneamente · NO tiene heurística semántica para distinguir "número estructural" (lista cosmética dentro de un bloque autocontenido) vs "número semántico" (referencia al orden del contenido del proyecto). Hace lo mismo en ambos casos.
- El `--fix` no presenta diff previo · ejecuta + escribe en lugar. Si el usuario no revisa el diff post-ejecución, el cambio semántico pasa desapercibido.
- Las listas semánticas son indistinguibles sintácticamente de las cosméticas a nivel de markdown · solo el contexto humano alrededor las clasifica.

**How to apply:**

- **Regla operativa firme:** NUNCA correr `markdownlint --fix` sobre múltiples archivos sin (a) presentar plan al user con scope estimado + (b) revisar `git diff` archivo por archivo post-fix antes de stagear · (c) firmar el plan ANTES de ejecutar (hermana operativa [`bulk-auto-fix-needs-pre-signature.md`](./bulk-auto-fix-needs-pre-signature.md)).
- **Si hay listas semánticas conocidas:** deshabilitar MD029 globalmente en `.markdownlint.json` con `"MD029": false` antes de correr `--fix`. Esto preserva las listas semánticas a costa de tolerar listas numeradas inconsistentes en el resto del repo (tradeoff aceptable cuando el repo tiene >1 lista semántica conocida).
- **Auto-chequeo de 3 segundos antes de correr `--fix`:** ¿este repo tiene listas numeradas cuyo número tiene significado del contenido del proyecto (orden de archivos · pasos del flujo · numeración de reglas · etc)? Si SÍ → deshabilitar MD029 + auditar manualmente las listas semánticas post-fix. Si NO → correr seguro pero igual revisar diff.
- **Diff obligatorio post-fix:** `git diff --stat` para ver cantidad de archivos tocados + `git diff <archivo>` archivo por archivo (NO `git diff` completo · es demasiado para review humano cuando son 30+ archivos).
- **Cero `--fix` sin firma user previa** cuando se anticipa que va a tocar ≥10 archivos. Aplica regla operativa [`bulk-auto-fix-needs-pre-signature.md`](./bulk-auto-fix-needs-pre-signature.md) en paralelo.

**Recovery (si ya pasó):**

- Revertir con `git restore <archivos>` si los cambios aún no están commiteados. El `--fix` toca archivos en lugar (sin staging) · `git restore` revierte al estado del último commit.
- Si ya commiteaste · `git revert <commit>` o cherry-pick reverso del commit que aplicó el `--fix`.
- Para fix puntual sin revertir todo · editar manualmente las listas semánticas afectadas + deshabilitar MD029 en `.markdownlint.json` + commit nuevo.

**Alternativas descartadas:**

- Correr `--fix` con allowlist de archivos (no se puede · markdownlint no soporta inclusion list granular).
- Correr `--fix` solo sobre archivos sin listas numeradas (requiere pre-análisis costoso · más simple deshabilitar MD029 global).
- Confiar en code review post-fix (los reviewers humanos también pasan por alto cambios de "1 dígito en un número" en diffs grandes).

**Cross-reference:**

- Hermana operativa: [`bulk-auto-fix-needs-pre-signature.md`](./bulk-auto-fix-needs-pre-signature.md) (cualquier auto-fix bulk requiere firma user previa · markdownlint --fix es caso concreto · esa memoria cubre el principio universal).
- Regla firme: [`surgical-changes.md`](../../rules/surgical-changes.md) (cero drive-by · cada cambio del diff debe ser trazable al request · `--fix` puede inyectar cambios fuera del scope).
- Regla firme: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (ante ambigüedad operativa · preguntar al user · operaciones bulk son ambiguas por default).
