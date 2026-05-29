{ lib, ... }:

{
  imports = [
    ./common.nix
    ./hardware-configuration.nix
  ];

  fileSystems."/etc/nixos" = {
    device = "nixos-config";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" "nofail" ];
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.gfxmodeBios = "1024x768,auto";
  boot.loader.grub.extraConfig = "set gfxpayload=keep";

  # This VM can't run niri (virtio-gpu has no EGL), so skip the autostart and
  # boot to a console for terminal testing. niri still autostarts on real
  # hardware (the ISO / laptop) via common.nix.
  services.greetd.enable = lib.mkForce false;

  networking.hostName = "storm";
}
