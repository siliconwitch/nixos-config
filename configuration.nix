{ pkgs, lib, ... }:

{
  # Nix
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.segger-jlink.acceptLicense = true;
  nixpkgs.config.permittedInsecurePackages = [ "segger-jlink-qt4-874" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot & kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "i8042.dumbkbd=1" ];        # Lenovo keyboard quirk
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hardware & firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;

  # USB device rules from packages that ship them
  services.udev.packages = with pkgs; [ saleae-logic-2 segger-jlink ];

  # Swap (compressed RAM — 32 GB machine, no hibernation, nothing on disk)
  zramSwap.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Networking
  networking.hostName = "storm";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;  # iwd's built-in DHCP
  };

  # Localisation
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

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
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    autosuggestions.strategy = [ "history" "completion" ];
    syntaxHighlighting.enable = true;
    histFile = "$HOME/.local/state/zsh/history";
    # Plugins with no NixOS module of their own. mkAfter so they load after
    # syntax-highlighting (history-substring-search must come after it).
    interactiveShellInit = lib.mkAfter ''
      source /run/current-system/sw/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
      source /run/current-system/sw/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    '';
  };
  environment.sessionVariables.ZDOTDIR = "$HOME/.config/zsh";

  # User
  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" ];
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
    wev            # wayland event debug
    wtype          # wayland virtual keyboard

    # Terminal apps & tools
    foot           # terminal
    helix          # hx editor
    fastfetch      # system info
    yazi           # file manager
    wiremix        # PipeWire TUI mixer
    bluetui        # Bluetooth TUI
    impala         # Wi-Fi TUI (iwd)
    libqalculate   # qalc
    eza            # ls (l/ll aliases)
    bat            # cat alias
    delta          # git pager
    trash-cli      # rm alias
    pass gnupg     # password manager
    netcat-openbsd # nc (zsh prompt)
    zoxide         # cd
    claude-code
    tmux           # terminal multiplexer
    btop           # system monitor
    jq             # JSON processor
    ffmpeg         # media
    fzf            # fuzzy finder
    fd             # find alternative
    ripgrep        # rg
    pandoc         # document converter
    cloc           # lines of code
    unzip
    nrfutil        # Nordic Semi CLI
    segger-jlink   # J-Link tools (unfree)

    # Languages & LSPs
    go
    gopls
    python3
    python3Packages.weasyprint   # HTML → PDF CLI
    ruff                         # python linter/formatter
    lua
    lua-language-server
    nodejs                       # node + npm
    typescript                   # tsc
    typescript-language-server
    vscode-langservers-extracted # html/css/json/eslint LSPs
    marp-cli                     # markdown slides
    clang                        # C/C++ toolchain
    clang-tools                  # clangd, clang-format
    markdown-oxide               # markdown LSP

    # zsh plugins loaded by programs.zsh above (autosuggestions +
    # syntax-highlighting via their modules; these three have none).
    zsh-history-substring-search
    zsh-you-should-use
    zsh-completions

    # GUI apps
    chromium
    kicad           # EDA
    vlc             # media player
    davinci-resolve # video editor (unfree)
    vesktop         # Discord client (Vencord, Wayland-friendly)
    saleae-logic-2  # logic analyzer (unfree)
  ];

  system.stateVersion = "25.11";
}
