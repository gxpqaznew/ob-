---
type: integration-guide
status: replaced
tags:
  - workflow/research
  - topic/obsidian
---

# MarkDownload Workflow

> MarkDownload's original Chrome extension is no longer available because Chrome reports that it does not follow current extension best practices. Do not bypass Chrome's protection. This Vault uses the imported **Obsidian Web Clipper / Research Capture** template instead.

## Pipeline

```text
Web page
  ↓ Obsidian Web Clipper / Research Capture
00-Inbox/Downloaded
  ↓ Research-Cleaner.ps1
00-Inbox/Cleaned
  ↓ triage / -Promote
04-Research/<one primary category>
  ↓
topic tags + Topic Hub links
```

## Capture settings

- Destination: `00-Inbox/Downloaded`
- Preserve title, source URL, author, capture time, and article body.
- Use the imported `Research Capture` template.
- Do not overwrite existing files without confirmation.

No MarkDownload installation is required.

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
