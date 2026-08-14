#!/bin/bash
# Hermes Agent Backup Script Template
# Backs up critical Hermes data and pushes to GitHub
# Adapt paths and REPO_URL for your environment
set -euo pipefail

# === CONFIG ===
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
BACKUP_DIR="/tmp/hermes-backup-repo"
REPO_URL="https://<YOUR_PAT>@github.com/<owner>/<repo>.git"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="backup_${TIMESTAMP}"
ENC_KEY="your-xor-key-here"

echo "[backup] Starting at ${TIMESTAMP}"

# === CLONE OR PULL ===
if [ -d "$BACKUP_DIR/.git" ]; then
    cd "$BACKUP_DIR"
    git pull --rebase origin main 2>/dev/null || true
else
    rm -rf "$BACKUP_DIR"
    git clone "$REPO_URL" "$BACKUP_DIR"
    cd "$BACKUP_DIR"
fi

mkdir -p "$BACKUP_DIR/$BACKUP_NAME"

# === HELPER: XOR obfuscate (self-inverse) ===
obfuscate() {
    python3 -c "
import sys
key = b'${ENC_KEY}'
data = open('${1}', 'rb').read()
out = bytes(b ^ key[i % len(key)] for i, b in enumerate(data))
open('${2}', 'wb').write(out)
"
}

# === SENSITIVE FILES (obfuscated) ===
for f in .env auth.json; do
    [ -f "$HERMES_HOME/$f" ] && obfuscate "$HERMES_HOME/$f" "$BACKUP_DIR/$BACKUP_NAME/$f.enc"
done

# state.db: compress + obfuscate (may contain PATs in session data)
if [ -f "$HERMES_HOME/state.db" ]; then
    python3 -c "
import zlib
key = b'${ENC_KEY}'
data = open('${HERMES_HOME}/state.db', 'rb').read()
compressed = zlib.compress(data, 9)
out = bytes(b ^ key[i % len(key)] for i, b in enumerate(compressed))
open('${BACKUP_DIR}/${BACKUP_NAME}/state.db.enc', 'wb').write(out)
"
fi

# === NON-SENSITIVE FILES (plain) ===
for f in config.yaml SOUL.md channel_directory.json gateway_state.json kanban.db; do
    [ -f "$HERMES_HOME/$f" ] && cp "$HERMES_HOME/$f" "$BACKUP_DIR/$BACKUP_NAME/"
done

# === DIRECTORY BACKUPS (tar.gz) ===
for dir in memories skills sessions cron platforms hooks kanban; do
    [ -d "$HERMES_HOME/$dir" ] && tar czf "$BACKUP_DIR/$BACKUP_NAME/${dir}.tar.gz" \
        -C "$HERMES_HOME" --exclude='*.lock' "$dir/" 2>/dev/null
done

# === CLEANUP OLD BACKUPS (keep last 10) ===
ls -dt "$BACKUP_DIR"/backup_* 2>/dev/null | tail -n +11 | xargs rm -rf 2>/dev/null || true

# === COMMIT AND PUSH ===
cd "$BACKUP_DIR"
git add -A
if ! git diff --cached --quiet; then
    git config user.email "backup@bot"
    git config user.name "Backup Bot"
    git commit -m "backup: ${BACKUP_NAME}"
    git push origin main
    echo "[backup] ✅ Pushed successfully"
else
    echo "[backup] No changes"
fi
echo "[backup] Done at $(date '+%Y-%m-%d_%H-%M-%S')"
