---
name: agents-conditional-by-domain
description: Sub-agentes domain-tight de skills multi-agente del pack (típicamente /revisar y /revisar-main) respetan un mecanismo de opt-in/opt-out vía config declarativo + banner condicional + early-exit clause. Cero false positives en proyectos donde el dominio no aplica · cero asunciones silenciosas del agente sobre la naturaleza del producto destino.
type: rule
applies-to: sub-agentes con scope condicional al dominio del proyecto (multi-tenancy · stock atomicity · BD relacional · etc) en skills multi-agente del pack. SKILL.md del skill multi-agente lee el config en Paso 0.6 + agente domain-tight lleva banner top + early-exit clause en § Process.
---

## Overview

> **Los sub-agentes domain-tight de skills multi-agente del pack (típicamente `/revisar` y `/revisar-main`) NO siempre aplican.** Un agente domain-tight asume condiciones del dominio (multi-tenancy estricto · stock atomicity · BD relacional con migrations · etc) que pueden o no cumplirse en el proyecto destino. Sin mecanismo de opt-in/opt-out, el agente corre igual en proyectos donde el dominio no aplica · emite false positives · ensucia el reporte del consolidator · degrada confianza del user en el skill.

**Por qué firme:** causa #1 de ruido en multi-agent reviews mal calibrados es que un sub-agente asume "stack/dominio X" cuando el proyecto destino es "stack/dominio Y" · busca patrones que no existen · si alucina reporta findings sobre algo que NO existe (ruido activo · user pierde tiempo verificando false positives). El mecanismo dual (config declarativo + banner + early-exit) atrapa la condición ANTES de ejecutar análisis.

**Origen:** codificada al detectar que los 3 sub-agentes domain-tight de `/revisar` y `/revisar-main` (`multi-tenant` · `atomicity` · `migration-safety`) corrían siempre sin opt-in/opt-out. Plan A (config) + Plan B (banner + early-exit) implementado en paralelo · firma 🔵 user (Bif 1=A `.claude/config/` · Bif 2=A 3 flags · Bif 3=A promover a regla firme).

