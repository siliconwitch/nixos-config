# AirPlay stutter tracks transient system freezes

HiFiBerry/AirPlay STUTTER (not no-audio) tracks transient system freezes (KiCad coredumps, script bursts), not local audio or WiFi bandwidth.

> ⚠️ UPDATE 2026-06-19: the stutter that **recurred** was a DIFFERENT cause — a stray AirPlay receiver ("Raj's MacBook Air") hijacking the stream, see [Stray AirPlay receiver hijacks the HiFiBerry stream](airplay-stray-device-hijack.md). The freeze pattern below was real on 2026-06-18 but did NOT apply to the 2026-06-19 recurrences (PSI clean, no coredump, no WiFi drop; the music *paused*, implicating sink teardown not radio starvation). Check for stray `_raop._tcp` advertisers FIRST.

Live diagnosis 2026-06-18 of the recurring AirPlay/HiFiBerry **stuttering** (distinct from the no-audio issue in [HiFiBerry AirPlay no-audio is device-side](hifiberry-airplay-no-audio-device-side.md) and [Duplicate HiFiBerry sink from a stray PipeWire drop-in](hifiberry-duplicate-raop-sink-stray-dropin.md)).

Ruled OUT by measurement while reproducing under load:
- **Not local PipeWire**: RAOP sink (node) + Chromium source show `ERR=0` (no xruns) at idle AND under full CPU saturation. The `sess.latency.msec=2000` RAOP buffer absorbs any CPU/scheduling stall < ~2s.
- **Not WiFi bandwidth/airtime**: saturating the link to 257 Mbit/s (8 parallel downloads) gave 0% packet loss to the device (192.168.0.239) and no BT drop.
- **Not a logged card fault**: `journalctl -k` across boots shows zero iwlwifi/btintel/PCIe-AER errors; only clean DEAUTH_LEAVING.

Real trigger = a transient **system freeze** ("everything lagged for a second"): KiCad SIGSEGVs often (`_eeschema.kiface`) → `systemd-coredump` dumps its multi-GB core = a few-second CPU+I/O storm. Claude running scripts = similar process/I/O bursts. Co-symptom: **Bluetooth (Magic Keyboard/Trackpad) drops too** — WiFi+BT are the same Intel CNVi module (PCI `0000:00:14.3`), so a contiguous freeze starving the card's kernel-side servicing drops audio UDP packets (no retransmit → audible gap) AND trips BT supervision timeout. See [Bluetooth wedges until a cold power cycle](panther-lake-bt-cold-boot-recovery.md).

Separately found (real defect, but NOT the stutter cause given the 2s buffer): **PipeWire's data-loop is not real-time** — `module-rt` asks `rt.prio=88`, rtkit ceiling is ~20 and pipewire's `RLIMIT_RTPRIO=0`, so the thread silently stays `SCHED_OTHER`. Worth fixing as hygiene.

**Why:** every past attempt chased local audio / WiFi; the cause is upstream (transient freeze starving the shared Intel radio).
**How to apply:** when stutter recurs, don't re-investigate local PipeWire or WiFi bandwidth. Reproduce via a coredump-style freeze. Candidate fixes (verify against NixOS docs first): tame `systemd.coredump` (KiCad crashes a lot), PCIe ASPM (`/sys/module/pcie_aspm/parameters/policy` was `[default]`), and the PipeWire RT fix.
