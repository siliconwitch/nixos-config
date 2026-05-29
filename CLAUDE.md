# Claude Guidelines

This project contains a NixOS system configuration. `configuration.nix` and any imported modules describe the complete, reproducible system state.

Your role is to help the user build their system and maintain their configuration in a structured way.

## IMPORTANT: Diligence Chain

It is critical that all configuration files resolve to a functioning, reproducible system with a high level of integrity. Failure to do so may result in a broken system, or permanent data loss for the user.

NEVER MAKE CHANGES OR GIVE RECOMMENDATIONS WITHOUT FOLLOWING THESE GUIDELINES.

0. ALWAYS present a range of options and confirm with the user before making any changes to config files. Never implement a single solution unilaterally — let the user steer the direction.
1. ALWAYS read `configuration.nix` and all imported modules to understand the current system configuration before suggesting changes.
2. NEVER assume a NixOS option exists without verifying it. Check `search.nixos.org` or the NixOS manual before recommending any option.
3. NEVER assume a package attribute name is correct. Verify package names at `search.nixos.org/packages` before using them.
4. ALWAYS search for up to date solutions and standard practices online before making any recommendation or suggesting changes.
5. ALWAYS cross-reference official online documentation before making recommendations or suggesting changes.
6. After making changes, always verify the config evaluates cleanly with `nixos-rebuild dry-run` before asking the user to apply with `nixos-rebuild switch`.
7. `hardware-configuration.nix` is machine-generated and machine-specific. Never edit it manually or copy it between machines.
8. NixOS generations act as the rollback mechanism. If a change may be risky, remind the user that the previous generation is available in the GRUB menu.
9. This system uses `sudo`. Never try to run sudo commands. Ask the user to run it.
10. This system uses systemd.

## Minimalism

Minimalism is key for this project. The configuration should contain nothing that isn't absolutely necessary.

Split configuration into focused modules only when a section becomes large enough to justify it — avoid premature abstraction. Prefer flat, readable `configuration.nix` entries over deeply nested module structures.

Avoid hardcoding usernames or machine-specific values in shared modules. Keep `hardware-configuration.nix` separate and machine-specific.

## NixOS Principles

- **Declarative**: the desired system state is fully described in the config — avoid imperative one-off changes via the shell.
- **Reproducible**: a fresh `nixos-install` from this config should produce the same system on any compatible machine.
- **Generations**: every `nixos-rebuild switch` creates a new generation. Use `nixos-rebuild test` to trial changes without making them the boot default.

## System Integrity

After a set of changes, verify the live system reflects the config — options that require a reboot won't take effect until one is performed.

## Useful Links

These links are provided to give quick access to commonly required documentation.

Don't solely rely on this documentation, and be sure to make additional searches.

As new documentation is discovered for any complex installed tools, add their links below. If tools are no longer used, remove them from this list.

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **NixOS Options**: https://search.nixos.org/options
- **Nixpkgs**: https://search.nixos.org/packages
- **NixOS Wiki**: https://wiki.nixos.org
- **Niri**: https://github.com/niri-wm/niri/wiki
- **Wayland ecosystem**: https://wayland.freedesktop.org
