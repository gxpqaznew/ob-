# AI Agent Operating Rules

This vault is a durable knowledge system shared by humans and AI agents such as Codex, Claude Code, and Cursor.

## Read first

Before substantial work, read:

1. `98-AI-Context/AI Operating Context.md`
2. `98-AI-Context/Current Focus.md`
3. `98-AI-Context/Prompt Rules.md`
4. the relevant project `Project-Status.md`

## Information architecture

- Every note has exactly one primary folder classification.
- A note may have multiple `topic/...` tags and internal links.
- Raw captures stay in `00-Inbox/Downloaded` and must never be overwritten.
- Cleaned copies go to `00-Inbox/Cleaned`; promoted research goes to one folder under `04-Research`.
- Topic hubs live in `04-Research/Topic-Hubs`.
- Reusable prompts live in exactly one category under `89-Prompts`.
- Completed or inactive material moves to `99-Archive`; do not delete durable knowledge without explicit approval.

## Durable memory

Do not save chat transcripts. Update memory only for information likely to remain useful:

- decisions and their rationale;
- proven workflows and best practices;
- recurring lessons and user preferences;
- project state, risks, and next actions;
- stable knowledge summaries or meaningful trend changes.

Write these updates to `97-AI-Memory`, `98-AI-Context`, or the relevant `06-Projects/<Project>/Project-Status.md`.

## Research and sources

- Preserve source meaning and distinguish source facts from analysis.
- Keep `source_url`, author, publication date, and capture date when available.
- The Research Cleaner may improve structure, but must not delete, summarize, or rewrite source claims.
- Add relevant `topic/...` tags and links to Topic Hubs.
- Prefer internal links that help retrieval; avoid decorative link spam.

## Projects

Every project directory must contain `Project-Status.md` with:

- current status;
- completed work;
- outstanding tasks;
- next action;
- risks;
- decisions.

Update it after meaningful progress.

## Verification

- Review changed files before committing.
- Run `98-AI-Context/Automation/Knowledge-Base-Audit.ps1` after structural changes.
- Do not commit secrets, tokens, local caches, or machine-specific workspace state.
