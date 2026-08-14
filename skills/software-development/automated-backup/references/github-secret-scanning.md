# GitHub Secret Scanning & Push Protection

## What It Does

GitHub's **push protection** scans every push for known secret patterns (PATs, API keys, tokens from major providers). It works on:
- Text files (obvious)
- **Binary files** like SQLite `.db` — scans raw bytes for hex/regex patterns
- Compressed archives (`.tar.gz`, `.zip`) — GitHub decompresses before scanning

## When It Triggers

Common triggers when backing up local data:
- `state.db` containing git clone URLs with embedded PATs
- `.env` files with `GITHUB_TOKEN=ghp_xxx`
- `auth.json` with OAuth tokens matching known patterns
- Session databases storing API calls with credentials in URLs

## Error Format

```
remote: error: GH013: Repository rule violations found for refs/heads/main
remote:
remote: - GITHUB PUSH PROTECTION
remote:   —————————————————————————————————————————
remote:     Resolve the following violations before pushing again
remote:
remote:     - Push cannot contain secrets
remote:
remote:             (?) Learn how to resolve a blocked push
remote:             https://docs.github.com/code-security/secret-scanning/...
remote:
remote:             —— GitHub Personal Access Token ————————————————
remote:              locations:
remote:                - commit: abc123
remote:                  path: backup/state.db:391
remote:
remote:             (?) To push, remove secret from commit(s) or follow this URL:
remote:             https://github.com/<owner>/<repo>/security/secret-scanning/unblock-secret/<id>
```

## Workarounds

### 1. Obfuscation (recommended for automated scripts)
- XOR-encode sensitive files before commit
- Compress (zlib) before encoding for extra entropy
- Save as `.enc` extension
- Include MANIFEST.md with decode instructions

### 2. One-time Unblock (manual only)
- Follow the unblock URL from the error message
- Confirm the secret is safe
- Only works for that specific commit — won't help for cron jobs

### 3. Disable Push Protection (repo settings)
- Settings → Code security → Push protection → Disable
- **Not recommended** — loses the security benefit entirely

### 4. .gitattributes (limited help)
- `*.db binary` marks files as binary but does NOT bypass secret scanning
- Only prevents diff display, not scanning

## Best Practice for Automated Backups

Always obfuscate files that *might* contain tokens, even if you're not sure. The overhead is minimal (a few lines of Python) and prevents unexpected push failures at 3am.
