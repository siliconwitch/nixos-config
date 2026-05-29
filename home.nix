{ pkgs, ... }:

{
  home.username = "raj";
  home.homeDirectory = "/home/raj";

  home.packages = with pkgs; [
    foot            # terminal (foot --server + footclient)
    mako            # notifications
    swaybg          # wallpaper
    wl-clipboard    # wl-copy / wl-paste
    cliphist        # clipboard history
    libnotify       # notify-send
    fastfetch
    yazi            # file manager
    chromium        # browser
    wiremix         # PipeWire TUI mixer
    bluetui         # Bluetooth TUI
    libqalculate    # qalc calculator
    playerctl       # media keys
    pulseaudio      # pactl client (talks to pipewire-pulse)
    wireplumber     # wpctl
    ddcutil         # monitor brightness
  ];

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  xdg.configFile."foot/foot.ini".source = ./foot/foot.ini;
  xdg.configFile."mako/config".source = ./mako/config;
  xdg.configFile."wallpaper.jpg".source = ./wallpaper.jpg;

  home.stateVersion = "25.11";
}
