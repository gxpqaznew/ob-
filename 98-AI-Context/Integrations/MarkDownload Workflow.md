---
type: integration-guide
status: needs-manual-browser-step
tags:
  - workflow/research
  - topic/obsidian
---

# MarkDownload Workflow

## Pipeline

```text
Web page
  ↓ MarkDownload
00-Inbox/Downloaded
  ↓ Research-Cleaner.ps1
00-Inbox/Cleaned
  ↓ triage / -Promote
04-Research/<one primary category>
  ↓
topic tags + Topic Hub links
```

## MarkDownload settings

- Download directory: `C:\ob仓库\ob仓库\00-Inbox\Downloaded`
- Include source URL: enabled.
- Include frontmatter: enabled when available.
- Keep article body: enabled.
- Do not overwrite existing files without confirmation.

Browser extensions cannot silently change the browser's download directory. Set the directory in MarkDownload or choose it in the Save dialog.

## Clean

```powershell
Set-Location -LiteralPath "C:\ob仓库\ob仓库"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\98-AI-Context\Automation\Research-Cleaner.ps1"
```

To promote directly after reviewing the taxonomy:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\98-AI-Context\Automation\Research-Cleaner.ps1" -Promote
```

## Guarantees

- raw source files are never edited;
- cleaned output records the source path and SHA-256 hash;
- title, author, URL, publication date, and capture date are retained when detected;
- conservative formatting recognizes common headings and numbered lists;
- long paragraphs may receive extra line breaks, but source wording is not rewritten or removed;
- topic tags and Topic Hub links are added from `Research Taxonomy.json`.
