---
paths:
  - "**/*.{c,h}"
  - "Makefile"
  - "**/Makefile"
  - "**/*.mk"
  - "**/*.ld"
---

# C

- Fixed width integer types. Buffer ownership, capacity and encoded length
  stay visible at every boundary, never inferred from one another.
- Check every return value from the kernel, filesystem, flash, crypto, radio
  and hardware libraries. Timeouts, short reads and writes, malformed frames
  and exhausted storage are ordinary states.
- Bounded memory. Prefer static storage and fixed capacity queues. Dynamic
  allocation needs a demonstrated bound and a failure path.
- No undefined behaviour: no uninitialised reads, out of bounds access, signed
  overflow, invalid shifts, unchecked narrowing, dangling pointers or races.
- Keep interrupts short. Share data across interrupt and thread contexts only
  through an explicit synchronisation primitive.

# Build tooling

`make` is the only mechanism. The full warning set and `-fanalyzer` live in
the compile rule for first-party code, so every build is the analysis run.
`make` generates `compile_flags.txt` from its own flags to feed clangd.
Formatting is the editor's job on save. Never add a make target for
formatting, linting or a compile database.

Keep first-party code strict and vendored code quiet, with `-w` and `-isystem`
for the vendored tree.

Traps proven the hard way, so do not relearn them:

- `gcc -fanalyzer -fsyntax-only` analyses nothing and exits 0. `-fanalyzer`
  needs a real `-c` compile.
- `clangd --check` prints errors only. It reports zero errors on a file that a
  live LSP session floods with warnings, so validate diagnostics with a real
  didOpen session.
- clangd does not run path-sensitive `clang-analyzer-*` even when
  `.clang-tidy` lists it. The editor cannot catch what `-fanalyzer` catches.
- A rule above `all:` steals the default goal. Keep `$(OBJECTS): Makefile` and
  `-include *.d` at the bottom of the Makefile. Target-specific variable
  assignments are fine anywhere.
- Per-object compiling needs `-MMD -MP` and `-include $(OBJECTS:.o=.d)`, or a
  header edit yields a stale binary that `make flash` happily programs.
- Keep the check list in `.clang-tidy` alone. `.clangd` does CompileFlags
  only, and its `ClangTidy: Add:` re-enables globs that `.clang-tidy` negates.
- `bugprone-reserved-identifier` fires on linker symbols such as `__bss_end`
  and `__STACK_BASE`. Negate it, because the linker script and the vendor MDK
  dictate those names.

# Testing on hardware

For hardware-touching code, write tests that drive the real device or the real
output rather than asserting on intermediate bytes. A printed label proves
more than the PDF bytes behind it.

These tests have physical side effects, so never run them yourself. Build and
vet to prove they compile, and leave the run to me on the bench.
