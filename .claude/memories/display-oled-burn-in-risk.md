# The built-in panel is OLED, with burn-in risk

Built-in panel is OLED (real burn-in risk), not LCD; protect via monitor-off / true-black bg.

The built-in display on this machine (Lenovo Yoga Slim 7 Ultra 14IPH11) is **OLED**: BOE NB140B91-M00 / Lenovo "LEN140WQ+", 2880x1800 120Hz HDR, 500 nits (1100 peak). Confirmed via EDID + Lenovo PSREF/NotebookCheck (the part number is hard to find by search alone).

Implication: prolonged **static** images can cause *permanent* burn-in (differential pixel aging) — unlike LCD, which only gets temporary, self-clearing retention. Risk scales with brightness × duration × how static/bright the content is. A fully off panel = zero risk; a uniform true-black screen ≈ zero risk (pixels emit nothing at #000000).

Protection used (2026-06-30, while user away):
- Power the panel fully off: `niri msg output eDP-1 off` (hard-disable — does NOT re-wake on stray input, unlike `niri msg action power-off-monitors` which is DPMS-off and wakes on any input). Reversed by lid close→open (fires `output eDP-1 on`) or explicit `on`.
- Black-background fallback for when it's on: swaybg with a **solid color** `swaybg -c 000000`, NOT a black JPEG (compression can leave pixels >0). User keeps `~/.config/wallpaper.jpg` line commented in niri config.kdl while away.
- There is NO idle daemon (no swayidle/hypridle) and niri does not auto-blank on idle by default — so if the screen comes on, nothing re-blanks it. Cursor does hide after 5s (`hide-after-inactive-ms 5000`).

CAVEAT observed: `swaybg -c 000000` does NOT persist when launched by niri (`spawn-sh-at-startup` or `niri msg action spawn`) — it exits immediately. It DOES stay running when launched directly with the Wayland env (`WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 swaybg -c 000000`). Root cause not yet confirmed. So the committed black-bg config may not actually show black after a reboot.

Note: niri's control socket path embeds its PID (`/run/user/1000/niri.wayland-1.<pid>.sock`), so it changes on every niri restart/reboot — re-detect with `pgrep -ax niri` / `ls /run/user/1000/niri.*.sock` rather than caching it.

Related: [niri crashes from a Mesa iris Tile4 segfault](niri-mesa-iris-tile4-crash.md), [Kernel 7.1.0 s2idle suspend hang](kernel-7.1.0-s2idle-suspend-hang.md).
