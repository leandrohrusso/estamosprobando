---
name: `| tail -N` en background tasks NO emite output hasta que stdin cierra (EOF) · usar redirect a archivo regular sin pipe
description: `npm run ci:local 2>&1 | tail -30` con `run_in_background: true` produce archivo output 0 bytes mientras el pipeline corre · `tail -N` solo emite las últimas N líneas cuando recibe EOF de stdin. Para procesos largos donde se quiere monitorear progreso incremental, NUNCA usar `| tail -N` · siempre redirect a archivo regular (`> /tmp/<archivo>.log 2>&1`) + leer parcialmente con `tail -N <archivo>` o `tail -f <archivo>` después.
type: feedback
---

Cuando se corre un proceso largo con `run_in_background: true` y se filtra el output con `| tail -N`, el archivo de output del task queda en **0 bytes** mientras el pipeline está corriendo. Esto NO es bug del harness · es comportamiento estándar de `tail`:

```bash
# ❌ Anti-pattern detectado en sesión PRP-NNN upstream:
npm run ci:local 2>&1 | tail -30   # 12-15 min runtime
# Resultado: /tmp/.../tasks/<task_id>.output queda 0 bytes hasta EOF.
# Si el harness kill-ea por timeout 10 min ANTES del EOF, output se pierde completo.

# ✅ Convención correcta:
nohup npm run ci:local > /tmp/ci-local-run.log 2>&1 &
# Output va incremental al archivo · podés leer parcialmente con tail -N en cualquier momento:
tail -30 /tmp/ci-local-run.log   # últimas 30 líneas hasta ahora
tail -f /tmp/ci-local-run.log    # follow en tiempo real
```

**Why:**

- `tail -N` por design es "show last N lines" · necesita ver el END de stdin para saber cuáles son las últimas N. Mientras stdin sigue abierto, tail buffer-iza · emite cuando recibe EOF.
- Cuando el task del harness completa con `completed: exit code 0` y el output file está vacío, lo que pasó es: el comando interno corrió a fin · tail recibió EOF · y volcó las 30 últimas líneas al pipe del background task. Si el harness ya cerró el read del task antes del flush, output se pierde.
- Caso real: en sesión PRP-NNN, primer `ci:local` corrió con `| tail -30` · al chequear el output file a los 4 min de iniciado, decía 0 bytes · misinterpreté como "task killed por timeout" pero en realidad seguía corriendo · al completar (15 min después) sí volcó las 30 últimas líneas pero confundió el debugging.

**How to apply:**

- **Procesos largos en background:** SIEMPRE redirect a archivo regular sin pipe filter:

  ```bash
  nohup <comando-largo> > /tmp/<descripcion>.log 2>&1 &
  ```

- **Procesos cortos en foreground:** OK usar `| tail -N` porque el pipe se cierra al terminar el comando · tail emite normalmente.
- **Si querés solo las últimas N líneas al final:** ejecutar `tail -N /tmp/<descripcion>.log` DESPUÉS de que el proceso termine (en bloque separado del Bash tool).
- **Si querés follow en tiempo real:** `tail -f /tmp/<descripcion>.log` mientras el proceso corre · pero esto bloquea el shell · usar solo en debugging manual del user.

**Cross-references:**

- Memoria hermana: [`bash-tool-timeout-and-classifier-boundary.md`](./bash-tool-timeout-and-classifier-boundary.md) (combinación con `nohup &` para timeout > 10 min).
- Origen del aprendizaje: handoff del PRP donde se detectó · queda como ref histórica del proyecto upstream.
- Aplica universal · convención operativa del harness Claude Code para procesos > 1 min en background.
