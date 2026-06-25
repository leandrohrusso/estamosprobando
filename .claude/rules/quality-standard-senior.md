---
name: quality-standard-senior
description: Toda acción del sistema (código · bugs · tests · docs · planificación · decisiones · archivado) se realiza con estándar senior profesional. Cero excepciones. Si no se sostiene · STOP.
type: rule
applies-to: cualquier acción del sistema (código · bugs · tests · docs · planificación · decisiones · archivado)
---

## Overview

> **Toda acción que ejecuta el sistema se realiza con estándar senior profesional. Cero excepciones. Si no se puede sostener el estándar en este momento (fatiga · contexto cargado · ambigüedad creciente), detenerte es PARTE de la regla, no su excepción.**

**Por qué firme:** el flujo prioriza calidad sobre velocidad · mediocre paga interés compuesto (bugs futuros · refactors evitables · deuda técnica invisible · pérdida de confianza). Mejor 5 acciones impecables que 8 mediocres. Codificada en sesión upstream · firma user 🔵 *"OK (Calidad senior siempre)"*.

**Subsume parcialmente** § "Siempre fixear todo, con calidad senior" de CLAUDE.md (hereda los 6 puntos del estándar). La política operativa "no diferir bugs por severidad" queda independiente en [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) · esa regla invoca este satélite para los 6 puntos sin duplicarlos.

## When

**Aplica a (todo el sistema · sin acotar):**

- Código nuevo (Server Actions · Client Components · helpers · services · hooks · stores).
- Modificación de código existente (refactors · adopciones · renames).
- Fixes de bugs (UR · CSV · bucle · reportes externos · review humano).
- Tests (regression-first · unit · E2E · SQL · smoke).
- Migraciones (DDL · RLS · RPCs · seeds).
- Documentación (PRPs · memorias · gobierno · roadmap · checkpoints · handoffs).
- Planificación (PRPs · sub-decisiones · roadmap · estrategia).
- Decisiones arquitectónicas (modo de trabajo · stack · tradeoffs).
- Archivado (mover · renombrar · eliminar) y limpieza.
- Reglas (codificar · refinar · cross-references).
- Configuración (settings · hooks · CI · env).

## Process

**Los 6 puntos del estándar (heredados de la regla previa "Siempre fixear todo, con calidad senior" · ahora aplican universalmente):**

1. **Senior, profesional, sustentable.** Pensado · simétrico con el resto del módulo · con WHY si la solución no es obvia · sin atajos. Si la acción se siente apurada o "hasta acá llego", parar y reescribir en frío.
2. **Cero hardcode.** Constantes mágicas → constantes nombradas. UUIDs/slugs/shortcodes en tests → fixtures/helpers. Strings de error → tablas de errores del módulo.
3. **Cero copy-paste.** Si la lógica ya existe en otro módulo, extraer helper compartido o referenciar el patrón con WHY. Duplicar = bug latente garantizado por divergencia futura.
4. **Cero código basura.** Sin TODOs vacíos · sin console.log olvidados · sin código comentado "por si acaso" · sin variables sin uso · sin imports muertos. Cada línea defiende su derecho a existir.
5. **Con esfuerzo, nunca con fatiga.** Si en N acciones del batch se cortan esquinas para terminar, ESTÁ FATIGADO — la regla es PARAR, no terminar. Mejor M < N acciones impecables + handoff que N mediocres en una sentada. Ver hermana [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) para el protocolo de detención.
6. **Simetría entre módulos hermanos.** Cuando dos módulos resuelven el mismo problema, sus implementaciones se mantienen simétricas. Asimetrías = bugs en potencia.

**Cómo aplicar:**

- **Antes de cada acción no trivial:** auto-pregunta *"¿puedo hacer esto con estándar senior ahora?"*. Si NO → la sub-rule [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) aplica · STOP + aviso al user.
- **Durante la acción:** respetar los 6 puntos. Si descubrís que un punto se rompió a mitad (ej: copy-paste descubierto), frenar · reescribir · NO entregar.
- **Al cerrar la acción:** revisar diff antes de commit. Si tiene líneas que NO defienden su derecho a existir, revertir o justificar.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico, lo entrego con un atajo y lo refino después" | NO. El "después" no llega · y el atajo se vuelve patrón. La regla es estándar senior siempre · si no se puede sostener ahora, parar es la respuesta correcta (sub-rule fatigue). |
| "El user pide rapidez, comprometo calidad por velocidad" | NO. El flujo prioriza calidad sobre velocidad por contrato firmado. Si hay tensión entre las dos, avisar al user con la sub-rule fatigue · NO decidir solo entregar mediocre. |

## Red flags

- 🚩 Estás por entregar código con TODO o console.log olvidado.
- 🚩 Encontraste copy-paste en el diff y lo dejaste "porque andaba".
- 🚩 La acción se siente "apurada" o "hasta acá llego" — disparador inmediato de fatigue self-evaluation.
- 🚩 Asimetría entre módulos hermanos detectada y NO mencionada al user (ej: `softDeleteX` ≠ `softDeleteY`).
- 🚩 Hardcode de UUID/slug/shortcode en spec sin fixture o helper.

## Verification

- [ ] Diff revisado antes del commit · cada línea defiende su derecho a existir.
- [ ] Cero hardcode (constantes nombradas · fixtures explícitas · strings centralizados).
- [ ] Cero copy-paste (helper extraído o WHY documentado para excepción).
- [ ] Cero código basura (TODOs vacíos · console.log · variables sin uso).
- [ ] Simetría con módulos hermanos verificada cuando aplica.
- [ ] Si la acción se sintió apurada → sub-rule fatigue aplicada (aviso al user · NO entrega silenciosa).

**Cross-reference firme:**

- Sub-rule operativa: [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) (cuando este estándar no se puede sostener).
- Hermana operativa: [`conversation-style.md`](./conversation-style.md) (preferencia de comunicación · brevedad y claridad por default).
- Hermana operativa: [`agents-conditional-by-domain.md`](./agents-conditional-by-domain.md) (regla #35 · 6 puntos del estándar aplicados al banner top + Pre-condition check de los agentes domain-tight · cero hardcode divergente · uniformidad contractual del texto entre los 3 agentes · solo varían `<flag>` y `<descripción>`).
- Refuerza: [`surgical-changes.md`](./surgical-changes.md) · [`regression-first-on-fix.md`](./regression-first-on-fix.md) · [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md).
- Invocada por: [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) para los 6 puntos sin duplicar.
