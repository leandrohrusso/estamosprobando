---
name: session-handoff
description: Shape canónico + cuándo se genera un handoff entre sesiones cuando el agente cierra mid-trabajo (camino B de fatiga firmado · cierre de fase 🔴 punto-de-no-retorno · user invoca /handoff explícito · bloqueo inesperado). El archivo vive en `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` con 7 secciones obligatorias (frontmatter · intro blockquote · estado al cierre · qué falta · gotchas · re-onboarding · refs). Asegura continuidad multi-sesión sin pérdida de contexto operativo · paridad arquitectónica con regla #9 fatigue-self-evaluation ↔ skill /fatiga.
type: rule
applies-to: cualquier sesión donde se cierre trabajo mid-flight con continuidad esperada en sesión nueva
---

## Overview

> **Cuando una sesión cierra trabajo mid-flight con continuidad esperada (no se pudo terminar acá · vamos a retomar en sesión nueva), el agente genera un archivo handoff en `.claude/memory/project/` siguiendo el shape canónico de 7 secciones obligatorias.**

**Por qué firme:** sin shape canónico, cada handoff queda heterogéneo · la sesión nueva tarda más en re-onboardearse y se pierden gotchas detectados durante el trabajo. La regla codifica el shape como contractual para preservar continuidad multi-sesión.

**Origen:** codificada en sesión upstream con firma 🔵 user *"skill + regla (regla como SoT, skill toma la regla como SoT, igual que hicimos con fatiga)"*. Paridad arquitectónica con regla #9 [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) ↔ skill [`/fatiga`](../skills/fatiga/SKILL.md).

**Hermana operativa:** skill [`/handoff`](../skills/handoff/SKILL.md) · trigger explícito que invoca la aplicación de esta regla bajo demanda del user. Esta regla es SoT del shape + cuándo · el skill ejecuta la generación.

## When

**Aplica a:**

- **Camino B de la regla #9** [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) activada · fatiga 🟡 medio o 🔴 grande · user firma "B".
- **User invoca skill `/handoff`** explícitamente · interrupción manual · sin disparador automático del agente.
- **Cierre de fase 🔴 punto-de-no-retorno** (DDL aplicado a TEST DB cloud · archivado masivo · refactor estructural) cuando el agente decide cortar antes de la próxima fase para preservar contexto fresco.
- **Bloqueo inesperado** (CI roto · falta credencial · pre-condición no cumplida) donde la sesión nueva necesita info operativa de qué se intentó y cómo.

**NO aplica a:**

