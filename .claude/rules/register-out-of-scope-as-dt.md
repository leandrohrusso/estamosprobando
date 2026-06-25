---
name: register-out-of-scope-as-dt
description: Todo bug · problema · asimetría · gotcha · gap · dead code · comportamiento inesperado detectado fuera del scope del PRP/tarea/sesión en curso → fila en `docs/logs/technical-debt.md` en el acto · sin esperar al cierre · sin esperar a confirmación · cero excepción. Definición canónica · centraliza la obligación que antes vivía distribuida en 3 reglas hermanas.
type: rule
applies-to: cualquier descubrimiento fuera del scope durante cualquier modo (A/B/C) · cualquier fase del Modo C · cualquier acción del agente o aviso del user
---

## Overview

> **Si el agente o el user detecta un bug · problema · asimetría · gotcha · gap · dead code · comportamiento inesperado FUERA del scope del PRP/tarea/sesión en curso · y se decide NO fixearlo ahora (para no dispersar el scope actual) · es OBLIGATORIO registrarlo en `docs/logs/technical-debt.md` EN EL ACTO** · con la información mínima contractual · sin esperar al cierre · sin esperar a confirmación · sin posponerlo "para después".

**Por qué firme:** sin esta regla los hallazgos out-of-scope mueren con la sesión · la memoria del LLM **NO** persiste entre sesiones · solo `docs/logs/technical-debt.md` lo hace. "Lo anoto al cierre" es anti-pattern: al cierre se pierden detalles del síntoma · si la sesión se agota mid-flight la deuda nunca llega.

**Origen:** codificada en sesión upstream como satélite dedicado · centraliza obligación que antes vivía distribuida en 3 hermanas ([`always-fix-all-bugs.md`](./always-fix-all-bugs.md) § Excepciones · [`regression-first-on-fix.md`](./regression-first-on-fix.md) regla operativa 1 · [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) ítem 4.6.a). Firma user: *"Si, hacelo prolijo, si la nueva regla explica bien, tal vez las 3 piezas actuales puedan/deban referenciar a la nueva regla"*.

## When

**Aplica a (universal · cero excepción):**

- **Cualquier modo** del flujo (Modo A trivial · Modo B skill cerrado · Modo C PRP del producto · trabajo del refactor · cualquier otra sesión).
- **Cualquier fase** del Modo C (Contexto · Planificación · Implementación · Revisión · Verificación · Entrega).
- **Cualquier tipo de descubrimiento out-of-scope:** bug funcional · race condition · gap de cobertura · asimetría entre módulos hermanos · gotcha latente · dead code · comportamiento inesperado · comentario stale que afirma algo falso · regla de gobierno desincronizada con el código real · etc.
- **Cualquier actor que detecta:** agente durante codeo/análisis/lectura · agente durante `/revisar` o `/validar` o `/ultrareview` · user al revisar diff o pantalla · reporte externo.

**Disparador binario (cuándo se activa la obligación · momento exacto):**

El primer momento donde se cumplen las dos condiciones simultáneamente:

- **(1)** Se detectó algo que merece atención (bug · gap · gotcha · etc).
- **(2)** Se decide NO fixearlo ahora (porque está fuera del scope del PRP/tarea/sesión actual · porque requiere otro stack/feature/contexto · porque arreglarlo ahora dispersaría el foco).

Si (1) **Y** (2) se cumplen → **DT en el acto · inmediato · antes de continuar con cualquier otra acción**.

Si (1) se cumple pero (2) NO (porque el bug ESTÁ dentro del scope o se puede fixear quirúrgicamente sin dispersar) → aplica regla hermana [`always-fix-all-bugs.md`](./always-fix-all-bugs.md): fixear ahora con calidad senior + regression-first FIRME. NO DT.

**NO aplica a:**

