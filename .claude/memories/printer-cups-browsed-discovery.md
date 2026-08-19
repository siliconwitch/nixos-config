# Label printer served by cups-browsed discovery

Brother QL-1110NWB label printer is served by cups-browsed auto-discovery (implicitclass://); declarative ensurePrinters was removed (Jul 2026) because it duplicated that queue and failed rebuilds when the printer was off.

The Brother QL-1110NWB label printer (mDNS `BRNB42200F82A4F.local`, seen at 192.168.0.60) is an AirPrint/IPP-Everywhere device, and its CUPS queue is provided by **cups-browsed auto-discovery**, NOT by declarative config. `lpstat -v` shows `device for Brother_QL_1110NWB: implicitclass://Brother_QL_1110NWB/` — the `implicitclass://` backend is cups-browsed. cups-browsed is on by default because avahi is enabled (`services.printing.browsed.enable` defaults to `services.avahi.enable`). So `services.printing.enable = true` + avahi is all that's needed; the queue appears on demand with the right name.

**History (2026-07-13):** the config previously declared the queue via `hardware.printers.ensurePrinters` + `model = "everywhere"`. That failed `nixos-rebuild switch` (exit 4) two ways: (1) `everywhere` makes lpadmin do a live IPP query to the printer at *every* switch, so a powered-off printer → mDNS name unresolved → lpadmin fails; and (2) even with the printer ON, cupsd's own back-to-back `.local` lookup raced and failed ("Unable to connect … Name or service not known") right after `getent` had resolved it — the known CUPS + nss-mdns `.local` flakiness (see [Chromium fails .local mDNS lookups](chrome-local-mdns-resolution.md), nixpkgs#118628). It was also redundant/conflicting: cups-browsed already owned the same-named queue. **Fix = removed the ensurePrinters block entirely** (plus a short-lived `getent` ExecCondition gate that couldn't fix cause 2). Do not re-add it — there's a comment in configuration.nix explaining why.

**Verified facts worth keeping:**
- mDNS here is fast/reliable when settled (getent + TCP to both the IP and the `.local` name all ~5–8 ms, 5/5). The rebuild failure was a transient cold-mDNS stall (~5 s) + cupsd race, not a persistent break.
- `avahi-resolve -4 -n <name>` returns **exit 0 even on failure** — useless as a reachability gate. Use `getent ahostsv4 <name>` (exit 2 when unresolved) if ever gating on resolution.
- CUPS 2.4.x `everywhere` re-poll on a failed connect flags the queue `temporary` and can tear it down (dropped from printers.conf, PPD deleted after ~5 min idle) — another reason not to pair ensurePrinters+everywhere with an often-off printer.
- No static CUPS driver/PPD for the QL-1110NWB in nixpkgs (`ptouch-driver` tops out at QL-820NWB; `brlaser`/`cups-brother-*` are laser-only), so there's no clean declarative-without-device-contact route anyway.

If a fixed, always-present declarative queue is ever wanted instead: disable `services.printing.browsed`, pin the printer's IP (static/DHCP reservation) via `networking.hosts` so `.local` resolves instantly, and gate ensurePrinters on TCP reachability. Discovery was chosen for minimalism + resilience to the printer's IP changing.

Apply config changes with a direct `sudo nixos-rebuild switch --flake /home/raj/.config#mist`, not `update-my-nix` (apply-config-with-update-my-nix), while nixpkgs is rolled back for the gdal-minimal breakage.
