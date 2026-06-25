# `tests/scripts/` · Smoke tests bash de la fábrica del proyecto

> **Qué es:** scripts bash que verifican invariantes mecánicos de la fábrica del proyecto (orden de jobs CI · shape de skills · shape P8 de reglas firmes · paridad local↔remoto · hooks Husky no degenerados · estado canónico post fresh-install · skip-ci no en HEAD del PR · pre-condition checks de agentes domain-tight). NO son tests del producto · NO son tests E2E. Son la red de seguridad de la infra del flujo de 6 pasos.
>
> **Por qué se creó:** capturar gotchas empíricamente vividos en el flujo del proyecto (orden de jobs CI desincronizado · skill sin shape canónico · hooks Husky deshabilitados silenciosamente · etc) como invariantes binarios verificables en CI. Sin esta capa, las regresiones de la fábrica se descubren tarde y duelen.
>
> **Para qué sirve:** garantizar paridad estructural local↔remoto · atrapar drift entre archivos hermanos · convertir cada lección de la fábrica en check mecánico que rompe CI antes de que el bug llegue a producción.

## Convención

- **Naming:** `<dt-NNN | prp-NNN | <invariante>>-<descripción-corta>.sh` (ej: `rules-shape-p8.sh` · `husky-hooks-not-degenerated.sh` · `skip-ci-not-in-pr-head.sh`).
- **Plantilla bash:** `set -euo pipefail` + funciones `ok` / `fail` + EXIT 0/1 claros (referencia: cualquier smoke vigente en `infra-flujo/`).
- **Severidad:** ABORT (job `lint` del CI) si rompe regla operacional firme · warning (job separado con `continue-on-error: true`) si es heurística con falso positivo legítimo.
- **Wiring CI:** smokes ABORT bloquean el job `lint` del CI remoto + `scripts/local-ci.sh` local · paridad mecánica entre canales (smoke al canal que cubre).

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`infra-flujo/`](./infra-flujo/) | Smokes activos wireados al CI · invariantes del flujo de 6 pasos (shape P8 de reglas · shape de skills · hooks Husky · skip-ci · fresh-install · pre-condition de agentes domain-tight · paridad sync-dev) |

## Archivos en raíz (al boot del template)

> Raíz **vacía** (solo este README) · todos los smokes activos viven bajo [`infra-flujo/`](./infra-flujo/). La raíz queda disponible para smokes futuros que NO encajen en la categoría "invariantes del flujo de 6 pasos" (paridad regla [`respect-existing-folder-structure`](../../.claude/rules/respect-existing-folder-structure.md) · cero subcarpetas especulativas).

## Carpetas hermanas

- [`scripts/`](../../scripts/) (raíz del repo) — infra del CI / linting general (`local-ci.sh` · `lint-memory.sh` · `archive-log.sh` · etc) · estos smokes consumen archivos de ahí.
- [`.github/workflows/`](../../.github/workflows/) — CI remoto que ejecuta los jobs validados por estos smokes.
- [`tests/sql/`](../sql/) — invariantes SQL · capa BD · complementaria a esta capa de fábrica.

## Cómo agregar un smoke nuevo

1. **Decidir scope:** ¿es invariante del flujo de 6 pasos? → `infra-flujo/` (ver el [README de esa carpeta](./infra-flujo/README.md) para las 6 reglas operativas detalladas).
2. **Naming canónico:** `<descripción-en-kebab-case>.sh` · plantilla bash con `set -euo pipefail`.
3. **Severidad:** ABORT (job `lint`) si rompe regla firme · warning si tiene falso positivo legítimo.
4. **Wiring CI:** sumar al job correspondiente en `.github/workflows/ci.yml` + en `scripts/local-ci.sh` (paridad mecánica · cero asimetría entre canales).
5. **Verificar local antes de pushear:** correr el smoke a mano + correr el job `lint` completo (`npm run ci:local -- --only=lint` o equivalente del stack del adopter).

---

*Convención de README firmada 2026-05-25 (regla [`folder-creation-with-readme.md`](../../.claude/rules/folder-creation-with-readme.md)).*