- **Cierre exitoso de PRP entero post-paso 6** · eso es entrada `prp-close` en `log.md` (cronología append-only · regla #20 [`log-chronology-append-only.md`](./log-chronology-append-only.md)).
- **Modo A tasks triviales** · no hay continuidad · termina ahí mismo.
- **Modo B skills cerrados** con flujo propio que ya finalizó.
- **Sesión exploratoria sin scope definido** · no hay trabajo concreto para handoff.
- **Fatiga 🟢 chico camino A continuar** · sesión sigue · cero handoff necesario.

## Process

### Path obligatorio

`.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto-opcional>].md`

- `<scope>`: identificador del trabajo (`PRP-NNN` · `refactor-X.Y` · `dt-NNN` · etc).
- `<YYYY-MM-DD>`: fecha del handoff (cierre de esta sesión).
- `<contexto-opcional>`: sub-contexto cuando hay múltiples handoffs el mismo día (`fase-3-cerrada` · `post-fase4` · `paso-5-cerrado` · `cierre-integral` · etc).

### Las 7 secciones obligatorias (orden estricto · derivado de 36+ ejemplos)

#### 1. Frontmatter YAML

```yaml
---
name: <scope> handoff <descripción corta> · <YYYY-MM-DD>
description: <punto exacto de retoma 1-2 líneas · qué se cerró · qué viene>
metadata:
  type: project
---
```

#### 2. Título + blockquote intro (3 líneas obligatorias)

```markdown
# <scope> · handoff <contexto> · <YYYY-MM-DD>

> **Disparado por:** <razón del handoff · fatigue camino B firmado · cierre fase 🔴 · bloqueo · user invocó /handoff explícito · etc>
> **Próxima acción concreta:** <1 frase · qué tiene que hacer la sesión nueva primero>
> **Skill a invocar:** <skill exacto en sesión nueva · típicamente `/implementar PRP-NNN` o equivalente · NO `/arrancar` cuando el handoff cubre todo el contexto operativo>
```

#### 3. ## Estado al cierre de esta sesión

- Commits hechos (tabla `Commit | Resumen` con SHA y mensaje).
- Qué fases / pasos / sub-bloques quedaron cerrados (con marca `[✓]`).
- Qué se construyó concretamente (archivos · migraciones · specs · etc).
- Decisiones arquitectónicas firmadas durante la sesión.

#### 4. ## Qué falta hacer en la próxima sesión

- Acción operativa paso a paso (numerada · concreta · con paths exactos · cero ambigüedad).
- DoD esperado de la próxima fase / etapa.
- Cross-refs a archivos / reglas / commits relevantes.

#### 5. ## Gotchas detectados (única sección opcional)

- Aprendizajes técnicos descubiertos durante la sesión que pueden ameritar memoria persistente nueva.
- Anti-patterns evitados.
- Convenciones violadas y fixeadas inline.
- Candidatos a `feedback/<topic>.md` futuro.

**Si genuinamente ninguno aplica, omitir la sección entera** (no escribir "ninguno detectado").

#### 6. ## Re-onboarding en sesión nueva

- Pasos concretos del agente para arrancar la sesión nueva eficientemente.
- Qué `Read` hacer primero · qué skill invocar · qué saltar (Paso 0 ya cerrado · Paso 1 fases ya delimitadas · etc).
- Status tracker recomendado al boot.

#### 7. ## Refs

- Links al PRP / mini-PRP / refactor / scope correspondiente.
- DTs abiertas en esta sesión.
- Commits clave.
- Reglas firmes que aplicaron durante la sesión.

### Reglas operativas firmes

1. **6 secciones obligatorias · Gotchas única opcional** · las otras 6 son contractuales.
2. **Frontmatter `type: project`** · paridad con resto de memorias en `.claude/memory/project/`.
3. **Path obligatorio** · cero handoffs fuera de `.claude/memory/project/`.
4. **Commit del handoff** · el archivo se commitea localmente en el último commit de la sesión que cierra (NO push · paridad regla #27 [`push-and-ci-policy.md`](./push-and-ci-policy.md) "1 push por PRP en paso 6").
5. **NO sustituye `prp-close`** · el handoff es mid-flight · al cerrar el PRP entero post-paso 6 va `prp-close` en `log.md` (regla #20).
6. **Mencionar el handoff al user al cierre** · *"Handoff generado en `<path>` · próxima sesión arranca con [skill]"* · cero archivos silenciosos en `.claude/memory/project/`.

## Anti-rationalization

| Excusa | Rebuttal |
|---|---|
| "Es chico · skipeo el handoff · la próxima sesión re-lee el PRP y arranca" | NO. Re-leer PRP entero: 5-10 min · generar handoff: 2 min. Sin handoff la sesión nueva pierde gotchas + estado preciso de cerrado vs pendiente. |
| "Resumo todo en 3 líneas en el commit message · alcanza" | NO. Commit message = git history · handoff = re-onboarding operativo · canales distintos. Las 7 secciones del handoff NO caben en 3 líneas. |
| "Sé que el user va a leer todo igual · simplifico el shape" | NO. El handoff es para EL AGENTE que retoma · no para el user. Saltarse secciones rompe la continuidad operativa de la sesión nueva. |
| "Skipeo la sección Gotchas porque ninguno relevante" | OK · es la única opcional. Pero confirmá honestamente que ninguno aplica · gotchas suelen ser invisibles para el agente fatigado. |
| "Genero el handoff sin avisar al user" | NO. Mencionar al cierre es contractual (regla operativa #6) · *"Handoff generado en `<path>` · próxima sesión arranca con [skill]"*. Cero archivos silenciosos. |
| "Uso un path distinto porque me parece más claro" | NO. Path canónico contractual · `/arrancar` y otros skills buscan handoffs ahí exacto. Path distinto = handoff invisible al boot de la próxima sesión. |

## Red flags

- 🚩 Vas a cerrar la sesión mid-trabajo y NO generaste handoff (camino B firmado o fase 🔴 cerrada).
- 🚩 El handoff que generaste vive fuera de `.claude/memory/project/`.
- 🚩 Falta alguna de las 6 secciones obligatorias (Gotchas es la única opcional).
- 🚩 El path no sigue convención `<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md`.
- 🚩 El blockquote intro NO tiene "Disparado por · Próxima acción concreta · Skill a invocar" en 3 líneas.
- 🚩 Generaste el handoff y no lo mencionaste al user al cierre.
- 🚩 Confundiste handoff con `prp-close` (handoff = mid-flight · `prp-close` = post-merge a main · regla #20 [`log-chronology-append-only.md`](./log-chronology-append-only.md)).

## Verification

- [ ] Path: `.claude/memory/project/<scope>-handoff-<YYYY-MM-DD>[-<contexto>].md` (estricto).
- [ ] Frontmatter YAML con `name` · `description` · `type: project`.
- [ ] Blockquote intro con 3 líneas obligatorias (Disparado por · Próxima acción · Skill a invocar).
- [ ] 6 secciones obligatorias presentes (Estado al cierre · Qué falta · Re-onboarding · Refs · más Frontmatter + Título-blockquote).
- [ ] Sección Gotchas presente cuando aplica · omitida cuando genuinamente no aplica.
- [ ] Handoff commiteado localmente en el último commit de la sesión que cierra.
- [ ] Mencionado al user al cierre con path exacto + próxima acción.

**Cross-reference firme:**

- Hermana operativa: [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) (regla #9 · disparador típico del handoff vía camino B · paridad arquitectónica skill ↔ regla).
- Hermana operativa: skill [`/handoff`](../skills/handoff/SKILL.md) (trigger explícito · invoca la aplicación de esta regla bajo demanda).
- Hermana operativa: [`log-chronology-append-only.md`](./log-chronology-append-only.md) (regla #20 · handoff ≠ `prp-close` · cero solapamiento de canales).
- Refuerza: [`golden-rule-docs-memory.md`](./golden-rule-docs-memory.md) (ítem 6 commit local con resumen · handoff es parte del cierre de sesión).
- Refuerza: [`quality-standard-senior.md`](./quality-standard-senior.md) (continuidad multi-sesión es parte del estándar senior · cero handoffs sloppy).
- Refuerza: [`folder-creation-with-readme.md`](./folder-creation-with-readme.md) ítem § Lectura/consulta antes de actuar (la sesión nueva lee el handoff antes de actuar en `.claude/memory/project/`).

---

*Regla #26 codificada en sesión upstream con firma 🔵 user *"skill + regla (regla como SoT, igual que fatiga)"*. Formaliza la convención de práctica observada en 36+ handoffs históricos en `.claude/memory/project/`. Paridad arquitectónica con regla #9 [`fatigue-self-evaluation.md`](./fatigue-self-evaluation.md) ↔ skill [`/fatiga`](../skills/fatiga/SKILL.md).*
