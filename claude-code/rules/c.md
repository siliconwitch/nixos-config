---
paths:
  - "**/*.{c,h}"
  - "Makefile"
  - "**/Makefile"
  - "**/*.mk"
  - "**/*.ld"
---

# C

- Check every return value from the kernel, filesystem, flash, crypto, radio
  and hardware libraries. Timeouts, short reads and writes, malformed frames
  and exhausted storage are ordinary states.
- Avoid the preprocessor. `#define` is for hardware pin numbers and physical
  addresses, nothing else. A macro is correct only where a function cannot do
  the job, such as capturing the call site:
  `#define ERROR_CHECK_NON_ZERO(e) error_check_non_zero(e, __FILE__, __LINE__)`

# Memory safety

CERT C at https://cmu-sei.github.io/secure-coding-standards is the reference
for undefined behaviour and memory safety. Cite the rule ID when one applies,
such as `INT30-C` for unsigned wraparound.

- Bounded memory. Prefer static storage and fixed capacity queues. Dynamic
  allocation needs a demonstrated bound and a failure path.
- Fixed width integer types: `uint32_t`, never `unsigned long`.
- Ownership, capacity and encoded length are three separate facts, and all
  three stay visible at every boundary. Never infer one from another. A buffer
  crosses as a pointer plus its capacity, and the call reports how many bytes
  it actually wrote.
- Bounded calls at every boundary: `strnlen` over `strlen`, a checked length
  on every copy, no unbounded read or write.
- No undefined behaviour: no uninitialised reads, out of bounds access, signed
  overflow, invalid shifts, unchecked narrowing, dangling pointers or races.

# Build tooling

`make` is the only mechanism. The full warning set, `-Werror` and `-fanalyzer`
live in the compile rule for first-party code, so every build is the analysis
run. Set those up when standing up a new project, and never loosen what an
existing project already checks. Keep vendored code quiet with `-w` and
`-isystem` so it cannot dirty our diagnostics.

`make` generates `compile_flags.txt` from its own flags to feed clangd.
Formatting is the editor's job on save. Never add a make target for
formatting, linting or a compile database.

Traps proven the hard way, so do not relearn them:

- `gcc -fanalyzer -fsyntax-only` analyses nothing and exits 0. `-fanalyzer`
  needs a real `-c` compile.
- `-fanalyzer` cannot see through a naked function that returns in r0, so
  branching on its return raises a false
  `-Wanalyzer-use-of-uninitialized-value`. Suppress it for that object only,
  never globally.
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

# Debugging on hardware

`make debug` programs the device, starts `JLinkGDBServerCLExe` over SWD,
captures RTT to `build/rtt.log`, and attaches GDB. `make rtt` tails that log
from a second terminal.

- `hbreak` only. A software `break` writes into RRAM and corrupts the flashed
  image.
- J-Link does not find the RTT control block on its own. Resolve `_SEGGER_RTT`
  with `nm` on the elf and hand it over with `monitor exec SetRTTAddr`.
- Programming a SoftDevice build takes two passes: the SoftDevice hex with
  `chip_erase_mode=ERASE_ALL`, then the application with `ERASE_NONE`. One
  ERASE_ALL pass carrying the application alone wipes the stack.
- `make recover` unlocks and erases a part with read-back protection on.

For hardware-touching code, write tests that drive the real device or the real
output rather than asserting on intermediate bytes. A printed label proves more
than the PDF bytes behind it.

Run the hardware yourself: `make debug`, the probe, the RTT log. Stop and ask
first when a change could do something physical that reflashing cannot undo.
Spinning a motor or actuator, reconfiguring a PMIC rail or charger, driving a
pin whose external circuit you have not checked, or erasing storage holding
calibration or credentials all need a human to look before the board is
powered.

# Documentation

- Look for a local copy before downloading anything: a vendored datasheet, a
  `docs/` directory, the project memories, or a submodule's own headers.
- Raw text extraction from a PDF loses row and column association. Before
  treating a pin number, register field or timing figure from a table or
  diagram as fact, confirm it with a second method such as rendering the page
  to an image.
