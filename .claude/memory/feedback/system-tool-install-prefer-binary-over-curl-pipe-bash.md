---
name: Al instalar tools del sistema · preferir binary release directo sobre curl-pipe-bash · más seguro · más auditable · classifier-friendly
description: Cuando una herramienta del sistema NO está disponible via gestor de paquetes nativo (apt/brew/dnf) y hay que instalarla manualmente, preferir **binary release directo** (curl + tar/unzip + mv a `/usr/local/bin/`) sobre **curl-pipe-bash** (`curl ... | bash` o `bash <(curl ...)`). El binary directo es más seguro (cero ejecución de script remoto arbitrario), más auditable (binario verificable con checksum), y el classifier del harness Claude Code lo permite (curl-pipe-bash suele dispararse como "Code from External" y queda denegado).
type: feedback
---

Cuando la regla *"propose if missing · NO auto-install"* del proyecto (típicamente declarada en `CLAUDE.md § Política de tooling del sistema`) dispara una propuesta al user de instalar una herramienta del sistema (ej: `actionlint` · `shellcheck` · `yq` · `git-delta` · `fzf` · etc), el agente debe sugerir el método de instalación más seguro disponible. La doc oficial de muchas tools recomienda curl-pipe-bash por conveniencia · pero ese método es subóptimo en este contexto.

**Síntoma observable:**

Sesión típica del anti-pattern: el agente detecta que `actionlint` falta · consulta docs oficiales · sugiere `bash <(curl -sSfL https://raw.githubusercontent.com/.../download-actionlint.bash)` como comando de instalación. El user firma · el agente lo ejecuta. El classifier auto-mode del harness deniega con razón *"Code from External"* (script remoto descargado y ejecutado sin auditar). El agente queda obligado a buscar alternativa post-fail · workaround: descargar binary release directo (`curl -L .../actionlint_<version>_<os>.tar.gz -o /tmp/a.tar.gz && tar -xzf /tmp/a.tar.gz -C /tmp && mv /tmp/actionlint /usr/local/bin/`).

**Why:**

- **Seguridad:** curl-pipe-bash ejecuta un script remoto entero sin que el user vea su contenido · el script puede hacer mucho más que "instalar la tool" (modificar `.bashrc` · descargar dependencias adicionales · contactar servicios externos · etc). El binary directo solo coloca un archivo ejecutable en `/usr/local/bin/`.
- **Auditabilidad:** un binary release viene con checksum (típicamente SHA256) publicado en la página de release de GitHub · el user puede verificar antes de copiarlo a `/usr/local/bin/`. Un script bash remoto NO tiene checksum estable (puede cambiar entre fetches).
- **Reproducibilidad:** binary release de una versión `vX.Y.Z` es inmutable (GitHub releases NO permite reescribir assets) · curl-pipe-bash del `master` branch puede cambiar entre commits.
- **Harness compatibility:** el classifier auto-mode del harness Claude Code es defensivo contra `bash <(curl ...)` / `curl ... | bash` patterns porque son vectores conocidos de supply chain attack · binary download + extract + move son operaciones discretas que el classifier permite.

**How to apply:**

- **Orden de preferencia al proponer install command** (primer match gana):
  1. Gestor de paquetes nativo (`apt install <tool>` · `brew install <tool>` · `dnf install <tool>` · etc). Generalmente disponible para tools establecidas (shellcheck · ripgrep · fd-find · bat · git-delta · fzf · tree · jq · yamllint).
  2. Binary release directo desde GitHub Releases u origen oficial. Pattern típico: `curl -L <url-del-asset>.tar.gz -o /tmp/x.tar.gz && tar -xzf /tmp/x.tar.gz -C /tmp && sudo mv /tmp/<binary> /usr/local/bin/ && rm /tmp/x.tar.gz`.
  3. Gestor de paquetes de lenguaje cuando la tool es del lenguaje (`npm install -g <tool>` para Node tools · `pip install <tool>` para Python tools · etc). Aceptable cuando el lenguaje ya está instalado.
  4. **Último recurso:** curl-pipe-bash con firma user explícita del comando exacto + advertencia sobre el riesgo. Usar SOLO si las opciones 1-3 no aplican.
- **Auto-chequeo de 5 segundos antes de proponer install:** "¿puedo conseguir esta tool via apt/brew · O via binary release directo en GitHub?". Si SÍ → usar esa. Si NO → caer al gestor de lenguaje · y solo si tampoco aplica · curl-pipe-bash con warning explícito.
- **Si la doc oficial recomienda curl-pipe-bash** (caso típico de tools como `bun` · `oh-my-zsh` · varios install scripts), verificar antes la página `Releases` del repo en GitHub: la mayoría tiene también binary assets (`<tool>_<version>_<os>_<arch>.tar.gz`) que se pueden descargar directo.
- **Formato canónico de propuesta al user** (paridad regla `metodologia-iteracion`):

  ```text
  Detecté que `<tool>` no está instalada. Sugiero:

  Opción A (rec · gestor nativo): sudo apt install <tool>
  Opción B (binary release): curl -L <url> -o /tmp/x.tar.gz && tar -xzf ... && sudo mv ...

  Rec A porque <razón>. ¿Firmás?
  ```

**Recovery (si ya pasó · classifier denegó curl-pipe-bash):**

No es recovery propiamente · es pivote: cuando el classifier deniega el primer intento, el agente debe (1) reconocer la denegación · (2) buscar alternativa binary release o gestor nativo · (3) presentar la alternativa al user con justificación + firma. NO insistir con curl-pipe-bash (el classifier ya señaló el patrón como riesgoso).

**Alternativas descartadas:**

- Confiar en la doc oficial de cada tool: la doc optimiza por DX onboarding · NO por seguridad · suele recomendar curl-pipe-bash incluso cuando hay alternativa binary release disponible.
- Auto-instalar sin firma user: viola la regla canónica del CLAUDE.md *"propose if missing · NO auto-install"* · cero excepciones.
- Cachear las URLs de binary releases por tool: brittle (URLs cambian entre versiones) · mejor consultar la página `/releases/latest` al momento de proponer.

**Cross-reference:**

- Regla canónica del CLAUDE.md: `Política de tooling del sistema (propose si falta · NO auto-install)` (esta memoria detalla el "cómo" del install command cuando la propose es aceptada).
- Regla firme: [`ante-duda-preguntar-user.md`](../../rules/ante-duda-preguntar-user.md) (cero auto-install · firma user explícita siempre · esta memoria refuerza el patrón con el método de install específico).
- Hermana operativa: [`bash-tool-timeout-and-classifier-boundary.md`](./bash-tool-timeout-and-classifier-boundary.md) (otros gotchas del classifier auto-mode del harness · contexto general sobre cómo el classifier evalúa comandos).
