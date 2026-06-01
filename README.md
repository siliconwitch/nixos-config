# nixos-config

My NixOS system configuration **and** dotfiles, in one repo.

## Layout

- **Nix defines the OS** — `configuration.nix` (+ machine-generated
  `hardware-configuration.nix`) describes the system and installs all packages.
- **App config stays as traditional dotfiles** — `niri/`, `foot/`, `mako/`,
  `zsh/`, `wallpaper.jpg`. No Home Manager; edit these directly and they take
  effect (apps reload them), the way their own docs describe.

The repo is cloned **as `~/.config`**, so the dotfiles land where apps look and
need no symlinking. The Nix files live alongside them at the repo root.

## Install (real machine)

1. Boot the live ISO (built with `nix build .#iso`, then `dd` to a USB).
2. Partition/mount the disk, then:
   ```
   sudo nixos-generate-config --root /mnt        # writes hardware-configuration.nix
   git clone <this repo> /mnt/home/raj/.config
   # move the generated hardware-configuration.nix into the repo,
   # add a host entry to flake.nix (configuration.nix + UEFI bootloader)
   sudo nixos-install --flake /mnt/home/raj/.config#<host>
   ```

## Day to day

- Edit dotfiles in `~/.config/<app>/` directly — live, no rebuild.
- `update` (zsh alias) → `nix flake update` + `nixos-rebuild switch` (latest).
- Broke something? Pick the previous generation in the boot menu.

## Testing (throwaway, delete when the real machine is ready)

- **VM**: `vm.nix` — the repo is shared in at `/etc/nixos` over 9p; rebuild with
  `sudo nixos-rebuild switch --flake /etc/nixos#vm`. Console only (the VM's
  virtio-gpu can't run niri); use it for OS/build checks.
- **ISO**: `iso.nix` — `nix build .#iso`. Tests the OS + that niri starts on
  real hardware. (Your dotfiles aren't baked into it — those are validated on
  the real install.)
