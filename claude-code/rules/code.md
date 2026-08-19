---
paths:
  - "**/*.{c,h,go,js,lua}"
---

# Structure

- **Functional.** Values in and values out, immutable inputs, no hidden global
  state. Where hardware or a library demands state, follow its style and keep
  that state private to the unit that owns it.
- **Procedural.** A long function that reads top to bottom is the goal, not a
  compromise. Never shorten or split a function while it stays procedural.
- **Guard clauses.** Handle errors and edge cases first and return early, so
  the happy path stays unindented.
- **Inline single use.** A constant used once is a literal at the point of
  use. Logic used once is written where it runs, never behind a function
  called from one place.

# Architecture

Three layers. Calls run 1 to 2 to 3 in that order, and never sideways within a
layer.

1. **Setup and run.** The entry point: `main.c`, `main.go`, the top level
   script. Calls each initialisation function, then starts the tasks. Holds no
   logic.
2. **Application logic.** One file per structural part of the system. The
   decision making lives here. Never split a module or abstract over it.
3. **Workhorse.** Drivers, protocol handling, and everything the decisions act
   through.

Helpers sit outside the layers: logging, error checking, and small self
contained utilities, callable from anywhere.

A module reaching for another module means the callee is really a layer 3
driver. Move it down instead of calling sideways.

# Co-location

Deleting a module file and its one line of wiring at the setup layer removes
that feature entirely.

Within a module file: callbacks and handlers at the top, initialisation next,
working logic at the bottom.

# Names and layout

- Meaningful names, never abbreviated: `plotWidth`, not `pw`. Short names only
  for loop indices, receivers, `err`, `ok`, and established mathematical
  notation.
- Group related statements into paragraphs with a blank line between them.
  Always a blank line before an error check.
- Never combine a call with its error test or its return.

# Comments

Write one only in these cases:

- A short single line heading breaking a long procedural function into
  sections. Says what the section is for, never how it works.
- A short inline note on a magic number:
  `i2c_write(0x12, 0x50); // LED_CFG0: 1A drive, active discharge enabled`
- One sentence on behaviour required by hardware or an external contract that
  cannot be seen in the code: a settling time, an erratum, a protocol ordering
  constraint.
- A block explaining unreadable or highly optimised code, prefixed
  `// IMPORTANT:`. Never write one unless asked, and never remove or reword
  one unless asked.

In code you are already editing, delete every other comment and replace it
with self describing code. Leave vendored code and untouched files alone.

# Tests

- Table driven: input to expected case, iterated in a loop. Never repeated
  near-identical assertions.
- Test the failure path, not only the completed operation.
- Never split a function or create single use code to make it testable. Test
  the logic as a block.
- Invented neutral identities in fixtures. Never a real name, address,
  credential or customer record.

# Dependencies

- No dependency for simple or single use logic.
- Never hand roll security, encryption, or a parser of untrusted input. A
  robust, well tested library belongs there.
- A dependency is right for a moving standard its maintainer tracks better
  than we can.
- Nothing a distribution's packager would balk at. Evaluate a candidate by
  running it, never from memory of how it behaves.
