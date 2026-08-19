# gnome-keyring disabled

gnome-keyring disabled Aug 10; unlock popup was pgcli via python keyring; nothing on the machine uses Secret Service.

2026-08-10: `services.gnome.gnome-keyring.enable = false` added to configuration.nix (niri module mkDefault-enables it; greetd passwordless autologin means the login keyring can never auto-unlock, so any Secret Service call popped the unlock dialog).

The popup trigger was **pgcli** (`keyring = True` default in ~/.config/pgcli/config); the `keyring` CLI Raj ran came from pgcli's bundled Python env, not PATH. `python_keyring/keyringrc.cfg` (null backend) is now tracked in the ~/.config repo so Python tools no-op quietly.

Verified consumers before disabling: gh token is plaintext in hosts.yml, Chromium forced `--password-store=basic` (overlay), secrets live in pass+gpg ([The password store is unreadable from sessions](pass-store-unreadable-from-sessions.md)), iwd stores Wi-Fi itself. If a future app silently fails to save credentials or logs org.freedesktop.secrets errors, this disable is why. Orphaned ~/.local/share/keyrings/login.keyring (June, pre-flag Chromium) left in place.
