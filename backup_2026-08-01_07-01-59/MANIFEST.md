# Hermes Backup: backup_2026-08-01_07-01-59

**Timestamp:** 2026-08-01_07-01-59
**Hostname:** 5651be226083

## Files
- `config.yaml`, `SOUL.md`, `channel_directory.json`, `gateway_state.json`, `kanban.db`
- `.env.enc`, `auth.json.enc`, `state.db.enc` (XOR-obfuscated)
- `memories.tar.gz`, `skills.tar.gz`, `sessions.tar.gz`
- `cron.tar.gz`, `platforms.tar.gz`, `hooks.tar.gz`, `kanban.tar.gz`

## To Restore
1. Deobfuscate .enc files with XOR key
2. Decompress zlib for state.db
3. Copy to ~/.hermes/
