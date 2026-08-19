# Duplicate HiFiBerry sink from a stray PipeWire drop-in

Two HiFiBerry sinks / broken volume = a second raop-discover from a stray hand-written ~/.config/pipewire drop-in duplicating the declarative one; resume/reconnect triggers it.

Symptom: two HiFiBerry AirPlay outputs appear (one device), volume control hits the wrong one. Root cause was a stray hand-written `~/.config/pipewire/pipewire.conf.d/raop-discover.conf` (latency 500ms) loading a SECOND `libpipewire-module-raop-discover` alongside the declarative one from `configuration.nix` (`services.pipewire.extraConfig.pipewire."50-raop-latency"`, latency 2000ms). Two discover modules → each creates a sink for the same device.

Both loaded at every boot since ~2026-06-01; whether you saw 1 or 2 sinks was a discovery race. Suspend→resume + WiFi reconnect re-runs RAOP discovery (journal shows raop-sink re-created every ~10-15min) and let both discovers land a sink — that's the trigger, not the cause.

**Why:** the airplay latency setting was first set by a hand-written drop-in, later migrated into configuration.nix declaratively, but the original file was never deleted (and stayed committed in the ~/.config repo).

**How to apply:** check `pactl list short modules | grep raop-discover` — should be exactly ONE. If two, find the extra source (`~/.config/pipewire/pipewire.conf.d/`, stock `50-raop.conf` in pipewire share/avail). Remove the redundant one, then `systemctl --user restart pipewire pipewire-pulse wireplumber`. Device announces on both IPv4 + IPv6 (avahi-browse) but only the IPv4 sink is created; not currently a v4/v6 dup. Related: [HiFiBerry AirPlay no-audio is device-side](hifiberry-airplay-no-audio-device-side.md), apply-config-with-update-my-nix.
