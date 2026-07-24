---
type: integration-guide
status: needs-manual-browser-step
tags:
  - workflow/research
  - topic/obsidian
---

# Web Clipper Setup

The importable template is:

`98-AI-Context/Integrations/Research Capture.json`

## Browser steps

1. Install the official **Obsidian Web Clipper** extension.
2. Open its settings and select the Vault `ob仓库`.
3. Open **Templates** and import `Research Capture.json`.
4. Confirm the destination path is `00-Inbox/Downloaded`.
5. Clip one article and verify that title, URL, author, publication time, capture time, and full content are present.

The browser extension stores its configuration in the browser profile, not in the Vault. The JSON file in this Vault is the durable source-of-truth and backup for that manual import.

## After capture

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\98-AI-Context\Automation\Research-Cleaner.ps1"
```

Raw captures remain unchanged in `Downloaded`; cleaned Markdown is created in `Cleaned`.
