---
name: 'Playwright `getByLabel` matchea por substring → colisiona con aria-labels superstring'
description: getByLabel(text) sin `exact:true` hace match case-insensitive por substring. Un `<select aria-label="Rol de X">` colisiona con su botón hermano `<button aria-label="Guardar rol de X">` (superstring) → strict-mode violation. Usar `{ exact: true }` cuando dos accessible names comparten stem.
type: feedback
---

`page.getByLabel('Rol de X')` **sin** `{ exact: true }` resuelve por **substring case-insensitive**: matchea cualquier elemento cuyo accessible name *contenga* `"rol de x"`. Cuando un control (`<select aria-label="Rol de X">`) convive con un botón hermano cuyo aria-label es **superstring** (`<button aria-label="Guardar rol de X">`), ambos matchean → `strict mode violation: resolved to 2 elements`.

**Why:**

- Detectado en `/validar` PRP-002 (fila CSV MBR3): el e2e CRUD de miembros se actualizó en LR-002 (lr_bug_004) del auto-submit en `onChange` a un submit explícito con botón "Guardar" (aria-label `Guardar rol de {email}`). El spec locateaba el `<select>` con `getByLabel(\`Rol de ${email}\`)` — que ahora colisiona con el botón. El componente es **correcto** (dos accessible names distintos y claros para un lector de pantalla: "Rol de X, combobox" y "Guardar rol de X, button"); el bug es puramente del **locator del test**.
- `getByRole('button', { name: 'Guardar rol de X' })` NO colisiona porque el rol acota (el select no es button). El problema aparece solo cuando el locator NO acota por rol y el valor es substring de otro accessible name.
- Un accessible name que es *substring* del locator (ej: botón "Cambiar" bajo `getByLabel('Cambiar de organización')`) NO colisiona — el match es "el accessible name contiene el texto buscado", no al revés. Solo colisiona el **superstring**.

**How to apply:**

- Al locatear un control por `getByLabel`/`getByRole` cuyo accessible name comparte stem con un elemento hermano (típico: `<select aria-label="Rol de X">` + botón "Guardar rol de X" · switcher + botón "Cambiar" · cualquier form con label + submit que repite el label), usar `{ exact: true }`.
- Alternativa: acotar por rol (`getByRole('combobox', { name: ... })`) o por `locator('select[name="role"]')`.
- Regla mental: si el flujo pasó de `onChange` a submit explícito (patrón WCAG 3.2.2 · no auto-submit), revisá que los locators del `<select>` no colisionen con el nuevo botón "Guardar/Confirmar".
