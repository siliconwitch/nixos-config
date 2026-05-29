{ ... }:

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

  networking.hostName = "storm";
}
