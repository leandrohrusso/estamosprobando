---
name: claude-design-matrix
description: Toda feature con UI nueva sigue orden FIRME PRP → Claude Design → Implementación · Claude Design es especialista en decisiones de UX, no fábrica de mockups · matriz decide cuándo SÍ/CHICO/NO
type: rule
applies-to: cualquier task con UI nueva en Modo C · just-in-time por PRP, no batch
---

## Overview

Toda feature que toca UI nueva sigue este orden FIRME:

```text
1. PRP             → define QUÉ se construye (features, schema, flujos, fases, criterios de éxito)
2. Claude Design   → con el brief del PRP, diseña las superficies que la matriz justifique
3. Implementación  → /implementar ejecuta el PRP siguiendo los mockups + PRP al pie de la letra
4. Cierre código   → auditoría + /simplify + /security-review + REGLA DE ORO · cierre de implementación
5. Validación      → /validar: CSV 100% verde (Playwright MCP + Supabase MCP + fixes senior)
6. Cierre final    → REGLA DE ORO · cierre de validación + commit local + paso 6 (run local CI → push único → PR)
```

**Por qué este orden:**

- **PRP antes que diseño** — sin PRP, Claude Design tiene que inventar el flow (modal vs subform, qué campos agrupar, qué se valida cuándo). Con el PRP, las entidades, campos y reglas ya están decididas; Claude Design se ocupa solo del lenguaje visual y la disposición.
- **Diseño antes que código** — sin Claude Design previo cuando aplica, repetimos el error de una task upstream (auth con shadcn vainilla → rehecho desde cero).
- **Testing al cierre** — sin verificación E2E, los criterios de éxito del PRP quedan declarativos.

**Just-in-time, no batch:** una sesión de Claude Design por PRP. NO "diseñemos todo el roadmap ahora" — los mockups de turnos lejanos quedan desactualizados respecto a lo aprendido en los turnos anteriores.

**El error histórico que la regla evita:** una task upstream (auth UI) se construyó sin pasar por Claude Design — shadcn vainilla + copy genérico ("Iniciar sesión", "Bienvenido de vuelta"). No fue por improvisar diseño visual (los tokens estaban): fue por **decidir layout, copy y jerarquía sin criterio de UX**. Hubo que rehacer todo el visual después con un pass dedicado.

## When

**Estados del PRP frente al diseño:**

- `PENDIENTE` → vos revisás el PRP. Identificás qué superficies UI tienen las fases que enumera y aplicás la matriz.
- `APROBADO` → si la matriz lo justifica, se abre sesión de Claude Design con las superficies del PRP como brief. Mockups vuelven al repo en `docs/design/handoff/prp-NNN-.../`.
- `EN PROGRESO` → `/implementar` ejecuta. Fases de schema/lógica pueden arrancar antes del handoff visual; fases de UI esperan.
- `COMPLETADO` → criterios de éxito del PRP chequeados.

**Cómo se refleja en el PRP:** las fases de UI del PRP no listan archivos JSX hasta que haya mockup. Se escriben como:

> **Fase N — UI X:** pendiente de handoff Claude Design para `[superficie]`. Mockup esperado en `docs/design/handoff/prp-NNN-.../`. Implementación arranca cuando llega el handoff.

## Process

### La regla única

Antes de invocar Claude Design, preguntar:

> *"¿hay decisiones de UX que tomar en esta pantalla?"*

Si no → primitivos directo, sin sesión de diseño. El valor de Claude Design es el **CRITERIO**, no el output.

### Matriz de decisión

| Tipo de superficie | ¿Claude Design? |
|---|---|
| Decisión estructural / nueva experiencia (sidebar, layout shell, dashboard, página core nueva) | **SÍ** |
| Microinteracción nueva (combobox inline, drag-drop, modal multi-step) | **CHICO** (1 brief, ~3 estados) |
| Form simple (2-3 campos + botón) | **NO** — primitivos directo |
| Variante de algo ya hecho | **NO** |
| Cambio menor (campo, copy, padding) | **NO** |
| Primera impresión cliente final (ej: en un dominio ticketing serían página pública del comprador, landing white-label · adaptá a las superficies consumer-facing de tu dominio) | **SÍ FUERTE** — sesgo de implementador puede comerse decisiones de conversión |
| UX especializada (modo evento mobile en cancha, validación QR con manos ocupadas) | **SÍ FUERTE** — ergonomía no estándar |

### Cuándo usar claude.ai con proyecto dedicado vs Claude Code directo

| Caso | Tool |
|---|---|
| Sé QUÉ quiero, falta materializar (decisión cerrada — sidebar Linear-style, listado tipo Cal.com) | claude.ai con proyecto dedicado |
| Decisión abierta (3+ alternativas razonables, querés explorar y discutir) | claude.ai con proyecto dedicado |
| Iteración chica sobre algo ya generado | Claude Code directo (edit del demo en `/dev/*`) |

