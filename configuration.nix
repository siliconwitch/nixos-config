{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  fileSystems."/etc/nixos" = {
    device = "nixos-config";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" "nofail" ];
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.gfxmodeBios = "1024x768,auto";
  boot.loader.grub.extraConfig = "set gfxpayload=keep";
  boot.kernelParams = [ "i8042.dumbkbd=1" ];

  console = {
    font = "${pkgs.tamsyn}/share/consolefonts/Tamsyn10x20r.psf.gz";
    packages = [ pkgs.tamsyn ];
  };

  networking.hostName = "storm";
  networking.networkmanager.enable = true;

  programs.niri.enable = true;

  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # git is required for flake-based rebuilds (nixos-rebuild --flake reads the repo)
  environment.systemPackages = with pkgs; [ git ];

  system.stateVersion = "25.11";
}
