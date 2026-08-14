# Restore Recipe

Steps to restore Hermes data from a backup in the GitHub repo.

## Prerequisites

- Git, Python 3, tar available
- Access to the backup repo (HTTPS with PAT)

## Restore Steps

```bash
REPO_URL="https://<PAT>@github.com/<owner>/<repo>.git"
RESTORE_DIR="/tmp/hermes-restore"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

# Clone the backup repo
git clone "$REPO_URL" "$RESTORE_DIR"

# Find the latest backup
LATEST=$(ls -dt "$RESTORE_DIR"/backup_* | head -1)
echo "Restoring from: $LATEST"

# Deobfuscate .enc files (XOR is self-inverse — same operation)
ENC_KEY="your-xor-key-here"

for enc_file in "$LATEST"/*.enc; do
    [ -f "$enc_file" ] || continue
    base=$(basename "$enc_file" .enc)

    if [[ "$base" == "state.db" ]]; then
        # state.db was compressed + obfuscated: deobfuscate then decompress
        python3 -c "
import zlib
key = b'${ENC_KEY}'
data = open('${enc_file}', 'rb').read()
dec = bytes(b ^ key[i % len(key)] for i, b in enumerate(data))
open('${HERMES_HOME}/${base}', 'wb').write(zlib.decompress(dec))
"
    else
        # Simple XOR deobfuscation
        python3 -c "
key = b'${ENC_KEY}'
data = open('${enc_file}', 'rb').read()
out = bytes(b ^ key[i % len(key)] for i, b in enumerate(data))
open('${HERMES_HOME}/${base}', 'wb').write(out)
"
    fi
    echo "Restored: $base"
done

# Copy plain files
for f in config.yaml SOUL.md channel_directory.json gateway_state.json kanban.db; do
    [ -f "$LATEST/$f" ] && cp "$LATEST/$f" "$HERMES_HOME/" && echo "Restored: $f"
done

# Extract directory tarballs
for tarball in "$LATEST"/*.tar.gz; do
    [ -f "$tarball" ] || continue
    tar xzf "$tarball" -C "$HERMES_HOME/" && echo "Restored: $(basename "$tarball" .tar.gz)/"
done

echo "✅ Restore complete. Restart Hermes to pick up changes."
```

## Notes

- The XOR key must match the one used during backup
- state.db may be locked if Hermes is running — stop Hermes first
- Sessions will appear in the next Hermes startup
- Skills are restored as tar.gz — they'll be available immediately
