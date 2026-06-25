---
name: husky-hooks-smoke-tests
description: Husky hooks (pre-commit · pre-push · post-commit) tienen smoke tests que verifican que su comportamiento se mantiene · cualquier cambio al hook obliga actualizar el smoke test correspondiente.
type: rule
applies-to: .husky/{pre-commit,pre-push,post-commit,commit-msg} · scripts asociados · CI smoke tests
---

> ⚙️ **Stack adaptation banner:** esta regla asume stack con **Node.js + npm + bash + GitHub Actions + Husky** en los hooks y smokes (`.husky/<hook>` · `tests/scripts/infra-flujo/*.sh` · `.github/workflows/ci.yml`). Si tu proyecto usa otro stack (GitLab CI · pnpm · Bun · Makefile · pre-commit framework de Python · git hooks nativos sin Husky · etc), adaptá los mecanismos: el principio (hooks defienden invariantes mecánicos del flujo · cambio al hook obliga actualizar smoke test correspondiente · cero hook deshabilitado silenciosamente) es universal · los comandos concretos (`.husky/` · `npm install` que activa hooks vía `prepare` script · GH Actions) son ejemplos del stack default · reemplazá por equivalentes (ej: `.git/hooks/` directo · `lefthook.yml` · `pre-commit/.pre-commit-config.yaml` · etc).

## Overview

> **Los 4 hooks Husky activos del proyecto (`pre-commit` · `pre-push` · `post-commit` · `commit-msg`) tienen smoke tests que verifican su comportamiento.** Cualquier cambio al hook obliga actualizar el smoke test correspondiente · si no, el flujo se rompe silenciosamente y nadie se entera hasta que un commit / push falla en CI.

**Por qué firme:** los hooks son infra crítica · garantizan que typecheck + lint corran antes de cada commit · que typecheck + build corran antes de cada push · y que el backup automático a `origin/dev-backup` se dispare después de cada commit. Si un hook se rompe en silencio (deshabilitado · script roto · path cambiado), las validaciones desaparecen y la regla "1 push por PRP con CI verde garantizado" se rompe sin alarma.

## When

**Aplica a:**

- Modificación de `.husky/pre-commit`, `.husky/pre-push`, `.husky/post-commit`, `.husky/commit-msg`.
- Modificación de scripts referenciados desde los hooks (`scripts/local-ci.sh` · `scripts/check-routing-english.sh`).
- Adición de hook nuevo (cero pendiente actual · los 4 activos están cubiertos: pre-commit · pre-push · post-commit · commit-msg).
- Cambio en la cadena de jobs locales que validan en hook (typecheck · lint · build).

**NO aplica a:**

- Cambios al schema del package.json scripts que NO se invocan desde hooks.
- Tests E2E del producto (esos no son smoke tests · son specs de regresión).

## Process

**Inventario actual de hooks + smoke tests:**

