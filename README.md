# nixos-config

My NixOS system configuration **and** dotfiles, in one repo.

## Layout

- **Nix defines the OS** — `configuration.nix` (+ machine-generated `hardware-configuration.nix`) describes the system and installs all packages.
- **App config stays as traditional dotfiles** — `niri/`, `zsh/`, `git/`, etc. No Home Manager - edit these directly.

The repo is cloned as `~/.config`, so the dotfiles land in the correct place without symlinking. The Nix files live alongside them at the repo root.

## Install

A minimal-ISO install with LUKS full-disk encryption, then a switch to this flake. The disk is encrypted and swap is compressed RAM (zram).

1. Download the **Minimal ISO** from [NixOS](https://nixos.org/download/#nixos-iso), then write it to a USB stick:

    ```
    lsblk # To find the correct disk
    sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
    ```

2. Boot the stick.

3. Switch to superuser:

    ```sh
    sudo -i
    ```

4. Use `cfdisk` to create two partitions:

    ```sh
    lsblk # to check which disk to wipe. e.g. nvme0n1
    wipefs -a /dev/nvme0n1

    cfdisk /dev/nvme0n1
    # Choose: gpt
    # /dev/nvme0n1p1 - 1G - EFI system partition
    # /dev/nvme0n1p2 - remaining space - Linux filesystem
    ```

5. Setup encryption:

    ```sh
    cryptsetup luksFormat /dev/nvme0n1p2
    cryptsetup open /dev/nvme0n1p2 cryptroot

    mkfs.ext4 -L nixos /dev/mapper/cryptroot
    mkfs.fat -F32 -n boot /dev/nvme0n1p1

    mount /dev/disk/by-label/nixos /mnt
    mkdir /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
    ```

6. Generate the base config and install:

    ```sh
    nixos-generate-config --root /mnt
    nixos-install
    reboot
    ```

7. Switch to this config:

    Login as `root`.

    ```sh
    nix-shell -p git
    git clone https://github.com/siliconwitch/nixos-config /root/storm
    cp /etc/nixos/hardware-configuration.nix /root/storm

    # Apply the config — this creates the raj user and home directory
    nixos-rebuild switch --flake /root/storm#storm

    # Move the config into place as raj's dotfiles; clean up the root clone
    mv /root/storm /home/raj/.config
    chown -R raj:raj /home/raj

    reboot
    ```

8. Create SSH key for github access

    ```sh
    ssh-keygen -t ed25519 -C "raj@siliconwitchery.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub # add at GitHub → Settings → SSH and GPG keys
    ```

9. Download and setup GPG key to enable `pass`

    ```sh
    # TODO
    ```

## Rebuilds

After setup, rebuild from raj's shell:

```sh
sudo nixos-rebuild switch --flake ~/.config#storm
```
