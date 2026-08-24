---
name: hermes-backup-restore
description: "Restore Hermes config/skills/memory from a backup repo."
version: 1.0.0
author: Hermes Agent
tags: [hermes, backup, restore, migration, github, configuration]
---

# Hermes Backup & Restore

Restore Hermes Agent configuration, memory, skills, and environment files from a backup repository or archive.

## Trigger

When a user provides a backup source (GitHub repo URL, archive, file path) and asks to restore Hermes configuration/memory.

## Workflow

### 1. Clone / Download (Read-Only)

Clone or download the backup source to a temp directory. Never write to `~/.hermes/` until inspection is complete.

```bash
cd /tmp && git clone <repo-url> hermes-backup
```

### 2. Inspect Contents (MANDATORY — skip nothing)

Review every file in the backup **before** suggesting any changes. Common backup layouts:

| Path | Purpose |
|---|---|
| `SOUL.md` | Hermes personality/system prompt |
| `config.yaml` | Main configuration |
| `.env` | API keys and secrets |
| `skills/` | Installed skills |
| `memories/` | Persistent memory entries |

Check each file's content. Compare against the current live setup. Identify:
- **What's custom** vs what's just default Hermes scaffolding
- **What's stale** (old config versions, deprecated settings)
- **What's dangerous** (credentials, tokens, overly permissive settings)
- **What's missing** (files the user expects but aren't in the backup)

### 3. Report Findings to User

Present a clear summary before any action:

- What the backup contains
- What is custom/valuable vs default/unnecessary
- What looks suspicious or misconfigured
- What will change if restored

**Do NOT auto-apply anything.** Let the user decide what to restore.

### 4. Apply Selected Items (with user confirmation)

Only after explicit user approval:

```bash
# Skills: copy to ~/.hermes/skills/
# Memory: copy to ~/.hermes/memories/ (if applicable)
# Config: use `hermes config set KEY VAL` — never hand-edit config.yaml
# Secrets (.env): warn about exposure, let user paste manually
```

## Critical Pitfalls

1. **NEVER blindly install/apply a backup.** If something looks wrong or there's a problem, STOP and tell the user. Review first, apply second. The user explicitly corrected this: "اگر دیدی چیزی درست نیست یا مشکل پیش میاد نصب نکن" (If something looks wrong or there's a problem, don't install it).

2. **Default ≠ valuable.** A backup of a fresh Hermes install contains only default files (standard SOUL.md, default config.yaml, bundled skills). Warn the user if the backup has no custom content worth restoring.

3. **Credential exposure.** If a GitHub PAT or API key is shared in chat:
   - **Never store it in memory** — it's a security risk
   - Warn the user to revoke/recreate the token
   - For repo access, use the token ephemerally (git clone with inline auth is fine for one-time access)
   - The Hermes secret redaction system may mask it in logs, but the chat itself is already exposed

4. **Don't overwrite live config blindly.** Differences between backup config.yaml and live config.yaml may be intentional (user customized settings). Always diff before merging.

5. **Skill compatibility.** Backup skills may be outdated. Check skill versions against what's currently installed. A skill bundled with Hermes should not be overwritten with an older backup version.

## Verification

After partial or full restore:
- `hermes doctor` — health check
- `hermes config show` — verify key settings
- Check that skills load: review `skills_list` output
- Verify memory entries appear in new sessions
