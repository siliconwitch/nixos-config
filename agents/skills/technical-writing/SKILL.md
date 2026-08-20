---
name: technical-writing
description: Concise technical prose for chat, documentation, READMEs, comments, commit messages, pull requests, and agent instructions. Use whenever writing or reviewing prose for engineers, including instructions and descriptions of current system behavior.
---

# Technical writing

Write for a tired engineer reading once.

- Cut every word that does no work. Use the shortest everyday word that stays precise.
- Use active voice, present tense, and concrete subjects.
- Name real files, symbols, flags, and commands. Use one name for each thing.
- Keep one thought or instruction per sentence. Put conditions before the action they govern.
- Use commands for procedures. Give every required action its own list item and self-contained command block.
- Use numbered lists for sequences and bullets for unordered sets.
- Make headings carry the point. Use sentence case.
- Prefer periods to semicolons. Never use an em dash.
- Avoid hype, filler, hedging, invented metaphors, agent narration, and claims of simplicity.
- State what the system does now. When documentation and code disagree, treat the documentation as wrong.
- Do not explain what the code or another document already makes clear.

For commits and pull requests, omit AI attribution and generated-by markers. Use a succinct title and a short body that says what changed and why. Add no section headers unless the project requires them.

For comments, describe a contract, constraint, or reason that the code cannot express. Do not narrate the edit or justify its history.

For agent instructions, keep always-loaded material minimal. Put task-triggered procedures in skills and make each skill description state its trigger conditions.
