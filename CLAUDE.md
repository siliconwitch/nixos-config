# NixOS configuration

`configuration.nix` and the modules it imports describe the complete,
reproducible system. A broken config means a broken boot or lost data, so work
through this before every change and every recommendation.

## Before changing anything

- Read `configuration.nix` and every module it imports.
- Verify each option and package attribute at https://search.nixos.org. Never
  assume either exists.
- Cross-reference the official manual or wiki, and search for current practice,
  before recommending anything.
- Lay out the change and its alternative in prose, then confirm with me before
  writing.

## After changing anything

- Run `nixos-rebuild dry-build` and fix what it reports.
- Ask me to run `nixos-rebuild switch`. This system uses sudo and you cannot.
- Offer `nixos-rebuild test` to trial a risky change without making it the boot
  default, and say that the previous generation is in the GRUB menu.
- Say when a change needs a reboot to take effect. Confirm the live system
  matches the config once it is applied.

## Constraints

- `hardware-configuration.nix` is machine generated and machine specific. Never
  edit it by hand or copy it between machines.
- Declarative only. No imperative one-off changes through the shell.
- The config holds nothing that is not necessary.
- Flat, readable `configuration.nix` entries beat nested modules. Split a
  section out only once its size justifies it.
- No usernames or machine-specific values in shared modules.

## Documentation

Start here, then search further. Add a link when a new tool arrives, and remove
one when a tool goes.

- NixOS manual: https://nixos.org/manual/nixos/stable/
- Options: https://search.nixos.org/options
- Packages: https://search.nixos.org/packages
- Wiki: https://wiki.nixos.org
- Niri: https://niri-wm.github.io/niri/
- Wayland: https://wayland.freedesktop.org
