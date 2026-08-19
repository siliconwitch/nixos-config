---
name: delegate
description: Hand implementation work to Codex (gpt-5.6 Sol) instead of burning Claude quota on it. Use for multi-file implementation, boilerplate, mechanical refactors, tests and migrations. Holds both delegation modes, the exact commands, and the rules for verifying the result. Trigger when handing off work to Codex, or when asked to delegate, or when a task is implementation rather than architecture, debugging or review.
---

# Delegate to Codex

Keep for yourself: architecture decisions, debugging, review, ultracode
orchestration. Hand off: multi-file implementation, boilerplate, mechanical
refactors, tests, migrations.

Pick one mode. Before running, say in one line what you are handing off, which
mode, and why.

## Fire-and-forget

The default, for one well-specified chunk of work.

1. Write a self-contained brief to `specs/task-<name>.md`. Codex cannot see
   the conversation: state the goal, files in scope, interfaces to match,
   constraints, definition of done.

2. Run:

    ```sh
    codex exec --sandbox workspace-write \
      "Read specs/task-<name>.md and implement it. Write a summary of
       changes and anything risky to specs/task-<name>.report.md." \
      > /tmp/codex-<name>.log 2>&1
    ```

3. Do not cat that log unless it fails. Use `git diff --stat` and the report
   only. Never read the full diff into context.

## Collaborative

For exploratory work, or when several rounds are likely.

1. Call `mcp__codex__codex` with sandbox `workspace-write`, approval-policy
   `never`, cwd at the repo root, a self-contained prompt, and these
   developer-instructions:

    ```
    Write all detail (reasoning, file-by-file changes, diffs) to
    notes/codex-<name>.md. Reply with at most 10 lines: what changed, what
    you're unsure about, what you need.
    ```

2. Keep the threadId and use `mcp__codex__codex-reply` for follow-ups.

3. Open the notes file only if the summary flags something.

## Both modes

- Verify by running the tests and the build, not by reading diffs. Review only
  what the report flags as risky.
- If it is wrong, sharpen the brief and re-delegate rather than fixing it
  yourself, unless the fix is small and contained.
- Do not override model defaults. One exception: `model_reasoning_effort`
  `"xhigh"` for a genuinely hard problem.
- Batch into one large brief rather than five small ones.
