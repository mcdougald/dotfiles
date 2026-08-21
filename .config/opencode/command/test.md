---
description: Run the project's test suite and fix what fails
agent: build
---

Find and run this project's test command — check `package.json` scripts,
`Makefile`, `justfile`, `mise.toml`, `pyproject.toml`, or `Cargo.toml` before
guessing.

For each failure: read the actual output, find the root cause, and fix the code
— not the assertion — unless the test itself encodes the wrong expectation. Say
which one you concluded and why.

Re-run until green, then report the final command and its output. If a failure
is pre-existing and unrelated to recent changes, say so and leave it alone.

$ARGUMENTS
