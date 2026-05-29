{ pkgs, ... }:

{
  boot.kernelParams = [ "i8042.dumbkbd=1" ];

  # Panther Lake Arc B390 (Xe3) GPU needs kernel >= 6.17; 25.11 defaults to 6.12.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  console = {
    font = "${pkgs.tamsyn}/share/consolefonts/Tamsyn10x20r.psf.gz";
    packages = [ pkgs.tamsyn ];
  };

  networking.networkmanager.enable = true;

  programs.niri.enable = true;
  programs.hyprlock.enable = true;

  # Maximise hardware coverage on new Lenovo silicon (WiFi, Bluetooth, audio DSP, GPU).
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;          # adds non-redistributable firmware (needs allowUnfree)
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Autologin straight into niri for raj, no greeter (initial_session).
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "raj";
      };
      default_session = initial_session;
    };
  };

  programs.zsh.enable = true;

  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ git ];

  system.stateVersion = "25.11";
}
