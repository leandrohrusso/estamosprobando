# `.husky/` · Git hooks locales

> **Qué es:** carpeta de hooks de Git gestionada por Husky. Contiene 3 hooks activos (`pre-commit` · `pre-push` · `post-commit`) que enforce typecheck/lint/build localmente antes de que el cambio salga del entorno del dev + backup automático.
>
> **Por qué se creó:** convención Husky · materializa la cobertura local de las reglas firmes ([`husky-hooks-smoke-tests.md`](../.claude/rules/husky-hooks-smoke-tests.md)). Sin estos hooks, los errores TS/lint llegarían al CI remoto · costaría minutos de GitHub Actions y cycle time del flujo.
>
> **Para qué sirve:** validación local pre-commit (typecheck + lint via lint-staged) · validación local pre-push (typecheck + build) · backup automático post-commit (`git push --quiet origin HEAD:dev-backup`) que protege el trabajo si WSL2 muere.

## Archivos actuales

| Archivo | Trigger | Rol |
|---|---|---|
| `pre-commit` | Antes de cada `git commit` | typecheck + lint sobre archivos staged (lint-staged) |
| `pre-push` | Antes de cada `git push` | typecheck + lint · gate antes de que el cambio salga al remoto |
| `post-commit` | Después de cada `git commit` | `git push --quiet origin HEAD:dev-backup` · backup async no-bloqueante |

## Subcarpetas

| Carpeta | Rol |
|---|---|
| `_/` | Carpeta auto-generada por Husky · contiene `husky.sh` interno · NO modificar a mano |

## Carpetas hermanas

- [`.claude/hooks/`](../.claude/hooks/) — hooks del agente Claude Code (NO confundir · son canales distintos · `.husky/` corre en eventos de Git del dev · `.claude/hooks/` corre en eventos del harness del agente Claude Code).
- [`.github/workflows/`](../.github/workflows/) — CI remoto · canal complementario · estos hooks son la primera capa local · CI remoto es la red final.
- [`tests/scripts/infra-flujo/`](../tests/scripts/infra-flujo/) — smoke tests que verifican que estos hooks NO degeneraron a stub (`husky-hooks-not-degenerated.sh`).
- [`scripts/`](../scripts/) — `local-ci.sh` reproduce los 6 jobs del CI · puede invocarse manualmente para validación más profunda que la del hook.

## Reglas firmes asociadas

- [`husky-hooks-smoke-tests.md`](../.claude/rules/husky-hooks-smoke-tests.md) — cualquier cambio a un hook obliga actualizar el smoke test correspondiente.
- [Política de pushes y CI runs](../.claude/rules/push-and-ci-policy.md) — el `post-commit` materializa la regla "backup automático a `dev-backup`" (2026-05-04).

---

*Convención de README firmada 2026-05-10 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
