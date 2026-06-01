# nixos-config

My NixOS system configuration **and** dotfiles, in one repo. Machine: **storm**.

## Layout

- **Nix defines the OS** — `configuration.nix` (+ machine-generated
  `hardware-configuration.nix`) describes the system and installs all packages.
- **App config stays as traditional dotfiles** — `niri/`, `foot/`, `mako/`,
  `zsh/`, `git/`, `helix/`, `fastfetch/`, `hypr/`, `pipewire/`, `wallpaper.jpg`.
  No Home Manager; edit these directly and they take effect (apps reload them),
  the way their own docs describe.

The repo is cloned **as `~/.config`**, so the dotfiles land where apps look and
need no symlinking. The Nix files live alongside them at the repo root.

## Install (machine: storm)

A minimal-ISO install with LUKS full-disk encryption, then a switch to this
flake. The disk is encrypted; swap is compressed RAM (zram), nothing on disk.

### 1. Flash the installer

Download the **Minimal ISO** (64-bit Intel/AMD) from
<https://nixos.org/download/#nixos-iso>, then write it to a USB stick (find the
device with `lsblk` — this erases it):

```
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot the stick.

### 2. Partition + encrypt

UEFI / GPT: a 1 GB EFI partition and a LUKS container for the rest. Adjust
`/dev/nvme0n1` to your disk (`lsblk`); with `cfdisk`/`parted` make `p1` = 1 GB
EFI System and `p2` = the remainder. Then:

```
cryptsetup luksFormat /dev/nvme0n1p2          # set the disk passphrase
cryptsetup open       /dev/nvme0n1p2 cryptroot
mkfs.ext4 -L nixos /dev/mapper/cryptroot
mkfs.fat -F32 -n boot /dev/nvme0n1p1
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot && mount /dev/disk/by-label/boot /mnt/boot
```

You'll type this LUKS passphrase at every boot.

### 3. Minimal install (a booting base)

```
nixos-generate-config --root /mnt     # auto-detects LUKS → writes the luks device
```

In `/mnt/etc/nixos/configuration.nix`, enable the UEFI bootloader:

```
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

Then install and reboot:

```
nixos-install        # prompts for the root password
reboot
```

### 4. Switch to this config

Log in as `root` on the freshly booted system:

```
nix-shell -p git
git clone https://github.com/<you>/<repo> /root/storm    # use git@… if private
cp /etc/nixos/hardware-configuration.nix /root/storm/     # storm's, with the luks device
nixos-rebuild switch --flake /root/storm#storm \
    --extra-experimental-features 'nix-command flakes'
reboot
```

(The `/root/storm` clone is only for this first switch — flakes aren't enabled
yet on the base system, hence the flag. The permanent copy lives at `~/.config`,
below.)

### 5. First login

Autologins as `raj` into niri. Then:

- `passwd` — change the initial password (`changeme`).
- Set up the **SSH key** (below), then clone this repo **as `~/.config`** so the
  `update` alias works (init-in-place if `~/.config` already has files, as on
  Alpine). Copy storm's `hardware-configuration.nix` into it and commit it.
- Import your **GPG key** so `pass` works — `.zshrc` runs `pass git pull` on
  start.

### SSH key for GitHub

```
ssh-keygen -t ed25519 -C "raj@siliconwitchery.com"
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub      # add at GitHub ▸ Settings ▸ SSH and GPG keys
ssh -T git@github.com          # verify
```

## Day to day

- Edit dotfiles in `~/.config/<app>/` directly — live, no rebuild.
- `update` (zsh alias) → `nix flake update` + `nixos-rebuild switch` (latest).
- Broke something? Pick the previous generation in the boot menu, then fix.
