# Session recovery gaps in greetd and the power key

Config-level fragilities exposed by the Aug 13 incident: greetd has no Restart= and Conflicts=getty@tty1 (one greeter death = no GUI, blank tty1); HandlePowerKey=ignore means power key does nothing when the session is dead; ac-unplug-suspend script breaks when two wayland lock files exist. All fixes undecided.

Three recovery gaps observed (not caused) during the 2026-08-13 incident ([13 August 2026: agent benchmarks killed the compositor](aug13-desktop-killed-by-agent-benchmarks.md)). None is a defect in normal operation; each removed a recovery path once the compositor was killed:

1. **greetd is single-shot, by design and by this config (verified upstream + module, 2026-08-13).** greetd deliberately terminates (exit 0, "Deactivated successfully") when its greeter dies without creating a session, to avoid crash loops; restart policy is delegated to systemd. The NixOS module HAS `services.greetd.restart` (maps to `Restart = "on-success"`), but its default is `!(settings ? initial_session)` and Raj's config sets initial_session (autologin), so restart defaulted to FALSE. Setting `services.greetd.restart = true;` explicitly would have auto-recovered this exact incident. NB `Restart=on-failure` would NOT work (exit code is 0). Trade-off per the option doc: every restart re-triggers autologin; a persistent killer loops until systemd's start rate limit, then dead again. Also: `default_session = initial_session` aliasing is why the SIGKILLed "greeter" was a second niri. The blank tty1 is module DESIGN, not accident: the module sets `Conflicts=getty@tty1.service` AND `systemd.services."autovt@tty1".enable = false`; not configurable short of a unit override. tty2 on-demand autovt is the intended fallback and did work.

2. **Power key is configured dead.** logind.conf has HandlePowerKey=ignore (config comment: "niri handles sleep"). With niri gone, 109 short presses did nothing; only the EC-level long hold worked, which is exactly the data-loss path (fsck recovery + dirty ESP + BERT record followed). Trade-off to discuss if it ever bites again, not a bug.

3. **ac-unplug-suspend glob bug.** The script does `basename` on `/run/user/1000/wayland-*.lock` assuming exactly one lock file; with a second Wayland socket present (crashing Hyprland left wayland-2.lock) it failed with "basename: extra operand" and exited 1 under set -e. On Aug 13 that failure was LUCKY (it prevented a suspend mid-collapse), but the script silently does nothing whenever a second compositor/socket exists. configuration.nix ~lines 56-82.

Also: user@1000.service can wedge in "Stopping" if a scope (here the foot server's app-niri-sh scope) doesn't exit; tty2 logins then authenticate but get "transaction is destructive" and no session. systemd's own 120 s stop timeout would have force-killed it had the machine been given the time.

**Why:** these decide whether a future desktop death is a 30-second recovery or another hard power-off.

**How to apply:** if Raj asks to harden any of these, verify current NixOS options first (diligence chain) and present variants; do not pre-apply. If a dead desktop recurs: try tty2, give user@ time to hit its stop timeout, then `systemctl restart greetd` as root.
