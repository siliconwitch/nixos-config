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

# Coding rules

## Structure

- **Functional and stateless.** Pure means values in and values out, with
  immutable inputs and no hidden global state. It does not mean small, so
  never split a function to make it purer. Where a library or hardware demands
  state, follow its style and keep that state private to the unit that owns
  it.
- **Procedural.** Long sequences of operations in one function are fine, and a
  long pure function is the goal rather than a compromise. Reading one top to
  bottom should describe its whole behaviour.
- **Inline single use code.** A function called once should not exist. Nor
  should a 1 to 3 line helper, unless it wraps something likely to change,
  such as a hardcoded path.
- **Guard clauses.** Handle errors and edge cases first and return early, so
  the happy path stays unindented and reads straight down.
- **Switch over ladders.** Prefer a `switch`, including a type switch, to a
  long `if` / `else if` chain.
- **Co-location.** A self-contained unit lives in one file: its types, state,
  behaviour and rendering together. Its only reference elsewhere is one line
  of wiring at the composition root. Deleting the file and that line removes
  it entirely.
- **Exact scope.** Build what I asked for. Offer an extra option, input shape
  or mechanism as a choice instead of building it.
- **No assumptive defaults.** A required input is required. Reject a missing
  or invalid value and say what it takes. Never guess what I probably meant.

## Names and layout

- Full descriptive names for functions and variables: `plotWidth`, not `pw`.
- Short names only for loop indices, receivers, `err`, `ok`, established
  mathematical notation, and a framework's own idiom: `w` for an
  `http.ResponseWriter`, `r` for an `*http.Request`. Keep those reserved for
  that exact type. A reader that is not an `*http.Request` is `reader`.
- Breathing room. A blank line between a call and its error check. Never
  combine a call with its error test or its return. Group code into
  paragraphs.

## Comments

Two reasons to write one, and nothing else:

1. The behaviour is not clear or intuitive from reading the code: a hardware
   quirk, a protocol, an external contract. One short sentence per line of
   logic.
2. A one line heading breaking a long procedural function into sections. A
   plain sentence with no `Step:` prefix, saying what the section below is
   for, never how it works.

Never restate what the code does. Struct tags are not comments.

## Tests

- Table driven: input to expected case, iterated in a loop. Never repeated
  near-identical assertions.
- Test the failure path, not only the completed operation.
- Invented neutral identities in fixtures. Never a real name, address,
  credential or customer record.

## Dependencies

Keep the set small. Nothing a distribution's packager would balk at.

Correctness outweighs count. For load-bearing logic a robust, well-tested
library beats hand-rolled code, and a substantial dependency is fine there.
Evaluate candidates by running them, never from memory of how they behave.
Keep hand-written code for the thin glue a library cannot cover. In Go prefer
pure Go, so `CGO_ENABLED=0` static builds keep working.

# TUIs

Primary labels get the default terminal foreground. Muted tones are for
secondary text only, and grid lines and borders stay subdued. I find dim text
hard to read, so never introduce a new dim style for anything I have to read.

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
