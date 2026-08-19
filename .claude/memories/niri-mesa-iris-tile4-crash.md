# niri crashes from a Mesa iris Tile4 segfault

niri/app crashes under GPU load trace to a Mesa iris Tile4 segfault on Panther Lake; updated to Mesa 26.1.2 on 2026-06-10, watching under load.

Recurring crash on `mist` (Panther Lake, `xe` driver): under heavy GPU load — reproduced by **scrubbing a PDF**, fan maxing — the graphics stack faults. Coredump backtrace pinned it to **Mesa `iris`**, not niri: `linear_to_tile4_faster` → `_isl_memcpy_linear_to_tiled` → `iris_unmap_tiled_memcpy`, reached via niri's `GlesRenderer::import_shm_buffer` → `glTexImage2D` (uploading a client's software/SHM buffer into a Tile4 texture). The "Atomic Test failed for new properties on crtc" log spam is a separate `xe` KMS symptom of the same new-hardware immaturity.

On 2026-06-10 updated nixpkgs (flake) → **Mesa 26.1.1 → 26.1.2, kernel 7.0.10 → 7.0.11** (niri unchanged at 26.04) via apply-config-with-update-my-nix. Failure mode **shifted**: previously niri itself SIGSEGV'd and took down the session; after the update niri survives and only client apps die — progress, not a confirmed fix (Mesa 26.1.2 changelog names no matching iris fix).

**Status:** unproven under load — idle boots are clean (0 atomic/frame errors). If it crashes again under heavy GPU load, escalate: pin/forward Mesa (e.g. 26.2 when in unstable) or file upstream with the coredump. On hardware this new the fix usually runs *forward* (newer kernel/Mesa), not back to "stable". Related: [Built-in audio on Panther Lake](builtin-audio-broken-panther-lake.md), [Bluetooth wedges until a cold power cycle](panther-lake-bt-cold-boot-recovery.md).
