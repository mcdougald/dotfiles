---
description: Review the current branch's diff against the default branch
agent: build
subtask: true
---

Diff to review:

!`git diff $(git merge-base HEAD origin/HEAD 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD~1)...HEAD`

Hand this diff to the `review` subagent and report only findings that survive
verification, most severe first. If it comes back clean, say so in one line.

$ARGUMENTS
