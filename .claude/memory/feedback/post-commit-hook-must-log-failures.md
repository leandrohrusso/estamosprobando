---
name: Hooks que ejecutan en background con --quiet deben loguear fallos a archivo
description: "Cualquier hook git (post-commit, post-merge, etc.) que ejecuta comandos en background con `--quiet 2>&1 >/dev/null` esconde fallos silenciosamente. Si el comando falla por días/semanas, nadie lo nota hasta que aparece el síntoma (recovery imposible · backup obsoleto · sync roto). Regla derivada: SIEMPRE loguear fallos a `.git/<hook>.log` con timestamp + SHA + razón."
type: feedback
---

Hooks de git que ejecutan operaciones de red en background con output silenciado fallan **silenciosamente y prolongadamente**. El patrón típico es:

```sh
git push --quiet origin HEAD:dev-backup >/dev/null 2>&1 &
```

El `&` manda al background, `--quiet` minimiza output, `>/dev/null 2>&1` redirige todo a basura. Si el push falla (`non-fast-forward` = rechazo de push porque el remoto tiene historia divergente que el push borraría · auth expirado · network down · permission denied), **NO hay forma de saberlo**. El usuario sigue commiteando local pensando que el backup funciona.

**Why:**

- Detectado en sesión upstream durante un refactor intensivo del flujo. El hook `.husky/post-commit` falló silenciosamente por varios días seguidos post-squash de un PRP previo (rechazo non-fast-forward porque `dev-backup` quedó en linaje muerto · ver memoria hermana `squash-merge-dev-divergence.md`). Si el entorno hubiera muerto en ese intervalo, se perdían varios días de trabajo del refactor · garantía operativa "NO push durante refactor · backup automático protege" rota sin que nadie notara.
- El bug es **anti-detection by design**: el output que delataría el problema está suprimido por el propio hook. La única forma de detectarlo es preguntarse "¿cuándo fue el último commit de `dev-backup`?" y comparar con el último commit local — algo que nadie hace de rutina porque el hook *debería* funcionar.

**How to apply:**

Cualquier hook que ejecute comando en background con output silenciado debe **capturar el exit code y loguear fallos a archivo** con suficiente contexto para diagnosticar después:

```sh
LOG="$(git rev-parse --git-dir)/<hook-name>.log"
SHA="$(git rev-parse --short HEAD)"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

(
    if OUTPUT="$(git push origin HEAD:dev-backup 2>&1)"; then
        :  # Success · silencioso · NO loguear OK (ruido innecesario)
    else
        EXIT=$?
        printf '%s · %s · FAIL (exit %d)\n%s\n---\n' "$TS" "$SHA" "$EXIT" "$OUTPUT" >> "$LOG"
    fi
) &
```

**Reglas concretas:**

1. **Capturar exit code** — sin esto el hook no sabe si falló.
2. **Capturar stdout+stderr a una variable** (`2>&1`) — para preservar la razón del fallo.
3. **Loguear timestamp + SHA + EXIT + OUTPUT** — el SHA permite correlacionar con commits específicos · el timestamp permite detectar gaps prolongados.
4. **NO loguear éxitos** — agrega ruido al archivo · si querés rotación o métricas, separar a otro archivo o usar un script de health check periódico.
5. **El log vive en `.git/`** — fuera del working tree (`.git/` no se versiona) · privado al clone local · no contamina commits.
6. **Sufijo del archivo** — `<hook-name>-<purpose>.log` (ej: `post-commit-backup.log`) para que sea autodescriptivo · evitar nombres genéricos como `error.log`.

**Anti-patterns:**

- `git push --quiet ... >/dev/null 2>&1 &` (sin captura de exit code · output completamente perdido)
- `git push --quiet ... 2>/tmp/err &` (output en `/tmp` se pierde al reboot)
- Loguear éxitos también (genera ruido · enmascara fallos)

**Cómo el user audita el log:**

```bash
# Ver fallos recientes
tail -50 .git/post-commit-backup.log

# Detectar gap (sin fallos puede significar todo OK O hook nunca corrió)
ls -la .git/post-commit-backup.log
```

**Aplicar a:**

- `.husky/post-commit` ✅ ya aplicado.
- Cualquier hook futuro que ejecute en background con output silenciado.
- Scripts de cron / scheduled jobs que tengan el mismo patrón.

**Coordinación con `squash-merge-dev-divergence.md`:** el log de fallos detecta el síntoma · el script `sync-dev-after-squash-merge.sh` (extendido el mismo día) cierra la causa raíz. Las dos memorias son complementarias.
