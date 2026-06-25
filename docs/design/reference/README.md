# `docs/design/reference/` · Design Reference · output de Claude Design

> **Qué es:** carpeta con el output curado de Claude Design · referencia visual para implementar UI consistente con el Design System del producto. Contiene UI kits (prototipos del proveedor) + HTML previews de tokens y componentes en aislamiento + sub-carpetas por PRP con bundles cerrados.
>
> **Por qué se creó:** materializar el lado **output** del flujo `PRP → Claude Design → Implementación` (regla #28 [`claude-design-matrix.md`](../../../.claude/rules/claude-design-matrix.md)). Sin esta carpeta, el handoff visual quedaría disperso entre conversaciones de claude.ai y los briefs de [`../handoff/`](../handoff/) · y la implementación carecería de SoT visual canónica.
>
> **Para qué sirve:** consultar antes de implementar UI nueva en `src/` · evitar duplicar diseño · mantener consistencia con el DS del producto. Si la UI cae bajo `SÍ`/`CHICO` de la matriz Claude Design (página/pantalla/layout/form/modal nuevo) y NO hay mockup acá → frenar y pasar por Claude Design primero (regla #28).

## Convención

- **Prototipos:** los UI kits son prototipos de alta fidelidad (típicamente JSX con inline styles + iconografía por CDN). **No copiar tal cual** · traducir al stack real (ej: TSX + Tailwind con los tokens del DS) al integrar a `src/`.
- **HTML previews:** abrirlos directo en el browser (`xdg-open <file>.html` Linux · `open <file>.html` Mac). Sirven para chequear paleta/tipografía/spacing/componentes en aislamiento sin levantar el dev server.
- **Versión navegable del stack:** si el proyecto mantiene demos en vivo (ej: `src/app/dev/` en Next.js) con los UI kits ya traducidos al stack, ese es el espejo runtime de esta referencia.
- **Sub-carpetas por PRP:** los handoffs Claude Design por PRP viven como bundles inmutables · NO editar el contenido del bundle · referencia para integración.
- **Vacío al boot del pack:** sin UI kits ni previews al arrancar · el adopter los puebla conforme cada PRP que toca UI cierra su handoff.

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`preview/`](./preview/) | HTML previews del DS en aislamiento (color · tipografía · geometría · componentes · iconografía · logo · voice) |
| [`ui_kits/`](./ui_kits/) | UI kits con prototipos del proveedor · kit base del backoffice + sub-carpetas por feature/PRP |

## Carpetas hermanas

- [`../handoff/`](../handoff/) — briefs originales (input PARA Claude Design) + bundles cerrados de handoff por PRP.
- [`../../product/references/`](../../product/references/) — strategy + constraints + vocabulario del producto · contexto que alimenta los briefs.

## Reglas firmes asociadas

- [`../../../.claude/rules/claude-design-matrix.md`](../../../.claude/rules/claude-design-matrix.md) — matriz de decisión sobre cuándo abrir sesión Claude Design vs primitivos directos del DS (regla #28).
- [`../../../.claude/rules/heuristica-referente-mercado.md`](../../../.claude/rules/heuristica-referente-mercado.md) — el referente del rubro es el anchor del DS (regla #29).
- [`../../../.claude/rules/folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22).

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
