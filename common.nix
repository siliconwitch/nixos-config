{ pkgs, ... }:

{
  boot.kernelParams = [ "i8042.dumbkbd=1" ];

  console = {
    font = "${pkgs.tamsyn}/share/consolefonts/Tamsyn10x20r.psf.gz";
    packages = [ pkgs.tamsyn ];
  };

  networking.networkmanager.enable = true;

  programs.niri.enable = true;
  programs.hyprlock.enable = true;

  hardware.graphics.enable = true;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };
  };

  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" "networkmanager" ];
    initialPassword = "changeme";
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [ git ];

  system.stateVersion = "25.11";
}
