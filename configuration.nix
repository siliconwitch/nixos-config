{ pkgs, ... }:
# test
{
  # Nix
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot & kernel
  boot.kernelParams = [ "i8042.dumbkbd=1" ];        # Lenovo keyboard quirk
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hardware & firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Desktop & lockscreen
  programs.niri.enable = true;
  programs.hyprlock.enable = true;
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

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    nerd-fonts.anonymice
    noto-fonts-color-emoji
  ];

  # Shell
  programs.zsh.enable = true;
  programs.zsh.histFile = "$HOME/.local/state/zsh/history";
  environment.sessionVariables.ZDOTDIR = "/home/raj/.config/zsh";

  # User
  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };
  security.sudo.wheelNeedsPassword = false;

  # Packages
  environment.systemPackages = with pkgs; [
    git

    # Desktop related
    mako           # notifications
    swaybg         # wallpaper
    wl-clipboard   # clipboard
    cliphist       # clipboard history
    libnotify      # notify-send
    playerctl      # media keys
    ddcutil        # external monitor brightness
    pulseaudio     # pactl (talks to pipewire-pulse)
    wireplumber    # wpctl

    # Terminal apps & tools
    foot           # terminal
    helix          # hx editor
    fastfetch      # system info
    yazi           # file manager
    wiremix        # PipeWire TUI mixer
    bluetui        # Bluetooth TUI
    libqalculate   # qalc
    eza            # ls (l/ll aliases)
    bat            # cat alias
    delta          # git pager
    trash-cli      # rm alias
    pass gnupg     # password manager
    netcat-openbsd # nc (zsh prompt)
    zoxide         # cd

    # zsh plugins (sourced from /run/current-system/sw/share in zsh/.zshrc)
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-you-should-use
    zsh-completions

    # GUI apps
    chromium
  ];

  system.stateVersion = "25.11";
}
