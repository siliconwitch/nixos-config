{ pkgs, lib, username, ... }:

{
  # Nix
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.segger-jlink.acceptLicense = true;
  nixpkgs.config.permittedInsecurePackages = [ "segger-jlink-qt4-874" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  nixpkgs.overlays = [
    (final: prev: {
      chromium = prev.chromium.override {
        commandLineArgs = "--password-store=basic";
      };
    })
  ];

  # Boot & kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "i8042.dumbkbd=1" ]; # Lenovo keyboard quirk
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hardware & firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;
  services.fwupd.enable = true;
  
  # USB device rules from packages that ship them
  services.udev.packages = with pkgs; [ saleae-logic-2 segger-jlink ];

  # Remap Lenovo Copilot key
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        global.chord_timeout = 10;
        main."leftmeta+leftshift+f23" = "leftmeta";
      };
    };
  };

  # Power buttons (niri handles sleep, along with the script below)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
    HandleSuspendKey = "ignore";
  };

  # Power notifications and tasks
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="ADP0", ENV{POWER_SUPPLY_ONLINE}=="0", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ac-unplug-suspend.service"
    SUBSYSTEM=="power_supply", KERNEL=="ADP0", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ac-notifications.service"
  '';

  systemd.services.ac-unplug-suspend = {
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec="infinity";
    };
    path = with pkgs; [ util-linux hyprlock ];
    script = ''
      if grep -q closed /proc/acpi/button/lid/LID0/state; then
        rd=/run/user/$(id -u ${username})
        wd=$(basename "$rd"/wayland-*.lock .lock)
        runuser -u ${username} -- env XDG_RUNTIME_DIR=$rd WAYLAND_DISPLAY=$wd hyprlock --immediate-render --no-fade-in &
        systemctl suspend
        wait -n
      fi
    '';
  };

  systemd.services.ac-notifications = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ util-linux libnotify ];
    script = ''
      if [ $(cat /sys/class/power_supply/ADP0/online) == 1 ]; then
        runuser -u ${username} -- env XDG_RUNTIME_DIR=/run/user/$(id -u ${username}) notify-send "Power" "Plugged in"
      else
        runuser -u ${username} -- env XDG_RUNTIME_DIR=/run/user/$(id -u ${username}) notify-send "Power" "Unplugged"
      fi
    '';
  };

  systemd.user.services.battery-notifications = {
    wantedBy = [ "default.target" ];
    path = with pkgs; [ coreutils hyprlock libnotify ];
    script = ''
      notified=0; suspended=0
      while true; do
        level=$(cat /sys/class/power_supply/BAT0/capacity)
        if [ $(cat /sys/class/power_supply/BAT0/status) = "Discharging" ]; then
          if [ $level -le 5 ] && [ $suspended -eq 0 ]; then
            suspended=1; hyprlock --immediate-render --no-fade-in & systemctl suspend
          elif [ $level -le 10 ] && [ $notified -lt 2 ]; then
            notified=2; notify-send -t 5000 "Battery Low" "$level% remaining"
          elif [ $level -le 20 ] && [ $notified -lt 1 ]; then
            notified=1; notify-send -t 3000 "Battery Low" "$level% remaining"
          fi
        else
          notified=0; suspended=0
        fi
        sleep 60
      done
    '';
  };
  
  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      STOP_CHARGE_THRESH_BAT0 = 1;
    };
  };
  services.upower.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Networking
  networking.hostName = "mist";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;  # iwd's built-in DHCP
  };

  # Swap (compressed RAM — 32 GB machine, no hibernation, nothing on disk)
  zramSwap.enable = true;

  # GPG agent (passphrase caching for pass)
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # mDNS (*.local hostname resolution)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    ports = [ 3439 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      MaxAuthTries = 3;
      ClientAliveInterval = 15;
      ClientAliveCountMax = 3;
    };
  };

  # Localisation
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    nerd-fonts.anonymice
    noto-fonts-color-emoji
  ];

  # Desktop & lockscreen
  programs.niri.enable = true;
  programs.hyprlock.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = username;
      };
      default_session = initial_session;
    };
  };

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
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };

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
    brightnessctl  # internal display brightness
    ddcutil        # external monitor brightness
    pulseaudio     # pactl (talks to pipewire-pulse)
    wireplumber    # wpctl
    wev            # wayland event debug
    wtype          # wayland virtual keyboard
    xwayland-satellite # X11 app support (spawn from niri config)

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
