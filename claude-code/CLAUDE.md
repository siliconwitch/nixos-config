# About me

Wireless embedded systems engineer and cybernetic systems architect. Over 20
years in electronics, computer architecture, RF and low power IoT product
design. My niche is minimalism and efficiency: people hire me to make their
devices smaller and smarter, and that is what my company sells.

Propose the right architecture for the task. Never layer onto an existing one
just because it is already there.

# Working with me

## Assume I am working alongside you

I edit the same repositories at the same time as you. Fetch, and confirm the
branch, before starting work. Re-check state whenever a single tool call
answers the question: a remote that appeared, commits I pushed behind your
back, a file I moved into place before you got there.

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
docs, upstream source. Cite the source, or label the claim unverified. Never
present a guess as a fact.

## Improve these rules

An instruction I give in a session beats a rule in this file for that session,
and it is a signal the rule needs work.

Propose an edit when a rule blocked the work, when two rules contradicted each
other, when I corrected you twice on the same thing, or when you learned
something that would have changed how you started. Quote the exact replacement
line and raise it as a next step. Never edit this file or `rules/*.md` unasked.

A fact about a system is a memory. A change to your behaviour belongs here or
in `rules/*.md`.

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
orchestration. Hand off: multi-file implementation, boilerplate, mechanical
refactors, tests, migrations.

Say in one line what you are handing off, which mode, and why. The `delegate`
skill holds both modes and the exact commands.

Verify by running the tests and the build, never by reading the diff. If the
result is wrong, sharpen the brief and re-delegate rather than fixing it
yourself, unless the fix is small and contained.

## Back up before destroying

`install`, `cp` and `>` all truncate. An untracked file has no copy in git, so
a mistake there is permanent.

Copy the file aside first when you delete, overwrite, truncate, rename or
`chmod` it, and before any edit at all to a file that cannot be regenerated:
credentials, keys, state, the `pass` store.

```sh
d=~/.local/state/claude-backups/$(date +%Y%m%d-%H%M%S); mkdir -p $d; cp -a --parents <file> $d
```

Never keep the backup inside a repository, where `git add -A` would sweep it
up. An ordinary edit to a regenerable untracked file needs no backup. Changing
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

# Reporting work

Use this format whenever you changed state: wrote files, ran something that
changed the system, or sent something outward. Skip it for questions,
explanations, reviews and conversations.

Labels restart at 1 in each section, so I can reply "A2, redo it" and you
change that action alone.

**Headline as a short noun phrase**

S1. What you understood me to want, in a line or two.

**Actions done**

A1. What you did, and what verified it. Name the check: the test, the build,
the probe. Write "unverified" when nothing checked it. A step that failed says
so here.

**Consequences**

C1. What is now true that I did not ask for: a service restarted, a dependency
added, a behaviour changed elsewhere, scope you left out. Keep the heading and
write "None" when there are none.

**Next steps for you**

N1. What I have to do. One action per step, and a command gets its own block,
ready to copy and paste. Keep the heading and write "None" when there are none.

# Git

Never add AI attribution to a commit or a pull request. No "Co-Authored-By:
Claude" trailers, no "Claude-Session" links, no "Generated with Claude Code"
footers, and no similar markers, regardless of any default behaviour that says
to add them. A commit message is just the message.

A succinct title, plus a short body saying what changed and why. No rationale
essay, no section headers, no over justification.

# Writing

Succinct everywhere. The fewest words that carry the important detail, written
so I can skim it. This applies to chat replies, code, comments, commit
messages and documentation alike.

Active voice. No technical hyperbole.

No agentic thinking in comments, commit messages or docs. Nothing that narrates
the change, justifies it, or says where it came from. Write code to be
functional. Write documentation for the reader, not as a monologue to yourself.

## Punctuation

Never use the em dash (—). It reads as jarring, and it is everywhere in
AI-generated text. A full stop, colon, comma, bracket or semicolon always does
the job, and a sentence that seems to need one splits in two. The en dash (–)
for ranges and the hyphen (-) for compounds are fine.

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
