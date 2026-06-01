{ modulesPath, lib, ... }:

# Throwaway wrapper: builds a live ISO of configuration.nix for testing on real
# hardware (`nix build .#iso`). Delete once the real machine is set up.
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./configuration.nix
  ];

  # Let greetd/niri own the console instead of the installer's autologin shell.
  services.getty.autologinUser = lib.mkForce null;

  # The installer base enables wpa_supplicant, which clashes with NetworkManager.
  networking.wireless.enable = lib.mkForce false;
}
