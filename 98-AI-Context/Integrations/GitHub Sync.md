---
type: integration-guide
status: active
tags:
  - workflow/gi
  - topic/github
  - topic/obsidian
---

# GitHub Sync

## Repository

- Remote: `https://github.com/gxpqaznew/ob-.git`
- Visibility: private.
- Local Vault: `C:\ob仓库\ob仓库`

## Sync policy

- Pull on Obsidian startup.
- Automatic backup every 10 minutes.
- Push after a successful automatic backup.
- Pull before push.
- Do not commit workspace layout, caches, trash, temporary files, or secrets.

## Recovery

If automatic sync reports a conflict:

1. Stop editing the conflicting note.
2. Open Git history and inspect both versions.
3. Preserve both source variants when meaning is uncertain.
4. Resolve, run the audit, commit, and push.

\n