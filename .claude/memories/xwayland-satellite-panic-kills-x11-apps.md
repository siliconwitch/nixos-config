# An xwayland-satellite panic kills X11 apps

X11 apps (Minecraft/Prism) dying with "X connection to :0 broken" + exit 1 and NO crash report = xwayland-satellite panicking on a display/output change, not the app's fault.

When an X11 app under niri dies with `X connection to :0 broken (explicit kill or server shutdown)` and `Process exited with code 1` **and produces no app-level crash report / no Java exception / no hs_err**, the culprit is niri's `xwayland-satellite` panicking, not the app.

Confirmed 2026-07-30 for Minecraft (Prism, ATM10): the game ran fine for ~7 min, then died the instant a display/power transition happened. Journal showed at the same second: `niri::backend::tty: disconnecting connector "DP-1"` (the laser projector), `missing surface in vblank callback`, then `xwayland-satellite exited with: exit status: 101` (101 = Rust panic). Minecraft is an X11/GLFW client routed through xwayland-satellite, so when the shim panics **every** XWayland client dies at once.

**Trigger:** any output reconfiguration, and the recurring real-world one is the **"Laser Proj" projector (DP-1) DisplayPort link dropping on its OWN** (not user-unplugged — Raj confirmed). 2026-07-30 correlation was 3/3: DP-1 disconnect at 20:24:22, 20:44:05, 21:10:02 → xwayland panic at 20:24:22, 20:44:06, 21:10:02. Two of them **self-reconnected ~1s later** = a momentary link glitch, not a replug. The projector runs through the Thunderbolt/USB-C hub (commit d796c1b); at 21:10 the same event also blipped AC (`ADP0`→0), firing `ac-unplug-suspend` (lid closed → lock+suspend, configuration.nix ~line 58), so that crash also suspended the laptop. Consequence: EVERY X11 app dies whenever the projector flickers. Not GPU-load; distinct from [niri crashes from a Mesa iris Tile4 segfault](niri-mesa-iris-tile4-crash.md). Underlying hardware flakiness (projector DP link + AC dropout via the TB/USB-C hub) is a separate open question — see [LG UltraFine 5K over Thunderbolt](lg-ultrafine-5k-thunderbolt.md).

**Recurring:** 7 panic-exits (status 101) in 3 days (Jul 28–30, 2026). `xwayland-satellite` is **0.8.1**, the latest in nixpkgs 26.04 (niri 26.04), installed via `environment.systemPackages` in configuration.nix (~line 282). A straight version bump won't help.

**Fix avenues (none applied yet, discuss first):**
- Run Minecraft as a native Wayland client to bypass the shim entirely: add `-Dglfw.platform=wayland` to Prism JVM args (LWJGL 3.3.3 supports it; caveats: cursor-grab/fullscreen/libdecor quirks).
- Capture the panic with `RUST_BACKTRACE=1` by reproducing (toggle a display while an X11 app runs) to file/track upstream.
- Behavioral workaround: don't unplug AC / close lid / disconnect the projector while an X11 app is open.

See [Minecraft ATM10 setup via Prism Launcher](minecraft-atm10-prism-setup.md).