- Tareas mecánicas triviales del propio scope (rename · adopciones livianas) — no son "out of scope", son la tarea misma.
- Bugs del scope del PRP en curso → fixear ahora ([`always-fix-all-bugs.md`](./always-fix-all-bugs.md)).
- Bugs detectados durante `/validar` que pertenecen al PRP actual → fila al CSV + fix ([`regression-first-on-fix.md`](./regression-first-on-fix.md) regla 1 caso (a)).
- Observaciones cosméticas sin impacto real (typo en comment irrelevante · espacio extra · etc) — esos NO disparan DT · paridad regla [`simplicity-first.md`](./simplicity-first.md) "menos es más".

## Process

### Procedimiento canónico (4 pasos · obligatorios en orden)

#### Paso 1 · Decisión binaria fixear-ahora vs DT

Auto-pregunta al detectar el hallazgo: *"¿esto está dentro del scope del PRP/tarea/sesión actual y puedo fixearlo quirúrgicamente sin dispersar?"*.

- **SÍ → fixear ahora** (con calidad senior + regression-first FIRME · regla hermana [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) + [`regression-first-on-fix.md`](./regression-first-on-fix.md)).
- **NO → DT en el acto** (continuar paso 2).

**Criterio firme para "está fuera de scope":** alguna de estas condiciones se cumple:

1. El bug pertenece a un feature/stack/módulo distinto del que toca el PRP/tarea actual.
2. Arreglarlo requiere decisiones de diseño que el PRP/tarea actual no firmó.
3. Arreglarlo expande el diff más allá de lo trazable al request actual (paridad regla [`surgical-changes.md`](./surgical-changes.md)).
4. Hay un disparador objetivo para diferirlo (ej: depende de feature futura · depende de migración a servicio externo real no integrado aún · depende de PRP que aún no arrancó).

**Criterio firme para "está DENTRO de scope · fixear ahora":** ninguna de las 4 condiciones anteriores se cumple Y el bug está en archivos/áreas que el PRP/tarea actual ya está tocando.

#### Paso 2 · Agregar fila en `docs/logs/technical-debt.md` en el acto

**Antes de continuar con cualquier otra acción**, abrir `docs/logs/technical-debt.md` y agregar fila nueva. La fila lleva la información mínima contractual:

| Campo | Contenido obligatorio |
|---|---|
| **ID** | `DT-NNN` autoincremental (siguiente disponible · NO reusar IDs de DTs resueltas) |
| **Síntoma** | 1-2 frases describiendo qué pasa observable (NO root cause · eso va en notas) |
| **Archivo / área afectada** | Path concreto o tabla/feature/módulo (lo más específico posible · NO "el sistema") |
| **PRP destino tentativo** | "PRP-XXX" si ya hay candidato · "ad-hoc futuro" si no · "mini-PRP separado" si es trabajo de infra puro |
| **Severidad estimada** | `critical` · `normal` · `nit` (paridad con severidad de `/revisar` y `/ultrareview`) |
| **Mitigación temporal aplicada hoy** | "ninguna" si no aplica · o descripción 1-frase de qué workaround se puso en su lugar mientras tanto |
| **Disparador para cerrar** | Condición objetiva que activa el cierre (ej: "al integrar el servicio externo real" · "al refactorear módulo X" · "cuando llegue PRP-NNN") |
| **Detectada en sesión / commit** | Commit hash si aplica · o referencia a la sesión donde se detectó |

#### Paso 3 · Opcional · sumar memoria persistente si corresponde

Si la DT incluye un patrón replicable (gotcha · anti-pattern · convención violada · etc) que tiene valor para futuras sesiones más allá del fix puntual → agregar memoria nueva en `.claude/memory/feedback/` o `reference/` + entrada en `MEMORY.md` (regla hermana [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) ítem 4 · cero excepción).

Si la DT es solo un bug puntual sin patrón replicable → solo la fila en `technical-debt.md` alcanza.

#### Paso 4 · Continuar con el scope original sin desviarse

Una vez la fila DT está agregada, **retomar inmediatamente el scope original** que se estaba trabajando. NO arrastrar contexto del hallazgo out-of-scope al resto de la sesión. La DT preserva el contexto · vos volvés al foco original.

### Cómo distinguir DT genuina vs drive-by encubierto

