---
type: guide
status: active
tags:
  - workflow/promp
  - topic/promp
---

# Prompt Library Guide

## Store a prompt when

- it is reusable across more than one task;
- inputs and expected outputs can be stated clearly;
- success can be evaluated;
- it contains durable workflow knowledge rather than one conversation.

## Required fields

- purpose;
- compatible agent or model, if constrained;
- required inputs;
- prompt text;
- output contract;
- quality checks;
- version and change notes.

## Classification

A prompt lives in exactly one category folder. Use topic tags and links for secondary uses.

## Improvement loop

1. Run the prompt on a representative task.
2. Record failure modes.
3. Change one meaningful element.
4. Re-test.
5. Update version and change notes.

Never store API keys, tokens, personal secrets, or raw private conversations.

\n