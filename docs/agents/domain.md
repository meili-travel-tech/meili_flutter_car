# Domain docs

How the engineering skills use this repo's domain documentation.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root: the glossary for this repo's domain.
- **`docs/adr/`**: decisions that touch the area you are about to work in.
- When working from the Meili native workspace, its root **`CONTEXT-MAP.md`** lists every repo's glossary and how the contexts relate.

If a file doesn't exist, proceed silently. `/domain-modeling` (reached through `/grill-with-docs`) creates `CONTEXT.md` and ADRs when a term or decision is actually resolved. Both are committed.

## Use the glossary's vocabulary

Name domain concepts as `CONTEXT.md` defines them, in issue titles, proposals, test names and code. A concept missing from the glossary is either invented language to reconsider or a gap to note for `/domain-modeling`.

## Flag ADR conflicts

When your output contradicts an ADR, say so explicitly rather than silently overriding it.
