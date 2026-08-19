# Config declared final

Raj declared the NixOS config feature-complete on 2026-08-13; the only sanctioned pending change is linuxPackages_testing → linuxPackages_latest when 7.2 stable lands.

On 2026-08-13 Raj declared the config **final**: "assume this is my final config. There should be no placeholders or leftover things." The single sanctioned pending change is `boot.kernelPackages = pkgs.linuxPackages_testing` → `linuxPackages_latest` once 7.2 stable reaches nixpkgs (it was 7.1.8 on that date). That one TODO comment in configuration.nix is deliberate and should stay until it fires.

**Why:** he wants the repo to read as a finished artifact, not a work in progress.

**How to apply:** do not add speculative options, commented-out alternatives, "might want later" entries, or TODO markers. When a workaround's drop condition is met, remove the workaround *and* its comment in the same change rather than leaving a note. Verified-clean invariants as of that date, worth re-checking before claiming the config is tidy: no em dashes anywhere (his global style rule), no trailing whitespace, no TODO/FIXME markers, no dead package references.

Two things that LOOK like leftovers but are deliberate, do not "clean" them:
- `initialPassword = "changeme"` in configuration.nix is the documented fresh-install bootstrap (README step 8 says run `passwd`). Removing it leaves a new install unable to log into greetd.
- `placeholder_text =` in hypr/hyprlock.conf is a hyprlock option name set intentionally empty, not a stub.

See [Dropping nixpkgs pins](nixpkgs-pinned-freecad-kicad.md) for the method used to prove a pin/workaround is safe to delete.
