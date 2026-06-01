{ pkgs, ... }:

{
  # --- Boot / kernel -----------------------------------------------------------
  boot.kernelParams = [ "i8042.dumbkbd=1" ];        # laptop keyboard quirk
  boot.kernelPackages = pkgs.linuxPackages_latest;  # Panther Lake Arc B390 needs >= 6.17

  # --- Firmware / hardware -----------------------------------------------------
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;                # full WiFi/BT/audio/GPU firmware
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;                  # Mesa/EGL for niri
  hardware.i2c.enable = true;                        # ddcutil (external brightness)
  hardware.bluetooth.enable = true;

  # --- Audio (PipeWire) --------------------------------------------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # --- Networking --------------------------------------------------------------
  networking.networkmanager.enable = true;

  # --- Console -----------------------------------------------------------------
  console = {
    font = "${pkgs.tamsyn}/share/consolefonts/Tamsyn10x20r.psf.gz";
    packages = [ pkgs.tamsyn ];
  };

  # --- Desktop: niri, autologin with no greeter --------------------------------
  programs.niri.enable = true;
  programs.hyprlock.enable = true;                   # lock screen (sets up PAM)
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

  # --- Shell: zsh (config is a dotfile at ~/.config/zsh, see zsh/.zshrc) --------
  programs.zsh.enable = true;
  environment.sessionVariables.ZDOTDIR = "/home/raj/.config/zsh";

  # --- User --------------------------------------------------------------------
  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" "networkmanager" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };
  security.sudo.wheelNeedsPassword = false;

  # --- Nix ---------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Packages (system-wide; app *config* lives in dotfiles, not here) --------
  environment.systemPackages = with pkgs; [
    git

    # niri session helpers
    mako          # notifications
    swaybg        # wallpaper
    wl-clipboard
    cliphist      # clipboard history
    libnotify     # notify-send
    playerctl     # media keys
    ddcutil       # external monitor brightness
    pulseaudio    # pactl (talks to pipewire-pulse)
    wireplumber   # wpctl

    # terminal apps / tools
    foot          # terminal
    fastfetch
    yazi          # file manager
    wiremix       # PipeWire TUI mixer
    bluetui       # Bluetooth TUI
    libqalculate  # qalc
    eza           # ls (l/ll aliases)
    bat           # cat alias
    trash-cli     # rm alias
    pass gnupg    # password manager
    netcat-openbsd # nc (zsh prompt)
    zoxide        # cd

    # browser
    chromium

    # zsh plugins (sourced from /run/current-system/sw/share in zsh/.zshrc)
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-you-should-use
    zsh-completions
  ];

  system.stateVersion = "25.11";
}
