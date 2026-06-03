# PATH additions
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.npm/bin
export PATH=$PATH:$HOME/.nrfutil/bin
export PATH=$PATH:$HOME/go/bin

# Pull the latest passwords in the background
(pass git pull &>/dev/null &)

# Aliases
alias l='eza -l'
alias ll='eza -la'
alias cat='bat'
alias rm='trash-put'

alias gs='git status -u'
alias gd='git diff'
alias gl='git log'
alias gc='git add . && git commit -m'
alias gp='git pull'
alias gpp='git push'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'

alias clean='make clean'
alias debug='make debug'
alias recover='make recover'

alias rebuild-my-nix='sudo nixos-rebuild switch --flake ~/.config#mist'
alias update-my-nix='( cd ~/.config && nix flake update ) && sudo nixos-rebuild switch --flake ~/.config#mist && sudo fwupdmgr refresh && sudo fwupdmgr update'

# Clear scrollback + screen (also clears tmux history once tmux is installed)
function clear-scrollback-and-screen { zle clear-screen; command -v tmux >/dev/null && tmux clear-history }
zle -N clear-scrollback-and-screen
bindkey '^o' clear-scrollback-and-screen

# History search keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Options
setopt autocd
unsetopt BEEP

# History (kept in the XDG state dir, out of the home root)
mkdir -p ~/.local/state/zsh
export HISTFILE=~/.local/state/zsh/history
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Prompt
source ~/.config/zsh/prompt.zsh

# zsh plugins are installed and loaded by NixOS (programs.zsh in
# configuration.nix). zoxide is a tool, so init it here.
eval "$(zoxide init zsh --cmd cd)"
