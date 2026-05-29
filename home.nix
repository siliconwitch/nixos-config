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

    # shell tools (referenced by the zsh config)
    eza             # `l` / `ll` aliases
    bat             # `cat` alias
    trash-cli       # `rm` -> trash-put
    pass            # password manager (startup pull + prompt)
    gnupg           # gpg, used by pass
    netcat-openbsd  # `nc`, used by the prompt's git-fetch check
  ];

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  xdg.configFile."foot/foot.ini".source = ./foot/foot.ini;
  xdg.configFile."mako/config".source = ./mako/config;
  xdg.configFile."wallpaper.jpg".source = ./wallpaper.jpg;

  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 1000000;
      save = 1000000;
      extended = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      share = true;
    };

    shellAliases = {
      l = "eza -l";
      ll = "eza -la";
      cat = "bat";
      rm = "trash-put";
      gs = "git status -u";
      gd = "git diff";
      gl = "git log";
      gc = "git add . && git commit -m";
      gp = "git pull";
      gpp = "git push";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gco = "git checkout";
      gcb = "git checkout -b";
      clean = "make clean";
      debug = "make debug";
      recover = "make recover";
      update = "nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos";
    };

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ];

    initContent = ''
      # Extra completions on fpath (before compinit).
      fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)

      setopt autocd
      unsetopt BEEP
      setopt HIST_VERIFY

      # Pull latest passwords in the background on login.
      (pass git pull &>/dev/null &)

      # Clear scrollback + screen (also clears tmux history once tmux is added).
      function clear-scrollback-and-screen {
        zle clear-screen
        command -v tmux >/dev/null && tmux clear-history
      }
      zle -N clear-scrollback-and-screen
      bindkey '^o' clear-scrollback-and-screen

      # Custom prompt.
      source ${./zsh/prompt.zsh}
    '';
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.npm/bin"
    "$HOME/.nrfutil/bin"
    "$HOME/go/bin"
  ];

  home.stateVersion = "25.11";
}
