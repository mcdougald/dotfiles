# Global agent instructions

Loaded by opencode for every session (`~/.config/opencode/AGENTS.md`). Repo-level
`AGENTS.md` / `CLAUDE.md` files layer on top of this and win on conflict.

## Working style

- Read before you write. Locate the existing pattern and match it — naming,
  comment density, error handling, file layout.
- Smallest change that solves the stated problem. Do not refactor adjacent code,
  rename things, or "clean up" unless that was the request.
- Finish the whole task. If part of it is blocked, complete the rest and say
  plainly what was left out and why.
- Prefer the repo's own tooling (`make`, `just`, `mise`, package scripts) over
  ad-hoc commands.

## Verification

- After substantive edits, run the project's tests, type checker, or linter.
- Report results honestly. If tests fail, paste the failure; never claim a green
  run you did not see.
- Do not add a dependency without saying why the stdlib or an existing dep will
  not do.

## Boundaries

- Never commit, push, or open a PR unless asked.
- No secrets, tokens, or production data in code, logs, comments, or commits.
  Read them from the environment.
- Confirm before anything destructive or irreversible: force pushes, history
  rewrites, deletes, schema migrations, deploys.
- Ambiguous product behaviour is a question, not a guess.

## Style

- Comments explain *why*, not *what*. Skip them where the code is obvious.
- Conventional Commits for commit messages: `type(scope): summary`.
- Keep responses short. Show the diff and the command output, not a narration
  of them.
