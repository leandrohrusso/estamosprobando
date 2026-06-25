# `docs/design/reference/ui_kits/` · UI kits del Design System

> **Qué es:** raíz de UI kits del Design System del producto · contiene el kit base (prototipos del lenguaje visual del producto en la raíz) más sub-carpetas por feature/PRP con kits específicos. Cada kit es output de Claude Design integrado al repo como referencia.
>
> **Por qué se creó:** materializar el handoff visual de Claude Design hacia la implementación en `src/`. Los prototipos recrean las pantallas con el DS completo aplicado (tokens · tipografía · iconografía · voz) para que la implementación tenga una referencia de alta fidelidad y no se diseñe sobre la marcha.
>
> **Para qué sirve:** consultar antes de implementar UI nueva en `src/` · evitar duplicar diseño · mantener consistencia visual y de tono con el DS · servir de input cuando se genera UI consistente con los primitivos del Design System.

## Convención

- **Formato:** prototipos de alta fidelidad (típicamente `.jsx` con inline styles + iconografía por CDN). NO copiar tal cual al integrar a `src/` · traducir al stack real (ej: TSX + Tailwind con tokens del DS aplicados).
- **Kit base en la raíz:** los archivos del lenguaje visual general del producto (layout shell · navegación · cards · tablas base) viven en la raíz de `ui_kits/`. Establecen el lenguaje del backoffice/app.
- **Kits por feature/PRP en sub-carpetas:** `<feature>/` o `prp-NNN-<feature>/` para pantallas específicas · cuando vienen del proveedor como bundle, son inmutables.
- **Index navegable:** si el kit incluye un `index.html`, permite click-through entre las pantallas sin levantar el dev server.
- **Vacío al boot del pack:** sin kits al arrancar · el adopter los puebla conforme cada PRP que toca UI cierra su handoff de Claude Design.

## Archivos en raíz (kit base)

_(vacío al boot · llenar con los prototipos del lenguaje visual base cuando Claude Design entregue el kit del backoffice/app)_

| Archivo | Rol |
|---|---|
| — | — |

## Subcarpetas (kits por feature/PRP)

_(vacío al boot · llenar con `<feature>/` o `prp-NNN-<feature>/` conforme lleguen los handoffs)_

| Sub-carpeta | Rol | Brief |
|---|---|---|
| — | — | — |

## Carpetas hermanas

- [`../preview/`](../preview/) — HTML previews del DS en aislamiento (color · tipografía · geometría · componentes) · estos kits muestran pantallas armadas.
- [`../../handoff/`](../../handoff/) — briefs originales que dieron input a Claude Design para generar estos kits.

## Reglas firmes asociadas

- [`../../../../.claude/rules/claude-design-matrix.md`](../../../../.claude/rules/claude-design-matrix.md) — toda UI nueva pasa por matriz Claude Design antes de implementar (regla #28).
- [`../../../../.claude/rules/heuristica-referente-mercado.md`](../../../../.claude/rules/heuristica-referente-mercado.md) — el referente del rubro es el anchor del DS (regla #29).
- [`../../../../.claude/rules/folder-creation-with-readme.md`](../../../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22).

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