**Hermana operativa:** [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (regla #22 · README obligatorio al crear `.claude/config/`) + [`simplicity-first.md`](./simplicity-first.md) (config arranca con scope mínimo · 3 flags · cero abstracción especulativa) + [`surgical-changes.md`](./surgical-changes.md) (cero modificación de agentes universales · scope quirúrgico).

## When

**Aplica a (universal · cero excepciones):**

- **Cualquier sub-agente del pack** cuyo scope dependa de una condición del dominio del proyecto (multi-tenancy · stock atomicity · BD relacional · webhooks · PDF rendering · etc).
- **Cualquier skill multi-agente** que spawnee N sub-agentes paralelos (típicamente `/revisar` · `/revisar-main` · futuros skills similares).
- **Bootstrap del proyecto destino** al adoptar el pack workflow-base.
- **Refactor de un skill multi-agente** que agregue/quite/modifique sub-agentes domain-tight.

**Disparadores binarios (cuándo se activa la obligación · momento exacto):**

- **(D1) Diseñás sub-agente nuevo** cuyo scope asume condición del dominio que NO todo proyecto cumple → el agente debe ser domain-tight + llevar banner + early-exit + el skill principal debe leer el config + el config debe tener flag para el agente.
- **(D2) Modificás sub-agente existente** y descubrís que su scope asume condición del dominio NO universal → re-clasificarlo como domain-tight + aplicar mecanismo.
- **(D3) Bootstrap del proyecto destino** al adoptar el pack → llenar `agents-applicability.yml` reemplazando `unknown` por `yes`/`no` en cada flag según los constraints declarados en `BUSINESS_LOGIC.md § 8`.

**Lo que NO requiere mecanismo (NO disparar):**

- Sub-agentes universales (`architect` · `security` · `tests` · `correctness` · `a11y`) que aplican a CUALQUIER proyecto · sin asunción del dominio.
- Sub-agentes amplios (`i18n`) que aplican a la mayoría de proyectos pero con scope adaptable inline (sin opt-out hard · solo adapta criterios).
- Tareas mecánicas triviales dentro de un skill (preflight bash · lectura de archivos · escritura de log) · ese código no es agente.

## Process

### Procedimiento canónico de adopción (4 piezas · obligatorias en conjunto)

#### Pieza 1 · Config declarativo en `.claude/config/agents-applicability.yml`

Centraliza los flags `enabled: yes/no/unknown` por sub-agente domain-tight. Estructura mínima:

```yaml
agents:
  <nombre-agente>:
    enabled: unknown   # yes / no / unknown (default al boot del pack)
    condition: "Proyecto declara <flag>: yes en BUSINESS_LOGIC.md § 8 Constraints"
    description: "<descripción 1-frase de la condición del dominio>"
```

- **Default al boot del pack:** todos los flags arrancan en `unknown` · forza decisión explícita del proyecto destino durante el bootstrap (cero defaults silenciosos).
- **3 valores válidos:** `yes` (activa) · `no` (desactiva) · `unknown` (forza firma user en cada invocación del skill).
- **Cero flag genérico** tipo `disabled_agents: [...]` que cubra todos los agentes · solo los domain-tight tienen flag · simplicity-first.

#### Pieza 2 · Extensión de `BUSINESS_LOGIC.md § 8` con sub-sección "Constraints del dominio que activan agentes"

El bootstrap del proyecto destino llena los flags acá con justificación 1-frase · `agents-applicability.yml` es la cara mecánica del flag · `BUSINESS_LOGIC.md § 8` es la cara humana con racional.

Patrón:

```markdown
### Constraints del dominio que activan sub-agentes de /revisar y /revisar-main

| Flag | Valor | Justificación 1-frase |
|---|---|---|
| `<flag-1>` | `<unknown / yes / no>` | `<por qué>` |
| `<flag-2>` | `<unknown / yes / no>` | `<por qué>` |
```

#### Pieza 3 · Paso de lectura del config en el SKILL del skill multi-agente

El SKILL.md del skill multi-agente (típicamente `/revisar/SKILL.md` y `/revisar-main/SKILL.md`) lleva un paso explícito ANTES del spawn de sub-agentes que:

1. Lee `.claude/config/agents-applicability.yml` con `Read`.
2. Parsea los flags de los agentes domain-tight.
3. Si algún flag está en `unknown` → emite aviso al user con formato canónico + esperar firma 🔵 user antes de spawnear (cero asumir default).
4. Construye lista de agentes a spawnear (universales siempre + domain-tight según flag).
5. Emite transparencia al user: *"Agentes a spawnear: N/M · habilitados: <lista> · skipeados: <lista>"*.

#### Pieza 4 · Banner top + early-exit clause en el archivo del agente domain-tight

Cada agente domain-tight lleva DOS componentes:

**(4a) Banner top inmediato post-`# Agent: <nombre>`** (blockquote callout):

> **Nota sobre paths del template:** los paths relativos del banner abajo (`../../../../BUSINESS_LOGIC.md` · `../../../config/agents-applicability.yml` · `../../../rules/agents-conditional-by-domain.md`) asumen que el agente vive en `.claude/skills/<skill>/agents/<nombre>.md`. Si el agente está en otra ubicación, ajustá los `../` para que los paths resuelvan correctamente desde su locale.

```markdown
> **⚠️ Domain-conditional agent.** Este agente aplica SOLO si el proyecto declara `<flag>: yes` en [`BUSINESS_LOGIC.md § 8 Constraints`](../../../../BUSINESS_LOGIC.md) + el flag está habilitado en [`.claude/config/agents-applicability.yml`](../../../config/agents-applicability.yml). Si tu proyecto NO cumple la condición → este agente devuelve `### No findings · agent skipped (proyecto declara <flag>: no)` directo en su output (cero análisis del diff · cero false positives).
>
> **Condición operativa:** `<descripción 1-frase de la condición del dominio>`.
>
> Doctrina canónica del mecanismo: [`agents-conditional-by-domain.md`](../../../rules/agents-conditional-by-domain.md).
```

**(4b) § Pre-condition check al INICIO del § Process del agente** (antes de análisis del diff/scope):

```markdown
## Pre-condition check (ejecutar SIEMPRE primero · antes de analizar el diff/scope)

1. Leé `.claude/config/agents-applicability.yml` con `Read`.
2. Buscá el flag `<nombre-agente>.enabled`:
   - Si `enabled: no` → emitir output exacto: `### No findings · agent skipped (proyecto declara <flag>: no)` y terminar. Cero análisis del diff. Cero emisión de findings. Cero costo de procesamiento.
   - Si `enabled: unknown` → emitir output exacto: `### No findings · agent skipped (proyecto NO declaró <flag> en BUSINESS_LOGIC.md § 8 + config · necesita firma user antes de habilitar)` y terminar.
   - Si `enabled: yes` → continuar con análisis normal del diff/scope (resto del § Process abajo).
3. Backup defensivo: si el archivo `agents-applicability.yml` NO existe o no es parseable → emitir `### No findings · agent skipped (config no disponible)` y terminar. Cero abortar ruidosamente · cero análisis silencioso de fallback.
```

### Cómo aplicar el mecanismo paso a paso al adoptar el pack

1. **Bootstrap del proyecto destino lee `BUSINESS_LOGIC.md § 8`** y decide cada flag (`yes` / `no`) según los constraints del producto.
2. **Edita `.claude/config/agents-applicability.yml`** reemplazando `unknown` por el valor decidido en cada flag de agente.
3. **Documenta la decisión inline** en la tabla de § 8 con justificación 1-frase.
4. **Verifica:** invocar `/revisar` o `/revisar-main` debe emitir transparencia *"Agentes a spawnear: N/M · habilitados: <lista> · skipeados: <lista>"* sin pedir firma user (cero flag en `unknown`).

### Cómo agregar agente domain-tight nuevo al pack (futuro)

1. **Diseñar agente** con § Role + § Input + § Read these references + § Verification checklist + § Output format (paridad shape de agentes existentes).
2. **Agregar flag al config:** sumar entry en `.claude/config/agents-applicability.yml § agents` con `enabled: unknown` + `condition` + `description`.
3. **Agregar banner + early-exit clause al archivo del agente** (Piezas 4a + 4b arriba).
4. **Agregar fila a `BUSINESS_LOGIC.md § 8`** sub-sección "Constraints del dominio que activan agentes" con el nuevo flag.
5. **Sumar el agente a la lista canónica del SKILL multi-agente** (typically `/revisar/SKILL.md § Paso 2` y `/revisar-main/SKILL.md § Paso 2`).
6. **Actualizar `.claude/config/README.md`** si el config introduce categoría nueva de flag (típicamente NO requiere update).

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "El agente domain-tight ya devuelve `### No findings` cuando no hay nada · no hace falta early-exit" | NO. La diferencia es contractual: "no findings" después de análisis = el agente leyó el diff completo, gastó tokens, evaluó criterios, no encontró nada (válido). "No findings · agent skipped" = el agente NUNCA analizó el diff porque el proyecto declaró `no` (no aplica). El primero cuesta tokens · el segundo no. El primero puede emitir false positives · el segundo no. Doctrina sin ambigüedad. |
| "Si el config tiene `unknown` improviso con default `yes` para no frenar el flujo" | NO. `unknown` es disparador de firma user explícita · cero default silencioso. El user firma `yes` o `no` y queda en `agents-applicability.yml` para futuras invocaciones · el config se vuelve `yes`/`no` post-firma. Default `yes` silencioso = exactly el anti-pattern que la regla atrapa. |
| "Agrego flag genérico `disabled_agents: [list]` y el user mete cualquier agente · más flexible" | NO. Bif 2 = A firmada: scope mínimo viable · solo los 3 agentes domain-tight tienen flag. Flag genérico catch-all rompe el contrato del mecanismo · agentes universales no se deshabilitan (correrían igual sobre cualquier proyecto · valor universal). |
| "El banner del agente lo escribo diferente para cada uno · está bien que tenga personalidad" | NO. Regla #8 [`quality-standard-senior.md`](./quality-standard-senior.md): cero hardcode divergente · texto canónico uniforme entre los agentes domain-tight · solo varían `<flag>` y `<descripción>`. Personalidad es ruido · uniformidad es contractual. |
| "Bypaseo el early-exit del agente porque sé que el user va a querer el análisis igual" | NO. El early-exit es contractual · cero excepción del agente. Si el user quiere el análisis aunque el flag esté en `no`, debe firmar cambio del flag a `yes` en `agents-applicability.yml` antes de invocar `/revisar` o `/revisar-main`. Bypassear el early-exit en el agente rompe el contrato del mecanismo. |
| "El config no existe en el proyecto destino · improviso default `yes` para todos los agentes" | NO. Backup defensivo de Pieza 4b: si el config NO existe o no es parseable, el agente devuelve `### No findings · agent skipped (config no disponible)` y termina. Cero análisis silencioso de fallback. Improvisar `yes` sin firma user destruye la red defensiva. |
| "Modifico un agente universal (architect/security/tests/correctness/a11y) para que también lea el config · uniformidad" | NO. Regla #11 [`surgical-changes.md`](./surgical-changes.md): cero drive-by. Los agentes universales NO necesitan flag (siempre corren por contrato del mecanismo · valor universal). Agregarles lectura del config es código muerto + riesgo de bug latente si el config rompe. |

## Red flags

- 🚩 Sub-agente nuevo del pack asume condición del dominio (multi-tenancy · stock atomicity · BD relacional · webhooks · etc) y NO tiene banner top + early-exit clause + flag en `.claude/config/agents-applicability.yml`.
- 🚩 SKILL.md del skill multi-agente spawnea agentes sin haber leído `agents-applicability.yml` en un paso explícito previo (Paso 0.6 o equivalente).
- 🚩 Agente domain-tight con flag en `unknown` y el skill principal lo spawneó igual sin firma user.
- 🚩 Texto del banner top diverge entre los agentes domain-tight (cero uniformidad · violación regla #8).
- 🚩 Early-exit clause omite alguno de los 3 casos (`no` · `unknown` · backup defensivo "config no disponible") · matriz incompleta.
- 🚩 Bootstrap del proyecto destino llenó `agents-applicability.yml` con `yes`/`no` PERO `BUSINESS_LOGIC.md § 8` sigue con `unknown` (canales desincronizados · doctrina rota).
- 🚩 Agente universal modificado para leer el config "ya que estamos" (drive-by · agentes universales NO necesitan flag).
- 🚩 Flag nuevo agregado al config SIN sumar fila a `BUSINESS_LOGIC.md § 8` ni actualizar tabla de agentes del SKILL multi-agente.

## Verification

- [ ] **Pieza 1 (config) presente:** `.claude/config/agents-applicability.yml` existe con shape canónico (`agents:` + N entradas con `enabled` + `condition` + `description`).
- [ ] **Pieza 2 (BUSINESS_LOGIC.md § 8) extendida:** sub-sección "Constraints del dominio que activan sub-agentes" presente con tabla de flags + valores + justificación.
- [ ] **Pieza 3 (SKILL.md del skill multi-agente) modificada:** Paso 0.6 (o equivalente) explícito leyendo el config antes del spawn · lista de agentes a spawnear construida según flags · transparencia emitida al user.
- [ ] **Pieza 4a (banner top) presente** en CADA archivo de agente domain-tight inmediato post-`# Agent:` · texto canónico uniforme · solo varían `<flag>` y `<descripción>` por agente.
- [ ] **Pieza 4b (Pre-condition check) presente** al INICIO del § Process de CADA archivo de agente domain-tight · matriz `no`/`unknown`/backup defensivo completa.
- [ ] **Cero agente universal modificado** para leer el config (verificable con `git diff` sobre archivos de agentes universales · cero changes).
- [ ] **Cero default silencioso:** flag en `unknown` dispara firma user explícita · cero spawn automático con `unknown`.
- [ ] **Texto del banner uniforme** entre todos los agentes domain-tight (verificable con `diff` de las primeras N líneas post-`# Agent:` · solo varían `<flag>` y `<descripción>`).

**Cross-reference firme:**

- Hermana operativa: [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (regla #22 · `.claude/config/` carpeta nueva requiere README con shape canónico al crearla).
- Hermana operativa: [`simplicity-first.md`](./simplicity-first.md) (regla #12 · config arranca con scope mínimo · solo flags para agentes domain-tight existentes · cero abstracción especulativa).
- Hermana operativa: [`surgical-changes.md`](./surgical-changes.md) (regla #11 · cero modificación de agentes universales que no son domain-tight · scope quirúrgico del mecanismo).
- Hermana operativa: [`think-before-coding.md`](./think-before-coding.md) (regla #5 · al diseñar agente nuevo · listar asunciones del dominio · si una asunción NO es universal · el agente es domain-tight + aplica esta regla).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (regla #8 · 6 puntos del estándar · cero hardcode divergente en el banner · uniformidad contractual).
- Refuerza: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (regla #7 · el config + BUSINESS_LOGIC § 8 son las fuentes de verdad sobre aplicabilidad · cero asumir desde memoria del LLM).

**Sub-agentes y SKILLs que materializan este mecanismo (al boot del pack):**

| Pieza | Archivo / artefacto | Rol |
|---|---|---|
| 1 (config) | [`.claude/config/agents-applicability.yml`](../config/agents-applicability.yml) | Flags `enabled: yes/no/unknown` por sub-agente domain-tight · 3 flags actuales (`multi-tenant.enabled` · `atomicity.enabled` · `migration-safety.enabled`). |
| 1 (config doc) | [`.claude/config/README.md`](../config/README.md) | SoT documental del config · 3 secciones canónicas + cross-ref a esta regla. |
| 2 (BUSINESS_LOGIC § 8) | [`BUSINESS_LOGIC.md § 8 Constraints`](../../BUSINESS_LOGIC.md) | Cara humana con justificación 1-frase · sincronizada con valores del config. |
| 3 (SKILL ejecutor · diff vs main) | [`.claude/skills/revisar/SKILL.md § Paso 0.6`](../skills/revisar/SKILL.md) | Lectura config + parseá + branching `unknown` → firma user + transparencia · paso 4 del flujo del producto. |
| 3 (SKILL ejecutor · holístico) | [`.claude/skills/revisar-main/SKILL.md § Paso 0.4`](../skills/revisar-main/SKILL.md) | Paridad lógica con `/revisar` Paso 0.6 · numeración 0.4 justificada (Paso 0.5 planning intermedio). |
| 4a + 4b (agentes domain-tight · diff) | [`.claude/skills/revisar/agents/{multi-tenant,atomicity,migration-safety}.md`](../skills/revisar/agents/) | Banner top canónico + Pre-condition check con matriz 3-way + backup defensivo · backup defense in depth del SKILL Paso 0.6. |
| 4a + 4b (agentes domain-tight · holístico) | [`.claude/skills/revisar-main/agents/{multi-tenant,atomicity,migration-safety}.md`](../skills/revisar-main/agents/) | Copia adaptada al modo holístico · Bif 1 = A 🔵 user firmado · cero coupling con `/revisar/agents/`. |
| Smoke CI (Pieza 4 mecánica) | [`tests/scripts/infra-flujo/agents-domain-tight-have-precondition.sh`](../../tests/scripts/infra-flujo/agents-domain-tight-have-precondition.sh) | Invariante mecánico · valida banner uniforme + Pre-condition matriz 3-way en los 6 agentes · ABORT en job `lint` del CI (paridad `rules-shape-p8.sh`). |
| Hook commit-msg (Pieza 1 firma user) | [`.husky/commit-msg`](../../.husky/commit-msg) | Defense in depth · cambios staged a `agents-applicability.yml` exigen firma canónica (`🔵` · `firma user` · `firma 🔵`) en commit message. |

**Cómo agregar agente domain-tight nuevo al pack:** ver § Process "Cómo agregar agente domain-tight nuevo al pack (futuro)" arriba · 6 pasos contractuales · suma fila a esta tabla al cierre.

---

*Regla #35 codificada con firma 🔵 user sobre Bif 1 = A (ubicación `.claude/config/`) + Bif 2 = A (solo 3 flags · scope mínimo viable) + Bif 3 = A (promover a regla firme con shape P8). Formaliza el mecanismo dual (config opt-in/opt-out + banner condicional + early-exit clause) que evita false positives de sub-agentes domain-tight en proyectos donde el dominio no aplica. Paridad arquitectónica con regla #22 [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (carpeta `.claude/config/` nueva con README) + regla #12 [`simplicity-first.md`](./simplicity-first.md) (3 flags mínimos · cero abstracción especulativa).*