| Caso | Acción correcta |
|---|---|
| Bug en servicio externo no integrado aún mientras estoy en modo simulado local | DT (fuera de scope técnico genuino · disparador "al integrar el servicio externo real") |
| Asimetría detectada entre `softDeleteX` y `softDeleteY` mientras estoy tocando `softDeleteX` | Si el PRP actual ya tocaría `softDeleteY` por simetría con scope original → fixear ahora. Si NO, DT (con disparador "próximo PRP que toque módulo Y") |
| Dead code en archivo que estoy modificando | Si tu cambio lo dejó huérfano → removerlo (regla [`surgical-changes.md`](./surgical-changes.md) "limpia tu propio mess"). Si es código ajeno preexistente → DT (NO removerlo en el mismo diff "ya que estás" · ese es drive-by encubierto) |
| Bug en módulo del PRP actual que detectaste mid-fase | Fixear ahora ([`always-fix-all-bugs.md`](./always-fix-all-bugs.md)) · NO DT |
| Bug en módulo hermano que detectaste de paso · NO está en scope | DT inmediato · NO "ya que estaba lo arreglo" |
| Race condition latente en helper que no estás tocando | DT (riesgo real · pero arreglarlo requiere análisis de concurrencia que el PRP actual no firmó) |

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · lo anoto mental y al cierre lo paso a DT" | NO. "Lo anoto mental" es exactamente cómo se pierde. Al cierre el contexto se diluye, los detalles del síntoma se pierden, y si la sesión se agota mid-flight la deuda nunca llega. **DT en el acto · cero excepción**. Costo: ~2 min · costo de no hacerlo: bug en producción en N meses sin contexto de cuándo se detectó originalmente. |
| "Voy a fixearlo igual aunque sea out-of-scope · no hace falta DT" | NO. Si lo fixeás igual aunque sea out-of-scope, estás haciendo **drive-by refactoring** que la regla hermana [`surgical-changes.md`](./surgical-changes.md) prohíbe firmemente. La decisión correcta es: O bien (a) negociar con el user que entre al scope actual (regla [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md)) y entonces fixear con regression-first · O bien (b) DT en el acto y NO tocarlo ahora. NO existe (c) "fixear silenciosamente sin avisar". |
| "Es solo cosmético · no merece DT" | Verificá criterio firme: ¿afecta comportamiento observable · UX · seguridad · multi-tenancy · datos · performance? Si SÍ → DT (no es cosmético). Si genuinamente NO → no DT (no es deuda · es preferencia). El umbral firme: si en N meses sin atención esto puede generar bug · DT. Si nunca puede generar bug · no DT. |
| "Lo paso a memoria en `feedback/` directo y skipeo la DT" | NO. `feedback/` codifica patrones replicables · `docs/logs/technical-debt.md` codifica deudas accionables con disparador y PRP destino. Son canales distintos · complementarios. Si la deuda incluye un patrón replicable, **ambas** se actualizan (DT + memoria · ver paso 3 del Process). |
| "El user no me pidió que abra DT por esto · skipeo" | NO. La obligación es estructural · cero excepción · NO depende de que el user lo pida. La regla es contractual: si detectaste algo out-of-scope que merece atención y decidiste no fixear ahora → DT inmediato. El user confía en que el agente registra deudas sin recordárselo. |
| "Lo anoté en el commit message · alcanza" | NO. El commit message NO es DT trackeable. Los commits se desindexan rápido · nadie hace `git log --grep="TODO"` periódicamente. `docs/logs/technical-debt.md` es el canal único y oficial · estructurado · revisado en cada cierre de PRP. |
| "Es trivial · el próximo PRP lo va a tocar igual" | NO. "El próximo PRP" puede ser dentro de 6 meses y el agente que lo agarre NO va a saber que existía esta deuda. La DT con disparador objetivo garantiza que cuando el próximo PRP toque el área, va a ver la fila y va a cerrarla. Sin DT, queda invisible. |

## Red flags

