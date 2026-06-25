# `.claude/config/` · Configuración del proyecto para skills del pack

> **Qué es:** carpeta de configuración del proyecto que alimenta skills del pack con decisiones del dominio (qué sub-agentes domain-tight aplican · qué features están habilitadas · qué constraints declarativos consume el flujo). 1 archivo `.yml` por config · cero markdown como input declarativo (más frágil que YAML).
>
> **Por qué se creó:** algunos skills del pack (típicamente los multi-agente como `/revisar` y `/revisar-main`) tienen sub-agentes con scope condicional al dominio del proyecto (ej: `multi-tenant` · `atomicity` · `migration-safety`). Sin un canal declarativo centralizado, cada skill duplicaba la lógica de detección del dominio (más ruidoso · más frágil · cero SoT). Esta carpeta centraliza esas declaraciones en YAML parseable.
>
> **Para qué sirve:** los skills `/revisar` y `/revisar-main` leen [`agents-applicability.yml`](./agents-applicability.yml) en su Paso 0.6 (lectura del config) y solo spawnean los sub-agentes domain-tight habilitados. Doctrina del mecanismo en regla firme #35 [`agents-conditional-by-domain.md`](../rules/agents-conditional-by-domain.md).

## Convención

- **Naming:** kebab-case en inglés · descriptivo · `<config-corta>.yml` (ej: `agents-applicability.yml`). Cero `.json` · cero `.toml` · cero markdown · YAML parseo estable.
- **Shape / formato:** cada archivo YAML lleva header de docstring (comentarios `#` al inicio) explicando qué es · qué alimenta · cómo se llena · default al boot del pack. El cuerpo es estructurado por bloques canónicos (ej: `agents:` para `agents-applicability.yml`).
- **Default al boot del pack:** cada flag declarativo arranca en `unknown` · forza decisión explícita del proyecto destino durante el bootstrap. Cero defaults silenciosos · cero adivinar.
- **Cardinalidad:** mínima · agregar archivo nuevo solo cuando aparezca demanda concreta · cero abstracción especulativa (regla [`simplicity-first.md`](../rules/simplicity-first.md)).
- **Cero secrets en esta carpeta:** los secrets viven en `.env*` (gitignored) · este archivo SÍ se commitea al repo (es declarativo · cero credenciales).

## Archivos actuales

| Archivo | Rol |
|---|---|
| [`agents-applicability.yml`](./agents-applicability.yml) | Declara qué sub-agentes domain-tight de `/revisar` y `/revisar-main` aplican según los constraints del dominio del proyecto destino. |

## Carpetas hermanas

- [`.claude/skills/`](../skills/) — los 15 skills custom del pack consumen archivos de `.claude/config/` cuando necesitan info declarativa del dominio (típicamente skills multi-agente).
- [`.claude/rules/`](../rules/) — reglas firmes del flujo · regla #35 [`agents-conditional-by-domain.md`](../rules/agents-conditional-by-domain.md) es SoT del mecanismo que alimenta a esta carpeta.
- [`.claude/memory/`](../memory/) — memoria persistente del proyecto · distinta finalidad: la memoria captura aprendizajes/gotchas (declarativo subjetivo) · `config/` captura decisiones del dominio (declarativo objetivo).
- [`BUSINESS_LOGIC.md`](../../BUSINESS_LOGIC.md) — identidad del producto + § 8 Constraints del dominio · es la **fuente humana** que alimenta los flags declarativos de esta carpeta. El proyecto destino llena § 8 + replica las decisiones acá.

## Cómo agregar un config nuevo

1. **Validar que NO existe ya un archivo en esta carpeta** que cubra el rol (paridad regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md) § Validación de duplicados).
2. **Decidir naming** kebab-case descriptivo (ej: `feature-flags.yml`).
3. **Escribir archivo nuevo** con header de docstring (qué es · qué alimenta · cómo se llena · default al boot del pack).
4. **Actualizar este README** sumando fila en § "Archivos actuales".
5. **Indexar al consumidor:** el skill o herramienta que consume el config debe documentar la lectura en su § Process + § Verification.
6. **Si el config introduce mecanismo nuevo del flujo** → considerar promover el mecanismo a regla firme nueva con shape P8 (paridad con regla #35).

---

*Convención de README firmada 2026-05-22 (regla [`folder-creation-with-readme.md`](../rules/folder-creation-with-readme.md)).*
