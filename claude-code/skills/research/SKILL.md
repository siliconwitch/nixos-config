---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Look for a local copy first: a vendored datasheet, `docs/`, `.claude/memories/`, or a submodule's own headers. Only then go online.
2. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
3. Write the findings to a single Markdown file, citing each claim's source, and label anything unverified.
4. Save it to `.claude/memories/YYYYMMDD-title-of-the-memory.md`, with the date and time above the title. Promoting it to `docs/` is a separate, deliberate move.
