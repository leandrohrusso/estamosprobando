# `docs/design/reference/preview/` · HTML previews del Design System

> **Qué es:** carpeta de HTML previews estáticos del Design System del producto · cada archivo muestra una pieza del DS en aislamiento (paleta de color · escala tipográfica · geometría · componentes base · iconografía · logo · voz/copy) para inspección visual rápida sin levantar el dev server.
>
> **Por qué se creó:** dar una forma de auditar los tokens y componentes del DS de un vistazo · separada de los UI kits completos de [`../ui_kits/`](../ui_kits/) (que muestran pantallas armadas). Un preview por dimensión del DS facilita verificar consistencia de la paleta/tipografía/spacing cuando se implementa UI nueva.
>
> **Para qué sirve:** abrir en el browser para chequear una pieza del DS en aislamiento antes de implementar · confirmar que un token nuevo encaja con el resto · servir de referencia visual canónica de los primitivos del Design System.

## Convención

- **Formato:** HTML estático autocontenido · abrir directo en el browser (`xdg-open <file>.html` Linux · `open <file>.html` Mac) · cero build · cero dev server.
- **Una pieza por archivo:** naming descriptivo por dimensión del DS (ej: `colors-brand.html` · `type-scale.html` · `buttons.html` · `spacing.html` · `iconography.html`).
- **Espejo del runtime:** los previews reflejan los tokens efectivos del DS en producción (ej: `src/app/globals.css` + `src/lib/theme.ts` en un stack Next.js) · si un token cambia en el runtime, regenerar el preview correspondiente.
- **Vacío al boot del pack:** sin previews al arrancar · el adopter los genera cuando Claude Design entrega el DS base o cuando se consolidan los tokens del proyecto.

## Archivos actuales

_(vacío al boot · llenar con `<dimensión>.html` conforme se consolide el DS del producto)_

| Archivo | Rol |
|---|---|
| — | — |

## Categorías sugeridas

| Categoría | Ejemplos de archivo |
|---|---|
| Color | `colors-brand.html` · `colors-neutrals.html` · `colors-semantic.html` |
| Tipografía | `type-families.html` · `type-scale.html` |
| Geometría | `radii.html` · `shadows.html` · `spacing.html` |
| Componentes | `buttons.html` · `inputs.html` · `cards.html` · `badges.html` · `table.html` |
| Otros | `iconography.html` · `logo.html` · `voice.html` |

## Carpetas hermanas

- [`../ui_kits/`](../ui_kits/) — UI kits completos (pantallas armadas) · estos previews muestran los primitivos por separado.
- [`../../handoff/`](../../handoff/) — briefs originales que dieron input a Claude Design para generar el DS.

## Reglas firmes asociadas

- [`../../../../.claude/rules/claude-design-matrix.md`](../../../../.claude/rules/claude-design-matrix.md) — toda UI nueva pasa por matriz Claude Design antes de implementar (regla #28).
- [`../../../../.claude/rules/folder-creation-with-readme.md`](../../../../.claude/rules/folder-creation-with-readme.md) — convención de README + shape canónico (regla #22).

---

*Convención de README firmada (regla [`folder-creation-with-readme.md`](../../../../.claude/rules/folder-creation-with-readme.md) · pack `workflow-base`).*
