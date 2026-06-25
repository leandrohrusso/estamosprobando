---
name: Respeto a la estructura actual · sesgo anti-creación de carpetas
description: La estructura de carpetas actual del repo es la baseline · cero creación de carpeta nueva sin justificación + aprobación previa explícita del user + verificación exhaustiva de que NO existe carpeta ya creada que cumpla el rol. Sesgo FUERTE anti-creación en raíz · default = subcarpeta dentro de carpeta existente cuando creación es genuina. Reusar carpeta existente NO es licencia para dumping · el archivo debe encajar semánticamente con el rol declarado de esa carpeta. Estándar rector: ordenado · prolijo · profesional. Complementa la regla #22 (folder-creation-with-readme · proceso de creación) con la política de cuándo crear.
type: rule
applies-to: cualquier intento de crear carpeta o subcarpeta nueva en cualquier path del repo · cualquier modo (A/B/C) · cualquier fase · cualquier sesión
---

## Overview

> **La estructura de carpetas actual del repo es la baseline operativa.** Cero creación de carpeta nueva sin (1) justificación explícita · (2) aprobación previa del user · (3) verificación exhaustiva de que NO existe carpeta ya creada que cumpla el rol. Sesgo FUERTE anti-creación en raíz · default = subcarpeta dentro de carpeta existente · NUNCA carpeta nueva top-level salvo último recurso. Reusar carpeta existente NO es licencia para dumping · el archivo debe encajar semánticamente con el rol declarado de esa carpeta. Estándar rector: **ordenado · prolijo · profesional**.

**Por qué firme:** sin política default "NO crear", el repo acumula carpetas tipo `tests/stuff/` · `scripts/utils/` · `docs/misc/` que nadie sabe por qué existen 6 meses después · asimetría indistinguible de caos. La regla #22 [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) codifica el **proceso** de creación (validación duplicados + firma user + README) · esta regla #23 codifica el paso anterior: **la política de cuándo se crea**. Cada creación es costo arquitectónico que se paga con orden a futuro.

**Origen:** codificada en sesión upstream por firma textual del user: *"quiero que se respete la estructura actual de carpetas... no quiero que se creen carpetas nuevas, en caso de crearse, tiene que justificarse y tengo que previamente aprobarlo yo... prohibido 'meter cualquier archivo en cualquier carpeta'... evitar carpetas en raíz · usar subcarpetas dentro de existentes... orden claro · prolijo · profesional"* (cita textual completa preservada en git history del commit de codificación).

