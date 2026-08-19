2026-08-18 10:10 CEST

# HiFiBerry IPv6 mDNS record shadows its IPv4 one in PipeWire RAOP discovery

The recurring "HiFiBerry missing after resume" is a host-side race between the device's IPv4 and IPv6 `_raop._tcp` records, made fatal by the anti-hijack pin; fixed with `services.avahi.ipv6 = false`.

**Mechanism (pipewire 1.6.8 `src/modules/module-raop-discover.c`):** the tunnel list is keyed by mDNS **service name alone**, with no protocol in the key. `resolver_cb` calls `make_tunnel()` and appends the entry *before* `stream.rules` are evaluated. `browser_cb` then rejects any later announcement for a name already in the list:

```c
info = TUNNEL_INFO(.name = name);
t = find_tunnel(impl, &info);
case AVAHI_BROWSER_NEW:
        if (t != NULL) {
                pw_log_info("found duplicate mdns entry - skipping tunnel creation");
                return;
        }
```

So the first protocol to be announced claims the name. The pin `raop.ip = "~^[0-9.]+$"` rejected the IPv6 address, so no sink module was attached, but the tunnel entry was already registered. The IPv4 announcement then hit that duplicate check and was discarded without ever being resolved. Nothing retries. Permanently dead until the module is reloaded or avahi sends a `BROWSER_REMOVE`.

**Why it lost every resume.** IPv6 link-local is instant, IPv4 waits for DHCP:

```
08:44:43  wlan0 carrier lost, avahi drops both interfaces
08:44:43  airplay-rescan restarts pipewire
08:44:44  avahi rejoins IPv6
08:44:49  avahi rejoins IPv4
```

Five second head start for IPv6, deterministic. Proven by restarting pipewire by hand with the network settled: sink back in 2 s.

**Fix (`configuration.nix`):** `services.avahi.ipv6 = false`, and the now-pointless `raop.ip` clause dropped from the pin. `raop.hostname = "~hifiberry"` stays and is still what excludes the MacBook. Verified after switch: `use-ipv6=no`, one `;IPv4;` row in `avahi-browse -rpt _raop._tcp` and no IPv6 row, exactly one raop-discover module, sink present.

**`airplay-rescan` kept.** It was never the cause, only ineffective: the shadowing kills the sink with or without a pipewire restart. It also does not cover the Jul 21 `nixos-rebuild switch` trigger, which fires on `suspend.target` only. Kept as a safety net because whether resume now self-heals is still unproven.

**Corrects the Jul 13 root cause.** "A morning resume produces no announcement, so no sink appears" was most likely this shadowing seen from outside: the pin had been in place since Jun 19, and a device announcing fine with no sink is exactly what the shadow looks like. Also explains the Jul 21 and Aug 4 "stale browse session" observations, where IPv4 returned but the running discover never built a sink: on an avahi client disconnect the browser is freed and recreated but the tunnel list survives, so the recreated browser skips the name as a duplicate. Only `BROWSER_REMOVE` and `impl_free` ever clear tunnels.

**Discriminator unchanged.** Check `avahi-browse -rpt _raop._tcp | grep ';IPv4;'` first. Absent means the device-side IPv6-only wedge, power-cycle the box. Present with no sink means this host-side bug.

**Does not regress the Aug 4 decision.** "Do not relax the pin to hostname-only" was justified by duplicate sinks from both-family announcements, which cannot occur with IPv6 mDNS off. The two changes are coupled and must not be separated: restoring IPv6 mDNS without restoring the `raop.ip` clause would bring the duplicates back.

**`sess.latency.msec` warning stays benign, with the arithmetic.** `rtp.ptime` 7.981859 ms is 352 frames at 44.1 kHz; 2000 ms is 88200 frames, which is 250.57 packets, so `module-rtp/stream.c` warns and `SPA_ROUND_DOWN`s to 88000 frames, giving an actual 1995.46 ms. The only exact values are 1995.4648 and 2003.4467 ms. PipeWire's own RAOP default of 250 ms is 11025 frames and also warns. Upstream cosmetic wart, leave the 2000 alone.

**Pending:** first real resume after this change. Watch whether the sink is present before `airplay-rescan` fires. Also unreported upstream: keying tunnels by name without the protocol is wrong regardless of anyone's filter rules.

Related: [HiFiBerry sink missing after a morning resume](hifiberry-sink-missing-morning-resume.md), [Stray AirPlay receiver hijacks the HiFiBerry stream](airplay-stray-device-hijack.md), [Duplicate HiFiBerry sink from a stray PipeWire drop-in](hifiberry-duplicate-raop-sink-stray-dropin.md), [HiFiBerry AirPlay no-audio is device-side](hifiberry-airplay-no-audio-device-side.md)
