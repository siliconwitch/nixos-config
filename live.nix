{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./common.nix
  ];

  # Let greetd/niri own the console instead of the installer's autologin shell.
  services.getty.autologinUser = lib.mkForce null;

  # The installer base enables wpa_supplicant, which clashes with NetworkManager.
  networking.wireless.enable = lib.mkForce false;
}