**Hermana operativa:** [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (regla #22). Orden operativo: primero esta #23 cierra **¿se crea?** · si SÍ, #22 cubre **cómo se crea** (README + firma). Las 2 son complementarias · cero solapamiento.

## When

**Aplica a (universal · cero excepciones):**

- **Cualquier intento** de crear carpeta o subcarpeta nueva en CUALQUIER path del repo (`src/` · `tests/` · `db/` · `scripts/` · `docs/` · `.claude/` · raíz · etc).
- **Cualquier herramienta** que materialice creación (`mkdir` · `Write` con path que incluya carpeta inexistente · `git mv` a destino nuevo · creación implícita al escribir archivo).
- **Cualquier modo** del flujo (Modo A · Modo B · Modo C) y **cualquier fase** del Modo C.
- **Cualquier momento** donde el agente tenga que decidir dónde alojar un archivo nuevo (decisión de placement · NO solo creación explícita).

**Disparadores binarios (cuándo se activa la auto-pregunta firme · momento exacto):**

- **(D1) Voy a crear archivo nuevo** y su path natural NO existe todavía como carpeta → auto-preguntarse: *"¿qué carpeta existente puede alojar esto?"*.
- **(D2) Voy a proponerle al user crear carpeta nueva** → auto-preguntarse: *"¿agoté la búsqueda de carpeta existente que ya cumpla este rol?"*.
- **(D3) Voy a mover/renombrar archivo a path destino que NO existe** → auto-preguntarse: *"¿hay carpeta existente que ya pueda recibirlo?"*.
- **(D4) Voy a escribir contenido en path que el sistema va a auto-crear** (ej: `Write` a `docs/nueva-categoria/archivo.md` donde `docs/nueva-categoria/` no existe) → la creación implícita cuenta exactamente igual que `mkdir` explícito · auto-preguntarse: *"¿es genuinamente nueva esta categoría?"*.

**NO aplica a:**

- Carpetas auto-generadas por herramientas externas (`node_modules/` · `.next/` · `dist/` · `test-results/` · `.git/`).
- Carpetas creadas por scripts del propio proyecto en runtime ya documentados (ejs: `tests/manual/` carpeta padre + `tests/manual/screenshots/PRP-NNN/` sub-carpeta · ambas las crea `/validar` automáticamente · documentado en SKILL del proceso · paridad excepción simétrica padre↔sub-carpeta).
- Escribir archivos nuevos en carpetas que **ya existen** y cuyo rol declarado en `README.md` cubre semánticamente el archivo (eso NO es creación de carpeta · es uso normal · paridad regla #22 § "Lectura/consulta antes de actuar").

## Process

### Procedimiento canónico (5 pasos · obligatorios en orden)

**Vista de pájaro:**

| Paso | Acción | Criterio de salida |
|---|---|---|
| **1 · Inventario** | Listar candidatas existentes + leer su `README.md` (paridad regla #22 § "Lectura/consulta antes de actuar") · evaluar si alguna cubre el rol semánticamente | Si alguna cubre → usar esa · cero creación · saltar al paso 5 |
| **2 · Padre razonable** | Si ninguna cubre · buscar carpeta padre para subcarpeta nueva (`tests/` · `docs/` · `.claude/` · `db/` · `scripts/` · etc) | Default fuerte = subcarpeta dentro del padre · top-level solo último recurso |
| **3 · Justificación al user** | Presentar análisis A/B/C con recomendación early según formato canónico abajo | Esperar OK explícito (silencio NO es OK) |

#### Paso 1 · Inventario exhaustivo

Identificar el contenido (archivo · tipo · rol funcional) y listar **todas** las carpetas existentes que podrían razonablemente alojarlo. Candidatas típicas por dominio: smoke tests → `tests/scripts/` · documentación → `docs/` y subcarpetas · memoria persistente → `.claude/memory/feedback|reference|project/` · reglas firmes → `.claude/rules/` · specs E2E → `tests/e2e/regression/` · migraciones → `db/migrations/` · seeds → `db/seeds/prod|test/`. Leer el `README.md` de cada candidata y evaluar: *¿el rol declarado cubre semánticamente el archivo nuevo?* Si SÍ → usar esa · cero creación · saltar al paso 5. Si ninguna cubre → paso 2.

#### Paso 2 · Búsqueda de carpeta padre razonable (preferencia FUERTE sobre raíz)

Identificar el **dominio funcional** del contenido y listar carpetas top-level que correspondan. Para la más apropiada evaluar: *¿tiene sentido subcarpeta nueva dentro de esta?* **Default fuerte = SÍ** · subcarpeta dentro de padre razonable. Solo si genuinamente NO hay padre razonable (contenido transversal · nuevo dominio funcional completo) → escalar al paso 3 con propuesta top-level.

#### Paso 3 · Justificación al user + recomendación early

Presentar análisis al user con formato canónico (paridad regla [`metodologia-iteracion.md`](./metodologia-iteracion.md)):

```markdown
Necesito decidir dónde alojar: <contenido · 1-2 líneas>

**Carpetas existentes evaluadas (Paso 1):**
- `<candidata-1>` — <descartada porque...>
- `<candidata-2>` — <descartada porque...>
- ...

**Conclusión Paso 1:** ninguna carpeta existente cubre el rol semánticamente.

**Carpetas padre evaluadas (Paso 2):**
- `<padre-1>` — <evaluación de si tiene sentido subcarpeta dentro>
- `<padre-2>` — <ídem>

**Opciones:**

| Opción | Path propuesto | Tradeoff |
|---|---|---|
| **A (rec early)** | `<carpeta-padre-existente>/<subcarpeta-nueva>/` | Sesgo anti-raíz · respeta estructura · costo bajo |
| **B** | `<otra-padre>/<sub>/` | <tradeoff> |
| **C** (último recurso) | `<top-level-nuevo>/` | Carpeta nueva en raíz · costo arquitectónico mayor · solo si A y B no aplican |

**Mi rec: A** porque <razón 1-frase · típicamente "respeta sesgo anti-raíz + rol semántico claro dentro del padre">.

¿OK firmás A?
```

#### Paso 4 · Esperar OK explícito del user

- Cero creación silenciosa.
- Silencio NO es OK.
- Si el user firma A, B o C → aplicar regla #22 (proceso de creación con README + validación interna).
- Si el user objeta → re-evaluar con info nueva y volver al paso 3.

#### Paso 5 · Después de crear (handoff a regla #22)

Una vez firmado, el procedimiento de creación material (mkdir + README con 3 secciones obligatorias + commit) lo cubre regla #22 §  Process. Esta regla #23 termina su rol cuando la decisión "¿se crea?" quedó firmada.

### Anti-dumping (R7 · clarificación firme · NO licencia)

> **Reusar carpeta existente NO es licencia para "meter cualquier archivo en cualquier carpeta".** Si la carpeta candidata existe pero su rol declarado en `README.md` NO cubre semánticamente el archivo, la respuesta correcta NO es meterlo igual ni crear carpeta nueva sin pensar · es **replantear dónde va con criterio**.

**Cómo distinguir "uso correcto de carpeta existente" vs "dumping encubierto":**

| Caso | Acción correcta |
|---|---|
| Archivo encaja semánticamente con rol declarado de la carpeta candidata | ✅ Usar carpeta existente. Cero creación. |
| Archivo NO encaja semánticamente · pero hay otra carpeta que SÍ encaja | ✅ Usar la otra carpeta. NO dumping en la primera. |
| Archivo NO encaja en ninguna · pero hay carpeta padre razonable para subcarpeta nueva | ✅ Proponer subcarpeta dentro del padre (Paso 2 + Paso 3). |
| Archivo NO encaja en ninguna · NO hay padre razonable · es contenido top-level genuino | ⚠️ Último recurso: proponer carpeta nueva en raíz con justificación FUERTE. |
| Archivo NO encaja claramente pero "meto igual donde más o menos pega para no tener que preguntar" | ❌ Dumping encubierto. Prohibido. Pausar y preguntar al user. |

**Red flag interno (auto-chequeo):** si te decís *"meto este archivo acá aunque no encaja del todo, así evito proponer carpeta nueva"* → estás haciendo dumping encubierto · pausá y aplicá Paso 3 con la propuesta real.

### Sesgo anti-raíz (R5 · jerarquía de costo)

| Decisión | Costo arquitectónico | Cuándo usar |
|---|---|---|
| **Usar carpeta existente** | 🟢 Cero | Default · primer recurso |
| **Subcarpeta dentro de carpeta existente** | 🟡 Bajo | Cuando ninguna existente cubre rol · padre razonable disponible |
| **Carpeta nueva top-level (raíz)** | 🔴 Alto | Último recurso · solo si ninguna padre razonable existe · justificación FUERTE + firma user explícita |

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · creo la carpeta y le aviso al user después" | NO. La regla es upfront + firma explícita user · cero "después". Crear silenciosamente · aunque la carpeta parezca razonable · rompe el contrato de "estructura actual = baseline" y normaliza la creación sin control. Costo de preguntar antes: 1 round-trip · costo de creación silenciosa: estructura caótica acumulativa. |
| "Esta carpeta nueva en raíz es claramente necesaria · ahorro el round-trip y la creo" | NO. La carpeta en raíz tiene costo arquitectónico 🔴 alto · firma explícita del user es contractual · cero excepción. Si es tan claramente necesaria, el round-trip al user es trivial · y la firma queda como precedente para futuras decisiones similares. |
| "Hay una carpeta que más o menos sirve · meto el archivo ahí para evitar crear nueva" | NO. Eso es dumping encubierto (R7). "Más o menos sirve" = no sirve. Si el archivo no encaja semánticamente con el rol declarado, la respuesta NO es forzar el match · es proponer subcarpeta nueva dentro de carpeta padre razonable con análisis al user. |
| "Las subcarpetas dentro de carpeta existente no necesitan firma · están cubiertas por la firma de la carpeta padre" | NO. Cada nivel se firma por separado (paridad regla #22). Carpeta padre firmada hoy NO autoriza subcarpetas nuevas mañana sin nueva firma. El costo de aprobación de subcarpeta es menor que carpeta en raíz · pero NO es cero. |
| "Sé que el user va a decir SÍ · creo la carpeta y le confirmo en el mensaje siguiente" | NO. "Sé que va a decir SÍ" es proyección · NO firma. El contrato es firma explícita ANTES · NO confirmación implícita DESPUÉS. Y si genuinamente va a decir SÍ, el round-trip cuesta segundos. |
| "El user me dio firma para crear carpeta X · ahora cuando aparezca otro caso similar lo extiendo solo" | NO. Cada caso se evalúa individualmente · firma para X NO es firma para "carpetas similares a X". Los criterios "similares" se borronean rápido y terminan en creación silenciosa. |
| "La estructura actual está mal · la reformo de paso" | NO. Drive-by refactoring estructural está prohibido (paridad regla [`surgical-changes.md`](./surgical-changes.md)). Si la estructura actual merece reforma, eso es PRP propio con scope + firma user · NO se mete dentro de una tarea cuyo request original era otra cosa. |
| "Voy a crear N subcarpetas dentro de carpeta padre firmada · es 1 sola decisión arquitectónica · ahorro N firmas con 1" | OK firmar el plan completo en un solo round-trip · NO ir creando 1 a 1 sin avisar. Pero el plan completo se presenta al user con las N subcarpetas listadas explícitamente · NO "voy creando las que vea necesarias". |

## Red flags

- 🚩 Vas a correr `mkdir` · `Write` con path que crea carpeta · `git mv` a destino nuevo · sin haber ejecutado Paso 1 (inventario de carpetas existentes que puedan alojar el contenido).
- 🚩 Tu propuesta de carpeta nueva en raíz NO incluyó Paso 2 (búsqueda de carpeta padre razonable para subcarpeta).
- 🚩 Tu commit incluye carpeta nueva sin firma user explícita en la conversación previa (silencio o "asumí que estaba OK").
- 🚩 Te decís internamente *"meto este archivo acá aunque no encaja del todo, así evito proponer carpeta nueva"* → dumping encubierto · disparador inmediato de pausa + Paso 3.
- 🚩 Tu propuesta de carpeta nueva top-level NO justificó por qué NO hay carpeta padre razonable para subcarpeta (Paso 2 saltado).
- 🚩 Sumaste subcarpeta nueva dentro de carpeta firmada sin nueva firma explícita ("ya estaba autorizado el padre").
- 🚩 La sesión paralela / otra rama tiene cambios estructurales (carpetas nuevas) y vos por inercia replicás el patrón sin firma propia.
- 🚩 Estás escribiendo archivo nuevo a `<path>/<nuevo-segment>/<archivo>` y `<path>/<nuevo-segment>/` no existe · NO frenaste para aplicar D4 (creación implícita = creación · cuenta igual).

## Verification

- [ ] Antes de cualquier creación de carpeta · Paso 1 (inventario exhaustivo de carpetas existentes que puedan alojar el contenido · con lectura de READMEs candidatos) ejecutado y documentado al user si la propuesta sube al paso 3.
- [ ] Si Paso 1 concluyó "ninguna cubre" · Paso 2 (búsqueda de carpeta padre razonable para subcarpeta) ejecutado con preferencia FUERTE sobre creación en raíz.
- [ ] Paso 3 (análisis presentado al user con A/B/C + recomendación early con justificación 1-frase + carpetas descartadas listadas) emitido cuando se necesita creación genuina.
- [ ] Paso 4 (OK explícito del user con firma de letra A/B/C) recibido antes de cualquier `mkdir` o creación implícita.
- [ ] Paso 5 (creación material + README) ejecutado siguiendo regla #22 una vez firmada la decisión.
- [ ] Cero creación silenciosa (verificable: cualquier carpeta nueva en `git status` tiene precedente conversacional con firma).
- [ ] Cero dumping encubierto: cada archivo nuevo en carpeta existente encaja semánticamente con el rol declarado en `README.md` de esa carpeta.
- [ ] Cero carpetas nuevas en raíz sin justificación FUERTE documentada de por qué NO había padre razonable.
- [ ] Sesgo anti-raíz aplicado: jerarquía de costo 🟢→🟡→🔴 respetada en cada decisión.

**Cross-reference firme:**

- Hermana operativa directa: [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) (regla #22 · proceso de creación cuando ya se decidió crear · esta regla #23 es la política previa de "¿se crea o no?"). Las 2 son complementarias · cero solapamiento.
- Hermana operativa: [`ante-duda-preguntar-user.md`](./ante-duda-preguntar-user.md) (cualquier ambigüedad sobre dónde alojar archivo · preguntar al user con formato canónico).
- Hermana operativa: [`no-suponer-fuente-de-verdad.md`](./no-suponer-fuente-de-verdad.md) (cero suposición sobre estructura · ir a fuente · listar carpetas reales + leer READMEs antes de proponer).
- Hermana operativa: [`surgical-changes.md`](./surgical-changes.md) (cero drive-by `mkdir` · cero reforma estructural sin scope propio).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (estándar senior incluye estructura prolija + profesional · cero acumulación caótica).
- Refuerza: [`simplicity-first.md`](./simplicity-first.md) (mínima estructura necesaria · cero abstracción organizacional especulativa).
- Refuerza: [`metodologia-iteracion.md`](./metodologia-iteracion.md) (formato canónico de presentación al user cuando se propone creación).

---

*Regla #23 codificada en sesión upstream con firma 🔵 user *"adelante. hazlo"* sobre 8 requisitos R1-R8 presentados. Complementa regla #22 (folder-creation-with-readme · proceso de creación) con la política previa de cuándo crear · sesgo FUERTE anti-creación + anti-raíz + anti-dumping · baseline = respetar estructura actual.*
