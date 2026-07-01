# `src/` · Código de aplicación de PUERTITA

> **Qué es:** raíz del código de aplicación Next.js (App Router). Todo el código de producto vive bajo este árbol. El path alias `@/*` (definido en `tsconfig.json`) resuelve a `./src/*`.
>
> **Por qué se creó:** carpeta canónica del framework Next.js App Router · pre-declarada por los stubs del template (`tsconfig.json` paths · `tailwind.config.ts` content · `components.json` aliases). Materializada en PRP-001 (scaffold + infra base · 2026-06-26) con firma 🔵 user al aprobar el PRP.
>
> **Para qué sirve:** alojar rutas, componentes, helpers y servicios del producto separados de la config/infra de la raíz del repo.

## Subcarpetas

| Carpeta | Rol |
|---|---|
| [`app/`](./app/) | Rutas y layouts del App Router (`page.tsx` · `layout.tsx` · `globals.css`). Paths en inglés (regla #31). |
| [`lib/`](./lib/) | Helpers y servicios por dominio. `lib/supabase/` aloja los clientes browser/server. |

## Convención

- **Paths del framework en inglés** (regla #31 `routing-paths-in-english`) · copy de UI en español.
- **Componentes:** `src/components/` se crea cuando exista el primer componente real (simplicity-first · no antes).
- **Tokens del DS:** definidos en `src/app/globals.css` (CSS vars que consume `tailwind.config.ts`).

## Carpetas hermanas

- [`../tests/`](../tests/) — specs e2e/sql/unit + smokes de infra del flujo.
- [`../db/`](../db/) — migraciones y seeds (vacío al boot · schema real desde TASK-002).

---

*Convención de README firmada 2026-06-26 (regla [`folder-creation-with-readme.md`](../.claude/rules/folder-creation-with-readme.md)).*
