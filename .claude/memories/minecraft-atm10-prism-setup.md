# Minecraft ATM10 setup via Prism Launcher

Plan for modded Minecraft (ATM10 + Essential + controller) on mist via Prism Launcher; needs flake update first (Prism 11.0.3 CurseForge fix).

Raj wants to play All The Mods 10 (CurseForge modpack) with a friend, with the
Essential mod (Essential_1-4-0-3_neoforge_1-21-1.jar from the friend) and a
game controller. Researched and verified 2026-07-19.

STATUS (2026-07-19): plain `prismlauncher` added to configuration.nix
(GUI apps section), dry-build clean. Controller is an 8BitDo over Bluetooth,
rumble explicitly not wanted, so: no xpadneo/xone/steam-hardware options, no
sdl3 additionalLibs override (Controlify's GLFW fallback suffices). Remaining
steps are Raj-side: update-my-nix (MUST come before pack install, see below),
then imperative Prism setup (MS login, ATM10 instance, 10 GB RAM, Essential
jar, disable Drippy Loading Screen, Controlify from Modrinth), pair pad via
bluetui. If 8BitDo button mapping is wrong in XInput mode over BT, that is
the one case where adding hardware.xpadneo.enable would help.

Verified facts:

- ATM10 latest = 7.1 (2026-06-26), MC 1.21.1 + NeoForge, needs Java 21.
  RAM guidance: 8 GB min, 10 GB recommended, don't exceed ~12 GB (GC stutter).
- Launcher = Prism (`prismlauncher` in nixpkgs). CurseForge app is
  Ubuntu-only on Linux. TIME-CRITICAL: CurseForge CDN requires API-key auth
  since 2026-07-16; only Prism >= 11.0.3 (released 2026-07-11) can download
  CurseForge content. Locked nixpkgs rev 18b9261 (2026-07-14) has 11.0.2
  (broken); nixos-unstable branch already has 11.0.3, so run `update-my-nix`
  BEFORE installing the pack.
- Prism wrapper defaults are fine: jdks include jdk21, controllerSupport and
  gamemodeSupport already true on Linux. Override args if needed:
  additionalLibs, jdks, etc. Login with MS account inside Prism (no vanilla
  launcher). Runs via XWayland under niri (xwayland-satellite);
  avoid native-Wayland GLFW initially.
- Essential: free, peer-to-peer Host World (host must be online, max 8
  players, all players need identical mods/versions). 1.4.0.3 neoforge 1.21.1
  is real (2026-06-22); 1.4.1 exists (2026-07-16) but must match the friend.
  Jar goes in instance mods folder (Prism: Edit > Mods > Add file).
  Disable Drippy Loading Screen in the instance (on Essential's official
  incompatible list; ATM10 ships it via FancyMenu).
- Controller mod = Controlify 3.0.1+lts for NeoForge 1.21.1 (2026-07-10,
  dep YACL, client-side only; ATM10 bundles no controller mod; Controllable is
  maintenance-only). NixOS SDL3 caveat: Controlify loads "SDL3" by soname via
  JNA; if its downloaded native fails, fix with
  `prismlauncher.override { additionalLibs = [ sdl3 ]; }` or JVM arg
  -Dcontrolify.debug.sdl_natives_override=/path/libSDL3.so; graceful GLFW
  fallback otherwise (loses rumble/gyro only).
- Controller hardware on NixOS: joystick evdev access is automatic for the
  seat user (systemd uaccess rule, verified in live systemd 261); no input
  group. Xbox over BT: hardware.xpadneo.enable (no ERTM quirk on kernel 7.0).
  Xbox USB dongle: hardware.xone.enable (unfree firmware, allowUnfree covers).
  DualSense/DS4/Switch Pro: in-kernel, zero config.
  hardware.steam-hardware.enable only for hidraw extras (gyro/LEDs).
  All option names verified at locked rev. Steam Input route rejected
  (contradicts minimalism, worse UX than Controlify).
