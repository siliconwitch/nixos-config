{ lib, ... }:

# Throwaway wrapper: runs configuration.nix in the test VM. Delete once the
# real machine is set up.
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # This repo, shared in from the host over 9p.
  fileSystems."~/.config" = {
    device = "nixos-config";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" "nofail" ];
  };

  # So we can see the font in the VM
  #console = {
  #  font = "${pkgs.tamsyn}/share/consolefonts/Tamsyn10x20r.psf.gz";
  #  packages = [ pkgs.tamsyn ];
  #};

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.gfxmodeBios = "1024x768,auto";
  boot.loader.grub.extraConfig = "set gfxpayload=keep";

  networking.hostName = "vm";

  # The VM's virtio-gpu can't run niri, so boot to a console for OS testing.
  services.greetd.enable = lib.mkForce false;
}
