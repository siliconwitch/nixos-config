# Battery gauge miscalibrated, hard cut at 54 percent

Jul 11 2026 battery death — pack hard-cut at indicated 54% (gauge miscalibrated); suspend + notification stack all worked correctly.

**UPDATE Jul 23 2026: EC crash during failed s2idle wiped conservation mode;
off-state charge ran to 100%; energy_full re-learned 70.1 -> 66.71 Wh.**
Failed suspend Jul 22 15:47 (see [Kernel 7.1.0 s2idle suspend hang](kernel-7.1.0-s2idle-suspend-hang.md), xe/PSR
event): machine powered itself off at the firmware/EC level during the
evening; the EC reset cleared conservation mode, so while off on AC it charged
23% -> **100% despite the 80% limit** (no deep discharge occurred, minimal
wear). TLP re-applied Long_Life at next boot 10:58:20 (charge_types =
`[Long_Life]`, conservation_mode=1; kernel now says the conservation_mode attr
is deprecated in favor of charge_types). Takeaways: (1) full-charge
termination is a gauge learn point, so 66.71 Wh (89% of design, cycle_count
21) supersedes 70.1 as the trusted estimate; it is a re-estimate, NOT sudden
real degradation. Do NOT recalibrate or cycle. (2) After any EC reset, expect
one off-state charge to run to 100%; harmless, self-corrects on next boot via
TLP re-asserting the threshold.

2026-07-11: laptop died "suddenly" — NOT a drain or suspend problem. Timeline from journal + upower history (`/var/lib/upower/history-*-L25N4PH0-75.dat`):

- s2idle suspend worked perfectly on pinned kernel 7.0.13: suspended Jul 10 17:26 (ac-unplug-suspend path), resumed Jul 11 11:06 lid-open; 80%→75% over 17.7 h (~0.3%/h drain — healthy baseline).
- Active drain ~8%/h (terminal work) was normal.
- Pack hard-cut from **indicated 54% straight to dead** at 13:44:58; voltage was 13.37 V (~3.34 V/cell = near-empty) — fuel gauge state-of-charge is badly miscalibrated.
- battery-notifications user service + mako were running the whole time; no alerts fired because reported capacity never crossed the ≤20% threshold. Script logic is fine; its input was wrong.
- Health: energy_full 47.8 Wh vs 75 Wh design = **64% at only 12 cycles**. Either gauge drift (conservation mode via TLP `STOP_CHARGE_THRESH_BAT0=1` means it never sees 100%, so never recalibrates) or a defective cell (sudden cutoff suggests cell undervoltage).

**Recalibration run (Jul 11 evening) — pack is HEALTHY, gauge was lost:**
- Full charge with `tlp fullcharge`: pack absorbed ~25 Wh *beyond* gauge-"100%" over ~3 h; CV setpoint 18.14 V = 4.53 V/cell — ATL 4-cell (L25N4PH0) new-gen silicon-carbon-class chemistry, NOT overvoltage (nominal 3.85 V/cell → voltage_min_design 15.4 V).
- Load discharge (16× `yes`, ~52 W): EC force-cut S5 at gauge-0% (19:55) with cells at 15.34 V = 3.83 V/cell ≈ half charge. True capacity ≈ 65–70 Wh of 75 design. Gauge over/under-counted vs own power meter by ±25–80% during run.
- Gauge re-learned at the empty event: energy_full 47.84 → **57.49 Wh** (+20%). Partial convergence; repeat full cycles converge further.
- Jul 12, after 2nd full cycle (cycle_count 15): energy_full → **64.60 Wh**. Steps shrinking (+9.7, +7.1) and 64.6 is at the bottom of the measured 65–70 Wh true-capacity band ⇒ near convergence.
- Jul 12, after 3rd/final cycle (cycle_count 16): energy_full → **70.1 Wh** = 93% of design, at the TOP of the measured true band ⇒ **CONVERGED, calibration DONE**. Gauge now tracks reality; EC 0%-cutoff will line up with a genuinely near-empty pack. STOP cycling — the +5.5 was the gauge catching up to truth, not hidden capacity; further cycles are pure wear. Don't chase the 75 Wh design number.
- Post-cycle reboot fully restores steady state on its own: conservation_mode=1 (80% cap), battery-notifications active, upower active + unmasked (runtime mask self-reverts), tlp active. Nothing to manually re-enable.
- Deep-discharge runs need: stop battery-notifications user service. Keep lid open (ADP0 udev rule + closed lid = suspend). EC re-queries ADP0 at low battery → spurious "Unplugged" notification ~5%. (Jul 12: `services.upower.enable` removed from config — upower was redundant boilerplate the battery-notifications script superseded on Jun 3, only ever did a hard PowerOff at 2% vs the script's graceful suspend at 5%. So the old `systemctl mask --runtime upower` step is now OBSOLETE — nothing to mask.)
- Reboot restores conservation_mode=1 (TLP) — must re-run `sudo tlp fullcharge BAT0` after any reboot mid-procedure.
- Firmware audited (Jul 11, acpidump → bmfdec on all WMI BMOF blobs): NO gauge-reset/calibration/forced-discharge method exists in this firmware at all — Vantage on Windows couldn't do it either (that feature is ThinkPad-line only). Only battery-adjacent interfaces: ideapad conservation mode (SBMC) + undocumented EC mailbox BTMC (SMM-handled, do not probe). Convergence-by-cycling and the powered-off USB-C drain trick are the only calibration paths.

**Why:** runtime is governed by gauge FCC (EC kills at gauge-zero regardless of real charge), so calibration accuracy = usable battery life. Warranty unnecessary if convergence continues; the cells themselves are fine.

**How to apply:** If runtime seems short again, check energy_full vs 75 Wh design and repeat a calibration cycle. (2) `fwupdmgr get-updates` for EC/battery firmware still worth doing; (3) optional config hardening — emergency suspend on voltage/time-to-empty, not capacity% alone. Related: [Kernel 7.1.0 s2idle suspend hang](kernel-7.1.0-s2idle-suspend-hang.md) (this incident confirms 7.0.13 s2idle is solid), apply-config-with-update-my-nix.
