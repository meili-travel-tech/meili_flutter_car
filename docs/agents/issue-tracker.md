# Issue tracker: local markdown

Jira holds this repo's tickets. Specs, implementation tickets, notes and QA scripts produced by the agent skills are local, gitignored markdown in `.scratch/`; they never go into git or Jira.

## Conventions

- One directory per Jira ticket: `.scratch/<JIRA-KEY>/` (for example `.scratch/MPD-11466/`).
- The spec is `.scratch/<JIRA-KEY>/spec.md`. Implementation tickets are one file each at `.scratch/<JIRA-KEY>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order, never a single combined file.
- Each ticket file carries a `Status:` line and a `Blocked by:` line near the top.
- Comments and conversation history append under a `## Comments` heading.
- Work spanning repos keeps its spec with the primary ticket; sibling repos' `.scratch/<their key>/` link to it.
- At the end of a task, set the spec's `Status:` line to done with branch, PR, version and test count, and edit the body to describe what shipped. Keep the files.

## When a skill says "publish to the issue tracker"

Write the file under `.scratch/<JIRA-KEY>/`. Ask for the Jira key if there isn't one yet.

## When a skill says "fetch the relevant ticket"

Read the Jira issue for the requirement, and the files under `.scratch/<JIRA-KEY>/` for local specs and tickets.
