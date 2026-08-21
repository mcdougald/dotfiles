---
description: Stage and commit the current changes as one or more Conventional Commits
agent: build
---

Current state:

!`git status --short`

Staged diff:

!`git diff --cached --stat`

Unstaged diff:

!`git diff --stat`

Recent commit style to match:

!`git log --oneline -10`

Group the changes into the smallest set of coherent commits — one concern per
commit — and commit them as Conventional Commits (`type(scope): summary`,
imperative mood, no trailing period, subject under 72 characters). Add a body
only when the *why* is not obvious from the diff.

Do not push. Do not amend existing commits. If something in the working tree
looks unintentional (debug prints, stray files, secrets), stop and say so
instead of committing it.

$ARGUMENTS
