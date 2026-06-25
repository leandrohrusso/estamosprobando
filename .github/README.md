# `.github/` · GitHub configuration · CI workflows + PR template

> **Qué es:** carpeta de configuración GitHub del repo · contiene workflows de GitHub Actions (CI remoto) + template de pull requests + cualquier metadata específica de GitHub.
>
> **Por qué se creó:** convención GitHub para repos · todo lo que GitHub necesita leer (workflows · templates · CODEOWNERS · etc) vive acá. Materializa la regla firme #27 [`push-and-ci-policy.md`](../.claude/rules/push-and-ci-policy.md) ("1 push = 1 PR = 1 CI por PRP del producto").
>
> **Para qué sirve:** definir el CI remoto que valida cada PR antes del merge · dar shape a los PRs nuevos vía template estándar · garantizar que la política de pushes y CI runs del proyecto se cumple mecánicamente.

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`workflows/`](./workflows/) | GitHub Actions workflows (CI remoto del proyecto · jobs bloqueantes sobre `pull_request` no-draft) |

## Archivos en raíz

| Archivo | Rol |
|---|---|
| [`PULL_REQUEST_TEMPLATE.md`](./PULL_REQUEST_TEMPLATE.md) | Template aplicado automáticamente al abrir cualquier PR · estructura SoT del PR (resumen · checklist obligatorio · test plan · cross-refs a reglas del flujo) |

## Carpetas hermanas

- [`.husky/`](../.husky/) — hooks Git locales · validación `pre-commit` / `pre-push` antes de que el cambio llegue a CI remoto · paridad gate con el CI.
- [`scripts/`](../scripts/) — `local-ci.sh` simétrico al CI remoto · permite reproducir todos los jobs localmente antes del push (regla #27 § "1 local CI gate por PRP").
- [`tests/scripts/infra-flujo/`](../tests/scripts/infra-flujo/) — smoke tests bash invocados desde los workflows del CI (invariantes del flujo · regla satélite [`husky-hooks-smoke-tests.md`](../.claude/rules/husky-hooks-smoke-tests.md)).

## Reglas firmes asociadas

- [`push-and-ci-policy.md`](../.claude/rules/push-and-ci-policy.md) — regla #27 · 1 push + 1 PR + 1 CI remoto + 1 local CI gate por PRP del producto.
- [`husky-hooks-smoke-tests.md`](../.claude/rules/husky-hooks-smoke-tests.md) — regla #34 · hooks Husky con smoke tests · paridad con jobs del CI cuando aplica.

---

*Convención de README firmada 2026-05-24 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
