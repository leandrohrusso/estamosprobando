---
name: stack-versions-PRP-001
description: Versiones exactas del stack instaladas en PRP-001 (scaffold) verificadas contra el npm registry · TASK-002+ las hereda sin re-suponer.
metadata:
  type: reference
---

# Stack versions · PRP-001 scaffold (2026-06-26)

Versiones verificadas contra el **npm registry** durante PRP-001 Fase 1 (regla #7 [[no-suponer-fuente-de-verdad]] · cero memoria del LLM). TASK-002+ heredan este set salvo bump explícito.

| Librería | Versión | Verificado contra | Nota |
|---|---|---|---|
| next | ^16.2.9 | registry 2026-06-26 | engines node >=20.9.0 |
| react | ^19.2.7 | registry | peer de next ^19 |
| react-dom | ^19.2.7 | registry | — |
| @supabase/supabase-js | ^2.108.2 | registry | — |
| @supabase/ssr | ^0.12.0 | registry | cliente browser+server |
| tailwindcss | ^3.4.19 | registry (`@3` tag) | **v3 por 🔵 Bif 2=A** · v4 latest es 4.3.1 pero rompería los stubs |
| autoprefixer | ^10.5.2 | registry | — |
| postcss | ^8.5.15 | registry | plugin `tailwindcss: {}` estilo v3 |
| tailwindcss-animate | ^1.0.7 | registry | importado en tailwind.config.ts |
| typescript | ^6.0.3 | registry | dentro de rango typescript-eslint (<6.1.0) |
| @types/node | ^20.19.43 | registry | **alineado a CI node 20** (no a local node 24) |
| @types/react | ^19.2.17 | registry | — |
| @types/react-dom | ^19.2.3 | registry | — |
| eslint | ^9.39.4 | registry | **v9, NO v10** · ver compat abajo |
| typescript-eslint | ^8.62.0 | registry | peer eslint 8/9/10 · TS <6.1.0 |
| eslint-plugin-react | ^7.37.5 | registry | peer eslint ≤^9.7 (cap en 9) |
| eslint-plugin-import | ^2.32.0 | registry | peer eslint ≤^9 (cap en 9) |
| @next/eslint-plugin-next | ^16.2.9 | registry | — |
| globals | ^17.7.0 | registry | — |
| vitest | ^4.1.9 | registry | engines node ^20\|\|^22\|\|>=24 |
| @playwright/test | ^1.61.1 | registry | peer de next ^1.51.1 |
| husky | ^9.0.0 | (ya en template) | — |
| lint-staged | ^15.0.0 | (ya en template) | — |

## Decisión de compat crítica · eslint 9 (no 10)

eslint 10.6.0 es el latest pero **rompe el install**: `eslint-plugin-react@7.37.5` tiene peer `eslint ≤^9.7` y `eslint-plugin-import@2.32.0` tiene peer `eslint ≤^9` — ninguno soporta eslint 10 todavía. Se fija **eslint ^9.39.4** que satisface a todos los plugins + `typescript-eslint@8.62` (peer eslint 8/9/10). Cuando los plugins publiquen soporte eslint 10, evaluar bump (DT futura si aplica).

## Compat verificada (sin conflicto)

- Tailwind v3.4.19 + Next 16 + React 19 → OK (Tailwind v3 es plugin postcss agnóstico del framework · `postcss.config.js` usa sintaxis v3 correcta). Bif 2=A NO requirió escalada.
- TS 6.0.3 dentro del rango soportado por typescript-eslint 8.62 (`>=4.8.4 <6.1.0`).
- next 16 engines `node >=20.9.0` · vitest 4 engines `^20||^22||>=24` → CI node 20 ✅ · local node 24 ✅.
