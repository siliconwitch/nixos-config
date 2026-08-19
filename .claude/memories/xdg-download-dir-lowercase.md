# Lowercase ~/downloads via user-dirs.dirs

~/downloads is set via ~/.config/user-dirs.dirs; XDG_DOWNLOAD_DIR as an env var and NixOS xdg.userDirs both do NOT exist/work.

Jul 20 2026: made `~/downloads` (lowercase) stick for all apps by committing
`~/.config/user-dirs.dirs` with only `XDG_DOWNLOAD_DIR="$HOME/downloads"`, plus
`~/.config/yazi/keymap.toml` overriding `g d`. Both added to the .gitignore
allowlist. No .nix changes were needed.

Three traps worth remembering:

- **`environment.sessionVariables.XDG_DOWNLOAD_DIR` does nothing.** Neither
  Chromium's bundled `xdg_user_dir_lookup` nor GLib's `load_user_special_dirs`
  ever calls getenv for it. It is a key *inside* user-dirs.dirs that merely
  looks like an env var. This is the common wrong answer online.
- **There is no NixOS-level `xdg.userDirs` option** (home-manager only, and
  this system doesn't use home-manager). `environment.etc."xdg/user-dirs.defaults"`
  is also useless here: no app reads it, and its only consumer
  `xdg-user-dirs-update` is not installed.
- **Chromium's fallback path:** with no DOWNLOAD entry the lookup returns
  `$HOME`, which `DownloadPathIsDangerous()` rejects, so it substitutes a
  hardcoded `$HOME/Downloads`. Chromium creating that dir on first save is what
  kept resurrecting it, not xdg-user-dirs.

Nothing regenerates user-dirs.dirs on this machine (xdg-user-dirs is pulled in
only by full desktop-manager modules; niri doesn't). If a desktop manager is
ever added, add `/etc/xdg/user-dirs.conf` with `enabled=False`.

Yazi's default keymap hardcodes `cd ~/Downloads` on `g d`. Use
`mgr.prepend_keymap` — the section was renamed `[manager]` → `[mgr]` in
yazi v25.5.28 (running 26.5.6). See [Nix dev shells across ~/projects](projects-nix-dev-shells.md) for other
dotfile-vs-nix placement decisions in this repo.
