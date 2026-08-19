# Dropping nixpkgs pins

All nixpkgs pins are GONE (freecad unpinned 2026-08-13, kicad 2026-07-20); keeps the reusable method for proving a nixpkgs pin is safe to drop, incl. two traps that fake a green result.

**Status: no `nixpkgs-pinned` input exists any more.** kicad unpinned 2026-07-20; freecad unpinned 2026-08-13 (1.1.1 → 1.1.3), and the input, its `outputs` arg, the `specialArgs` inherit, and the overlay line were all removed. Remaining flake inputs are `nixpkgs` (unstable), `nixpkgs-master` (coding agents), `battui`. Note `nixpkgs-master` was called `nixpkgs-claude` until 2026-08-13, when codex joined claude-code on it; older notes using the old name are stale.

The rest of this file is the **method**, kept because it generalises to the next package that needs pinning.

**Why a pin is needed at all:** channels advance on a curated critical-jobs list, so unstable ships with leaf packages broken. Worse, a *fixed* dependency can immediately break its consumer (gdal got fixed, and the resulting `CSLConstList` constness change is what then broke vtk 9.5.2). "The fix landed" is never sufficient evidence: always check the actual consumer.

**Two traps that will fool a re-check:**
1. `nix eval` on the package exits 0 and `meta.broken` is `false` even when it cannot build. Evaluation proves nothing; the damage is build-time only. Use `nix build --no-link --dry-run` and read the **"will be built"** list.
2. Hydra `/latest-finished` can return **green from the pin's own eval**, concealing every later failure. Always fetch `hydra.nixos.org/eval/<id>` and confirm `jobsetevalinputs.nixpkgs.revision` is a rev *newer than the pin* (`git compare pin...rev` should say "ahead").

**Removal gate that worked (run in order):** (a) GitHub compare `nixos-unstable...<fix-rev>` says "behind" (unstable contains the fix); (b) Hydra buildstatus 0 for the broken *dependency*, on a post-pin rev; (c) Hydra buildstatus 0 for the *consumer*, on a post-pin rev; (d) `nix build --no-link --dry-run github:NixOS/nixpkgs/nixos-unstable#<pkg>` builds **0** derivations locally. (d) is the real gate.

**Testing trap:** a flake in a git repo evaluates git-*tracked* content only. Uncommitted edits to *tracked* files ARE seen (the "dirty" warning confirms it), but untracked files are invisible. To preview what `update-my-nix` will actually do, copy the `.nix` files + `flake.lock` to scratchpad *without* `.git`, run `nix flake update` there, then dry-build. Doing it in-place would either miss untracked files or leave the real lock bumped.

Apply via apply-config-with-update-my-nix.