| Hook | Función | Smoke test asociado |
|---|---|---|
| `pre-commit` | typecheck + lint sobre archivos staged | `tests/scripts/<smoke-pre-commit>.sh` (a definir cuando se agregue test específico) |
| `pre-push` | typecheck + lint (gate antes de push) | Verificación implícita: si rompe, el push falla |
| `post-commit` | `git push --quiet origin HEAD:dev-backup` (backup automático) | `tests/scripts/<smoke-post-commit>.sh` (a definir) |
| `commit-msg` | valida firma user explícita (`🔵` · `firma user` · `firma 🔵`) en commits que tocan `.claude/config/agents-applicability.yml` (regla #35 defense in depth) | `tests/scripts/infra-flujo/husky-hooks-not-degenerated.sh` (verifica presencia del check de firma en el hook) |

**Pattern de smoke para invariantes mecánicos:** un smoke bash que parsea archivos críticos (ej: `scripts/local-ci.sh` y `.github/workflows/ci.yml` para validar paridad de orden de jobs) y aborta si el invariante se rompe. Se invoca desde el job CI `lint` (local + remoto). Modelo a seguir cuando el proyecto derivado defina jobs concretos en `local-ci.sh` + `ci.yml` y necesite defender paridad mecánicamente · o cuando se agreguen smoke tests de hooks futuros.

**Reglas operativas:**

1. **Cualquier cambio a un hook NO mecánico** (typo en variable · cambio en cadena de comandos · agregar/quitar script invocado) obliga a:
   - Actualizar el smoke test correspondiente para que verifique el shape nuevo.
   - Correr el smoke test localmente y verificar EXIT=0.
   - Si NO hay smoke test del hook tocado todavía, escribirlo en el mismo PRP.
2. **Cualquier hook nuevo** que se agregue debe llegar con smoke test desde el día 1.
3. **`local-ci.sh` y `ci.yml`** son canales hermanos · cualquier cambio de orden de jobs en uno obliga el cambio simétrico en el otro · cuando el proyecto derivado defina jobs concretos, considerar smoke bash de paridad encadenado al job `lint`.
4. **Backup `post-commit`** es asíncrono y silencioso · NO bloquear si falla (ej: red caída) · pero el smoke test debe verificar que el comando es correcto y que la branch destino (`dev-backup`) existe en remote.
5. **Logging de fallos en hooks asíncronos (firme).** Todo hook que corre en background (`post-commit` · cualquier futuro `post-merge` · `post-checkout` con side effects) DEBE capturar exit code + loguear timestamp + SHA + resultado a `.git/<hook>-<purpose>.log` (gitignored). Sin logging, un fallo silencioso pasa desapercibido por días (ej: backup roto sin alarma). Patrón canónico: redirigir stderr al log + capturar `$?` post-comando + escribir línea estructurada `<ISO-timestamp> <SHA> <exit_code> <message>`. El smoke test del hook debe verificar que el patrón de logging está presente (grep al hook).

### Logging asíncrono · patrón canónico

```bash
#!/usr/bin/env sh
# .husky/post-commit
. "$(dirname "$0")/_/husky.sh"

LOG=".git/post-commit-backup.log"
SHA=$(git rev-parse HEAD)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

git push --quiet origin HEAD:dev-backup 2>>"$LOG"
EXIT=$?

if [ $EXIT -ne 0 ]; then
  echo "$TS $SHA exit=$EXIT FAILED post-commit backup push" >> "$LOG"
else
  echo "$TS $SHA exit=0 OK" >> "$LOG"
fi

# Hook NO bloquea en ningún caso · solo registra
exit 0
```

El smoke test del hook verifica que: (a) el log path existe en el script · (b) el exit code se captura · (c) el hook termina con `exit 0` (cero bloqueo en backup roto).

**Nota sobre el patrón canónico vs el hook real del proyecto:** el ejemplo arriba es el **mínimo contractual** que el smoke test debe verificar. El hook real del proyecto (`.husky/post-commit`) puede extender el patrón con auto-recovery non-fast-forward (`git push --force-with-lease` ante stale `dev-backup` post-squash · paridad regla [`push-and-ci-policy.md`](./push-and-ci-policy.md) sync-dev post-squash) · ejecución en background `( ... ) &` para no bloquear nuevos commits · branching por tipo de fallo (non-FF auto-recovery vs FAIL log diagnóstico). El smoke test acepta esas extensiones siempre que las 3 invariantes (a)/(b)/(c) sigan presentes · cero refactor obligatorio del hook real para alinearse al ejemplo simplificado.

**Procedimiento al modificar un hook:**

1. Identificar smoke test asociado (tabla arriba).
2. Si NO existe, escribirlo (con shape simple: bash + grep / parse · NO Playwright).
3. Aplicar el cambio al hook.
4. Correr el smoke test → debe pasar.
5. Commit con mensaje `refactor(husky): <hook> · <cambio> + smoke test actualizado`.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Mi cambio al hook es trivial · no hace falta smoke test" | NO. Trivial hoy · regresión silenciosa mañana cuando alguien refactore el script invocado. El smoke test cuesta 20 LoC · pagar el costo siempre. |
| "El hook ya pasa local · CI lo va a pescar si rompe" | NO. CI remoto solo valida el job que rompe (post-push). Si el hook falla SILENCIOSAMENTE (ej: `set -e` removido · script invocado retorna 0 sin hacer nada), CI no lo atrapa porque CI no corre los hooks. Smoke test es la única red. |
| "Agrego hook nuevo · escribo smoke test después · primero quiero que ande" | NO. Smoke test desde el día 1 · es parte del DoD. Sin smoke test, la próxima persona que modifique el hook NO sabe qué invariante preservar. |

## Red flags

- 🚩 Tu commit modifica `.husky/<hook>` o un script invocado desde el hook · y NO hay diff en `tests/scripts/`.
- 🚩 Agregaste hook nuevo y tu commit NO incluye smoke test asociado.
- 🚩 Cambiaste orden de jobs en `local-ci.sh` y NO actualizaste `ci.yml` (o viceversa) · el invariante de paridad se rompe silenciosamente sin smoke que lo defienda.
- 🚩 Tu hook tiene `set -e` removido · falla silenciosamente sin smoke que lo atrape.

## Verification

- [ ] Cualquier cambio a hook tiene smoke test correspondiente actualizado en el mismo commit.
- [ ] Smoke test corre verde localmente antes del commit (EXIT=0).
- [ ] Hook nuevo llega con smoke test desde el día 1 (cero excepciones).
- [ ] Si tocaste `local-ci.sh` o `ci.yml` · verificar paridad de orden de jobs entre ambos archivos (manual mientras no exista smoke mecánico de paridad en el proyecto derivado).
- [ ] Backup `post-commit` verificado: `git push origin HEAD:dev-backup` corre asíncrono · branch existe en remote.

**Cross-reference firme:**

- Refuerza: [`tests-as-dod-per-phase.md`](./tests-as-dod-per-phase.md).