- 🚩 Detectaste un bug fuera del scope durante la sesión y NO abriste fila en `docs/logs/technical-debt.md` en el mismo turno.
- 🚩 Tu commit incluye fix de algo que NO estaba pedido (drive-by) y NO hay DT abierta para registrar el hallazgo originalmente.
- 🚩 Tu plan es "lo anoto en el cierre" en lugar de "DT en el acto" — exactamente el anti-pattern que esta regla previene.
- 🚩 La fila DT que abriste falta uno de los 8 campos obligatorios (ID · síntoma · archivo · PRP destino · severidad · mitigación · disparador · sesión).
- 🚩 Detectaste un patrón replicable junto con la deuda y NO sumaste memoria persistente en `feedback/` (paso 3 del Process omitido).
- 🚩 La DT que abriste dice "PRP destino: ver luego" o "severidad: por definir" — campos obligatorios deben tener valor concreto al momento de abrir · si no se sabe, mínimo "ad-hoc futuro" o "normal" estimado · refinar si llega más info.
- 🚩 Estás por arrancar otro trabajo (siguiente fase · siguiente sub-tarea) sin haber abierto DT por el hallazgo out-of-scope que detectaste minutos antes.

## Verification

- [ ] Al detectar hallazgo out-of-scope, paso 1 (decisión binaria fixear-ahora vs DT) ejecutado con criterio firme.
- [ ] Si decisión fue DT, paso 2 (fila en `docs/logs/technical-debt.md`) ejecutado **antes de continuar con cualquier otra acción** (no al cierre · no en N minutos · ahora).
- [ ] Fila DT tiene los 8 campos obligatorios completos: ID · síntoma · archivo/área · PRP destino tentativo · severidad · mitigación temporal · disparador para cerrar · sesión/commit de detección.
- [ ] Si la deuda incluye patrón replicable, paso 3 (memoria persistente en `feedback/` o `reference/` + MEMORY.md) ejecutado en el mismo turno.
- [ ] Después de abrir DT, paso 4 (retomar scope original sin arrastrar contexto del hallazgo) cumplido.
- [ ] Cero hallazgos out-of-scope sin DT al cierre de la sesión (verificable: revisar log mental de "qué vi de paso" vs `docs/logs/technical-debt.md` filas nuevas).
- [ ] Cero drive-by encubierto: si el commit toca algo fuera del scope original, hay DT que registra el hallazgo originalmente.

**Cross-reference firme:**

- Hermana operativa: [`always-fix-all-bugs.md`](./always-fix-all-bugs.md) (todo bug se fixea siempre · esta regla codifica la **única** excepción operativa: bug out-of-scope → DT en el acto · NO se difiere el fix · se difiere a otro PRP/contexto con trazabilidad).
- Hermana operativa: [`regression-first-on-fix.md`](./regression-first-on-fix.md) regla operativa 1 (caso (a) bug dentro del scope → CSV + fix · caso (b) bug fuera del scope → esta regla).
- Hermana operativa: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) ítem 4.6.a (verificación al cierre · esta regla es la **fuente** del "inmediatamente" que la golden rule verifica).
- Hermana operativa: [`surgical-changes.md`](./surgical-changes.md) (cero drive-by · si encontraste algo fuera del scope, DT es la salida correcta · NO "ya que estoy" en silencio).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye documentar deudas detectadas · cero atajos).
- Refuerza: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (si dudás si el hallazgo entra al scope actual o es out-of-scope · preguntar al user · NO improvisar).
- Refuerza: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (cero suposición sobre si "alguien más lo va a registrar" · la obligación es estructural del agente que detecta).
- Skill operativo audit: [`/auditar-dt`](../skills/auditar-dt/SKILL.md) (audit read-only de DTs activas en `docs/logs/technical-debt.md` · clasifica en 3 baldes urgentes/latentes/obsoletas + emite recomendación accionable · cero side effects · cierra el loop de la regla auditando periódicamente las DTs que esta regla obliga a abrir en el acto · paridad arquitectónica regla↔skill firmada en bloque doctrine↔execution upstream).

---

*Regla #24 codificada en sesión upstream con firma 🔵 user *"Si, hacelo prolijo, si la nueva regla explica bien, tal vez las 3 piezas actuales puedan/deban referenciar a la nueva regla"*. Centraliza obligación que vivía distribuida en 3 hermanas · las 3 ahora referencian a esta como fuente canónica.*
