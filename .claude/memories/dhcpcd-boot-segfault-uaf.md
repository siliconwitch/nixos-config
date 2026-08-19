# dhcpcd boot segfault, use-after-free

dhcpcd 10.3.2 UAF segfault on most boots since 2026-06-02 (fixed upstream in 10.5.0 b6588aa6, nixpkgs unpatched); trigger was iwd EnableNetworkConfiguration + dhcpcd both on wlan0. RESOLVED 2026-08-13 by dropping EnableNetworkConfiguration so dhcpcd owns all DHCP. Also records the trap that made the first attempt at this kill DNS.

Recurring boot-time coredump: `dhcpcd: [manager]` (uid 993, Unit dhcpcd.service) SIGSEGV/GPF right after taking its wlan0 lease. First seen 2026-06-02 on dhcpcd 10.3.1 (hostname still "storm"); 27 dumps across 6 store paths by Aug 13. NOT related to kernel rc6/rc7 or the Aug updates. **Zero connection to the Aug 13 desktop incident** (see [13 August 2026: agent benchmarks killed the compositor](aug13-desktop-killed-by-agent-benchmarks.md)).

Fingerprint: two `wlan0: ipv4_deladdr: Bad file descriptor` lines (hidden by journalctl as "[37B blob data]", decode raw MESSAGE bytes) immediately before the dump; stack `dhcp_readbpf -> dhcp_packet -> dhcp_bind -> ipv4_applyaddr -> ipv4_deladdr [-> arp_freeaddr -> arp_find]`. Two flavours (segfault-at-0 in ipv4_deladdr vs GPF in arp_find) = same freed chunk, different glibc tcache poison.

Root cause upstream: Linux-only use-after-free of `old_ia` in ipv4_applyaddr. **Fixed in dhcpcd b6588aa6 (2026-06-23), first release 10.5.0 (2026-08-05); nixpkgs still 10.3.2, unpatched.** Local trigger: two DHCP clients on wlan0 (iwd's `EnableNetworkConfiguration` plus NixOS's default dhcpcd), so iwd churned addresses under dhcpcd. ArchWiki says pick one; the NixOS module has no assertion.

## Resolution (2026-08-13)

Raj chose: **dhcpcd owns DHCP and DNS on every interface, iwd associates only.** Config is now just `networking.wireless.iwd.enable = true;` with no `settings` and no per-interface `useDHCP`. Picked over the iwd-owns-it alternative because `networking.useDHCP` (default true) covers USB ethernet adapters automatically, whatever they enumerate as, with no per-interface config. Verified: the generated dhcpcd.conf `denyinterfaces` line loses `wlan0`. **Segfault fix is by trigger-removal, not a patched dhcpcd, so confirm over a few boots with `coredumpctl list dhcpcd`.**

## Trap: the first attempt at this broke DNS entirely

Commit ba42fdf tried to de-duplicate DHCP the *other* way, keeping `EnableNetworkConfiguration` and adding `networking.interfaces.wlan0.useDHCP = false`. That killed all name resolution (IP and default route were fine; iwd's). Reason: **iwd's `NameResolvingService` defaults to `systemd`, i.e. systemd-resolved, which is not enabled on this box** (`systemctl is-enabled systemd-resolved` → `not-found`), so iwd had nowhere to put DNS. dhcpcd had been supplying nameservers by accident all along; denying it wlan0 (`dhcpcd: no valid interfaces found` in the journal) left resolv.conf empty. Raj hand-wrote `nameserver 1.1.1.1` to recover, and could not rebuild until he did.

If iwd ever owns IP config again it MUST also set `Network.NameResolvingService = "resolvconf"` (iwd 3.12 accepts `resolvconf|systemd|none`). That backend does work here: the nixpkgs iwd module already puts openresolv in the unit's PATH and sets `ReadWritePaths=-/etc/resolv.conf`; verified via `/proc/<iwd pid>/mountinfo` that `/run` is rw and resolv.conf is bind-mounted rw despite `ProtectSystem=strict`.

**Why:** these dumps will keep appearing in coredumpctl and could mislead future crash investigations (they already made an "unstable system" report look worse than it was), and the DNS trap is invisible until something needs to resolve a name.

**How to apply:** don't treat these dumps as evidence of new instability. A hand-edited `/etc/resolv.conf` is resolvconf-managed here (`root:resolvconf` 664) and gets wiped on the next `resolvconf -u`; the tell that it is hand-written is a missing `options edns0` line. To rebuild while DNS is broken, use a plain `nixos-rebuild switch` rather than apply-config-with-update-my-nix, since a flake update needs the network but an unchanged input set does not.
