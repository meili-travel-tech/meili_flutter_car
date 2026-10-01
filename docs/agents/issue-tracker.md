# Issue tracker: local markdown

Jira holds the tickets. Specs, implementation tickets, notes and QA scripts produced by the agent skills are local, gitignored markdown in `.scratch/` at the root of the Meili native workspace (`ux-native-agents`), shared by every repo under `repositories/`; they never go into git or Jira. From a repo under `repositories/`, that folder is `../../.scratch/`. Outside the workspace, use this repo's own `.scratch/`.

## Conventions

- One directory per Jira ticket, whichever repos the change touches: `.scratch/<JIRA-KEY>/` (for example `.scratch/MPD-11466/`).
- The spec is `.scratch/<JIRA-KEY>/spec.md`. Implementation tickets are one file each at `.scratch/<JIRA-KEY>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order, never a single combined file. When a ticket spans repos, start each slug with its platform (`03-ios-phone-from-residency.md`), and suffix any other per-platform file the same way (`qa-android.md`).
- Each ticket file carries a `Status:` line and a `Blocked by:` line near the top.
- Comments and conversation history append under a `## Comments` heading.
- Sibling Jira tickets (one per platform) each get their own directory; the spec names its siblings by key, and a sibling that shares a spec holds only a `README.md` naming the key whose directory has it.
- At the end of a task, set the spec's `Status:` line to done with branch, PR, version and test count, and edit the body to describe what shipped. Keep the files.

## When a skill says "publish to the issue tracker"

Write the file under the workspace's `.scratch/<JIRA-KEY>/`. Ask for the Jira key if there isn't one yet.

## When a skill says "fetch the relevant ticket"

Read the Jira issue for the requirement, and the files under the workspace's `.scratch/<JIRA-KEY>/` for local specs and tickets.
