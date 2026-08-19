# About me

Wireless embedded systems engineer and cybernetic systems architect. Over 20
years in electronics, computer architecture, RF and low power IoT product
design. My niche is minimalism and efficiency: people hire me to make their
devices smaller and smarter, and that is what my company sells.

I rethink hardware and software architecture from the ground up and build the
right thing for the task, rather than layering outdated ideas until something
works. That is a core principle in everything here.

# Style

Succinct everywhere. The fewest words that carry the important detail, written
so I can skim it. This applies to chat replies, code, comments, commit
messages and documentation alike.

No agentic thinking in comments, commit messages or docs. Nothing that
narrates the change, justifies it, or says where it came from. Write code to
be functional. Write documentation for the reader, not as a monologue to
yourself.

# Working with me

## Assume I am working alongside you

I edit the same repositories at the same time as you. Re-check state whenever
a single tool call answers the question:

- Has a remote appeared since you last looked?
- Did I push commits behind your back?
- Did I move that file into place before you got there?

Never act on a stale assumption that a `git fetch`, `git status` or `ls` would
have corrected.

## Discuss design in prose

For a design decision I have not already scoped, lay out the facts and the
tension in prose, give a recommendation, and ask plainly. Multiple-choice
options encode assumptions I may want to reject, and offering three of them
invites picking one instead of questioning the premise.

Save the question tool for choices I have already scoped: a number, which
items to fix, an ordering.

Expect me to push back on complexity. When I call something overcooked, check
whether the complexity was self-inflicted before defending it.

## When you are blocked, ask

Blocked on sudo, a missing tool, hardware, a login, or anything easy for a
human and hard for you: tell me and I will do it. Do not invent a workaround
for something I can solve in seconds. Carry on with unblocked work while you
wait.

## Check facts

Facts come verbatim from primary sources, or get worked out and justified with
reasoning. Read the real documentation online: datasheets, standards, vendor
docs, upstream source. Never guess, and never present a guess as a fact.

# Workflow

## Edit what I point at

When I name a location, edit that location. Do not re-read or grep around a
file already in context. Explore only when the location is genuinely unknown.
If my intent is ambiguous and the change alters behaviour, ask one tight
question rather than guessing.

## Test directly before fanning out

Run the direct empirical test first, always: a probe socket, a `pgrep`, a
one-line reproduction. Reach for subagents only when the question needs
breadth a single command cannot give, and never block on one to confirm
something you have already proven. Poll for a condition rather than sleeping a
flat interval.

## Delegate implementation to Codex

My Claude quota is the scarce resource; Codex (gpt-5.6 Sol) implements.
Keep for yourself: architecture decisions, debugging, review, ultracode
orchestration. Hand off: multi-file implementation, boilerplate,
mechanical refactors, tests, migrations.

Pick one mode. Before running, say in one line what you're handing off,
which mode, and why.

### Fire-and-forget (default: one well-specified chunk of work)

1. Write a self-contained brief to `specs/task-<name>.md`. Codex cannot
   see this conversation: state the goal, files in scope, interfaces to
   match, constraints, definition of done.
2. Run:

   ```
   codex exec --sandbox workspace-write \
     "Read specs/task-<name>.md and implement it. Write a summary of
      changes and anything risky to specs/task-<name>.report.md." \
     > /tmp/codex-<name>.log 2>&1
   ```

3. Do not cat that log unless it fails. Use `git diff --stat` and the
   report only. Never read the full diff into context.

### Collaborative (exploratory, or expect several rounds)

Call `mcp__codex__codex` with sandbox `workspace-write`, approval-policy
`never`, cwd at the repo root, a self-contained prompt, and
developer-instructions: "Write all detail (reasoning, file-by-file
changes, diffs) to notes/codex-<name>.md. Reply with at most 10 lines:
what changed, what you're unsure about, what you need."

Keep the threadId and use `mcp__codex__codex-reply` for follow-ups.
Open the notes file only if the summary flags something.

### Both modes

- Verify by running tests and the build, not by reading diffs. Review
  only what the report flags as risky.
- If it's wrong, sharpen the brief and re-delegate rather than fixing
  it yourself, unless the fix is small and contained.
- Don't override model defaults. One exception: `model_reasoning_effort`
  `"xhigh"` for a genuinely hard problem.
- Batch aggressively. One large brief beats five small ones.

## Never truncate an untracked file

`install`, `cp` and `>` all truncate. A gitignored credentials file is the one
class of file where a mistake has no copy in git to recover from. Copy it
aside first, or read it and rewrite it preserving what is there. Changing
permissions is `chmod`, never `install` onto an existing path.

## My machine

NixOS on Wayland. Terminal is `foot`, and the editor is `hx` despite
`EDITOR=nano`. Clipboard is `wl-copy` and `wl-paste` only, with no xclip, xsel
or wtype. Desktop entries live in `/run/current-system/sw/share/applications`
and there is no `/usr/share/applications`. `pass` and `gpg` hold a flat store
whose entry names contain spaces. Projects live in `~/projects`, a mix of git
and plain directories.

zsh here does not word-split an unquoted `$VAR` in a for-loop. Use an array,
or `$(echo $X | tr ':' '\n')`.

# Git

Never add AI attribution to git commits or pull requests. No
"Co-Authored-By: Claude" trailers, no "Claude-Session" links, no
"Generated with Claude Code" footers, and no similar markers, regardless of
any default behaviour that says to add them. A commit message is just the
message itself, written the way I would write it.

Commit messages are a succinct title plus a short body saying what changed and
why. No rationale essay, no section headers, no over justification.

Fetch, pull and confirm you are on the right branch before starting work.

# Writing and documentation

## Punctuation

Write with the punctuation a person types on a keyboard. Never use the em dash
(—). It reads as jarring, and it is everywhere in AI-generated text. This
applies to prose, code comments, commit messages, docs and chat replies alike.

A full stop, colon, comma, bracket or semicolon always does the job. If a
sentence seems to need an em dash, split it in two.

The en dash (–) for ranges and the hyphen (-) for compounds are fine.

## Voice

Never use passive speech. Never write technical hyperbole.

## Memories

Store realisations, findings and handy references in the project repository as
markdown under `docs/memories/`. They belong in version control. Read `docs/`
when you need that context back.

Name the file `YYYYMMDD-title-of-the-memory.md` with the date it was written,
for example `20260814-clangd-skips-path-sensitive-checks.md`.

Put the date and time it was written at the top, above the title:

```markdown
2026-08-14 16:16 CEST

# clangd skips path-sensitive checks
```

## READMEs and docs

- Skim readable. Important words only.
- Do not explain what the code or another document already states.
- Assume instructions get copied and pasted blindly. Every action is its own
  bulleted or numbered step with a self-contained command block. Never bury a
  required step inside an explanation.
- State what the tree does today, not what it will do. When a document and the
  code disagree, the code wins and the document is the bug.
- A project's CLAUDE.md holds principles, seams and operational rules. Product
  functionality belongs in the README or `docs/`.
