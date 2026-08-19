# Kernel 7.1.x breaks s2idle suspend (Panther Lake)

## UPDATE Jul 22 2026: NEW, DIFFERENT s2idle death on 7.2-rc3 (intermittent, xe/PSR)

One fatal suspend on 7.2-rc3 after **6 clean suspend/resume cycles in the same
boot** (so NOT the 7.1.x always-hang returning). Signature: lid-close on
battery at 23% -> `xe 0000:00:02.0: [drm] *ERROR* Timed out waiting PSR idle
state` 0.3 s before `PM: suspend entry (s2idle)` -> journal dies, never
resumed; found powered OFF next morning. NOT a drain death: Raj plugged it in
just after lid close, unplugged ~23:00, and it held 100% overnight, which only
an already-off machine does (a hung box burns watts; clean s2idle is ~0.3%/h).
So the machine killed itself at the firmware/EC level during the evening,
possibly right at suspend entry, and the EC reset wiped conservation mode ->
off-state charging ran 23%->100% (see
[Battery gauge miscalibrated, hard cut at 54 percent](battery-gauge-miscalibrated-cutoff-at-54pct.md) for the energy_full re-learn
fallout). Corroboration conservation was fine before the crash: previous night
same boot sat pinned at exactly 80% "not charging" on AC. The PSR timeout is
the only anomaly vs the 6 good cycles; none of them logged PSR errors. pstore
empty, no panic record. Intermittent GPU-not-idle failure, watch for
recurrence. If it recurs: research disabling PSR for the xe driver (verify the
exact module param first, do not assume) and check 7.2 stable changelogs.

Tested on this machine during the audio test boot (`linuxPackages_testing` =
7.2.0-rc3 on the Jul 2026 nixpkgs pin, binary-cached): `systemctl suspend`
suspends AND resumes cleanly. The 7.1.x regression is gone in 7.2.
DONE Jul 20 (commit 0cddc01): `nixpkgs-kernel` flake input + 7.0.13 pin
dropped; now riding `linuxPackages_testing` = 7.2-rc3 (chosen for audio, see
[Built-in audio on Panther Lake](builtin-audio-broken-panther-lake.md)). Only remaining action: move to
`linuxPackages_latest` once 7.2 stable reaches nixos-unstable (comment already
in configuration.nix). Sections below are history.

CONFIRMED (high confidence, Jun 18 2026). A nix update bumped
`linuxPackages_latest` 7.0.12 -> 7.1.0; s2idle suspend now hard-hangs the
kernel and the machine must be force-powered-off.

## UPDATE Jul 8 2026: 7.1.3 still hangs; IPU7 theory ruled out; 7.0 re-pinned via flake input

- nixpkgs removed `linuxPackages_7_0` (EOL upstream, 2026-06-27) -> rebuild broke.
- User tested **7.1.3**: same hard hang; journal of that boot ends at
  `PM: suspend entry (s2idle)` — identical signature to 7.1.0. No suspend/PM/ipu7
  fixes in the 7.1.1–7.1.3 changelogs at all.
- **CachyOS IPU7 s2idle bug (linux-cachyos#826) is NOT this machine's bug**:
  `intel-ipu7.ko` is built but never loaded (webcam is USB UVC via `uvcvideo`,
  not IPU7/MIPI), and that bug requires camera use first. Don't chase it again.
- New pin: `nixpkgs-kernel` flake input pinned to nixpkgs `e73de5b` (last rev
  with linux 7.0 = 7.0.13, binary-cached); configuration.nix uses
  `nixpkgs-kernel.legacyPackages.<system>.linuxPackages_7_0`. Main nixpkgs keeps
  updating normally. 7.0 gets NO upstream fixes anymore — this is a stopgap.
- **Next action: retest suspend on 7.2 when it reaches stable** (7.2-rc1 existed
  in nixpkgs testing as of Jul 2026), then drop the nixpkgs-kernel input.

## Controlled comparison (read-only, from live journals)
- Boot -4 = **7.0.12**: 8 `PM: suspend entry (s2idle)` / 8 `PM: suspend exit`,
  perfect 1:1, zero hangs. Lid-close-on-battery and timer suspends all clean.
- Boots -3,-2,-1,0 = **7.1.0**: **0** `suspend exit` across all four boots.
  - -3: clean manual `systemctl reboot` (NOT a hung suspend). The earlier
    "Reached target Sleep, no entry" note was misattributed to -3.
  - -2: lid-close (battery) -> niri -> logind "will suspend now" ->
    systemd-sleep froze user.slice OK -> "Performing sleep operation 'suspend'"
    -> journal DIES. Kernel never even logged `suspend entry`. Hang is *before*
    the PM core's first message (write to /sys/power/state wedged the box).
  - -1: same path, got one step further: logged `PM: suspend entry (s2idle)`,
    then DIED before `Freezing user space processes`. Force-powered-off.

## Adversarial alternatives ruled OUT
- Inhibitor block: CanSuspend=yes, BlockInhibited="" (only delay-mode
  rtkit+UPower). Userspace actually proceeded into the kernel call.
- Userspace refusing to freeze: `user.slice` froze successfully both times.
- Re-wake / wakeup-source storm: zero `suspend exit` anywhere; it's a hang,
  not an instant re-wake.
- sleep.conf/AllowSuspend: sleep.conf empty (defaults), mem_sleep=[s2idle] only
  (S0ix machine, normal). Unchanged from the working 7.0.12 state.
- niri AC-gating: NOT the cause and working as designed (see below).
- The dhcpcd segfault / sof_sdw cs42l43 -ENODEV noise at boot is unrelated
  (boot-time, not at suspend; audio is a separate known issue).

Only variable that changed = the kernel. -> 7.1.0 regression confirmed.

## Lid-close AC-vs-battery design (NOT a bug)
niri config.kdl `switch-events { lid-close ... }`: always hyprlock + blank
eDP-1, but only `systemctl suspend` when `/sys/class/power_supply/ADP0/online`
== 0 (battery). On AC, lid-close only locks+blanks BY DESIGN. Both -2 and -1
DID fire suspend => machine was on battery; the lid logic worked correctly.
(Separate custom `ac-unplug-suspend.service` + udev rule suspends on AC unplug;
also low-battery auto-suspend at <=5%. configuration.nix ~L47-101.)

## Fix APPLIED (Jun 18 2026)
configuration.nix L18: `boot.kernelPackages = pkgs.linuxPackages_latest;`
-> `pkgs.linuxPackages_7_0;` (verified via nix eval: `_7_0` = 7.0.12 exactly,
`_7_1` = `_latest` = 7.1; no `linuxPackages_lts` attr in this nixpkgs). Keeps
the rest of the update (nixpkgs 567a49d, Mesa 26.x userspace — iris/niri fix is
userspace, unaffected); reverts ONLY the kernel. `nixos-rebuild dry-build`
clean. User applies with sudo switch + REBOOT (kernel change needs reboot;
running kernel stays 7.1.0 until then). Pin survives future flake updates while
7.0.x stays in nixpkgs. **Un-pin to linuxPackages_latest once a 7.1.x point
release fixes the PTL s2idle hang.** Fallback still = generation 140.