### Procedimiento cuando una task entra en "SÍ" o "CHICO" de la matriz

1. Verificar si ya hay mockup en `docs/design/reference/` o en una handoff reciente (busca con `find docs/design/reference -type f` y `git log --diff-filter=A --name-only` para handoffs recientes).
2. Si NO existe, FRENAR antes de escribir JSX y decir al usuario textualmente:
   > *"Esta task tiene UI nueva [describir qué pantalla/componente]. Antes de implementar conviene pasar por Claude Design para que no salga genérico. ¿Abrimos un proyecto en Claude Design o usamos los primitives del DS sin mockup?"*
3. ESPERAR respuesta antes de proceder.
4. Si el user dice "abrimos Claude Design" → standby hasta que pase el handoff.
5. Si el user dice "hacela directo, sin Claude Design" o equivalente → proceder con los primitives del DS sin preguntar de nuevo.

### Recursos de diseño en el repo

*Tokens (fuente de verdad):*

- `src/app/globals.css` — CSS vars completas (terracota + sage + neutrals warm + estados + escala tipográfica + radii + shadows).
- `src/lib/theme.ts` — espejo TS para runtime (Recharts, white-label, SVG).
- `tailwind.config.ts` — Tailwind expone los tokens.

*Demos en vivo* (sin auth):

- <http://localhost:3000/dev/listado-standard> — 3 ejemplos × 8 estados.
- <http://localhost:3000/dev/form-evento> — crear/editar × validación/AI.
- <http://localhost:3000/dev/detalle-orden> — 4 estados orden + modal refund.

*Componentes producción a REUSAR (no recrear):*

- `src/components/auth/` — auth-card, auth-banner, password-input, password-strength, forms conectados.
- `src/components/listado-standard/` — `ListadoStandard<T>`, `ExpandedShell`, `ResumenAgregado`.
- `src/components/forms/` — `FormSection`, `Field`, `Toggle`, `ToggleRow`, `GhostButton`.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Esta UI es chica, salto Claude Design" | Check matriz primero: ¿es form de 2 campos o variante? → NO Claude Design. ¿Es decisión estructural o cliente final? → SÍ. La matriz cierra la duda sin improvisar. |
| "Uso shadcn vainilla, después lo refino" | NO. Ese fue el error de una task upstream (auth UI rehecha desde cero). El refinamiento "después" cuesta más que el pass de Claude Design upfront. |
| "Sidebar/topbar son patrones convencionales, no necesitan Claude Design" | Cierto: sidebar/topbar/dashboard de SaaS backoffice son patrones convencionales (Linear, Cal.com, Notion). Para esto, iteración en código directo con primitives del DS alcanza. claude.ai conversacional solo agrega valor cuando la decisión es genuinamente abierta — no confundir "**estructural**" (que es CRITERIO) con "**convencional**" (que es PATTERN). |

## Red flags

- 🚩 Vas a escribir JSX de pantalla nueva sin haber consultado matriz.
- 🚩 La pantalla es "primera impresión cliente final" o UX especializada y NO frenaste para preguntar Claude Design.
- 🚩 Estás copiando layout de otro módulo sin verificar si la matriz pedía pass dedicado.
- 🚩 La fase del PRP lista archivos JSX pero el handoff de Claude Design no existe en `docs/design/handoff/prp-NNN-...`.

## Verification

- [ ] Para cada superficie nueva del PRP, matriz consultada y decisión documentada (SÍ / CHICO / NO).
- [ ] Si SÍ o CHICO: handoff de Claude Design existe en `docs/design/handoff/prp-NNN-...` antes de implementar.
- [ ] Si NO: justificación mecánica documentada (form simple, variante, cambio menor).
- [ ] Componentes producción reusados (no recreados desde cero) cuando aplican (`auth/`, `listado-standard/`, `forms/`).

**Cross-reference firme:**

- Hermana operativa: [`think-before-coding.md`](./think-before-coding.md) (listar asunciones de UX antes de escribir JSX · matriz es el filtro que decide si hay decisiones de UX que tomar).
- Hermana operativa: [`simplicity-first.md`](./simplicity-first.md) (matriz "NO" para forms simples y variantes · primitives del DS sin sesión dedicada · mínimo necesario).
- Hermana operativa: [`decisiones-features.md`](./decisiones-features.md) (cada superficie nueva del PRP se evalúa una por una con la matriz · cero batch silencioso).
- Refuerza: [`heuristica-referente-mercado.md`](./heuristica-referente-mercado.md) (cuando la matriz disparó SÍ/CHICO · el referente del rubro alimenta la sesión de Claude Design).
