---
type: guide
status: active
tags:
  - workflow/research
  - system/inbox
---

# Research Import Guide

## Entry points

- Browser articles: use the Web Clipper `Research Capture` template.
- Markdown downloads: save with MarkDownload into `00-Inbox/Downloaded`.
- Files and images: place them in `00-Inbox/Attachments`.
- Quick notes: create them in `00-Inbox`, then triage them.

## Required source metadata

Keep as much of the following as the source provides:

- title;
- source URL;
- author or publisher;
- publication time;
- capture time;
- full original content.

Never overwrite the original file in `Downloaded`. Run the Research Cleaner to create a separate cleaned copy.

## Run the cleaner

From PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\98-AI-Context\Automation\Research-Cleaner.ps1"
```

Add `-Promote` only when you want cleaned copies moved into their primary research category.
\n