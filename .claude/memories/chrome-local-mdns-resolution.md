# Chromium fails .local mDNS lookups

Chromium fails .local (mDNS) lookups intermittently via its own resolver even when system mDNS works — not a NixOS DNS bug.

Chromium uses its **own built-in DNS/mDNS resolver**, separate from glibc/nss-mdns/Avahi. It intermittently fails `.local` lookups → `ERR_NAME_NOT_RESOLVED`, **even when the system resolves the name 10/10** (`getent hosts`, `avahi-resolve`). It also caches the miss, so it can stay broken until the cache clears (a reboot, or time). `services.avahi` (nssmdns4 + openFirewall) and `nsncd` are fine — don't chase NixOS DNS config for browser-only `.local` failures.

Fixes:
- Immediate, no reboot: `chrome://net-internals/#dns` → Clear host cache (+ `#sockets` → Flush socket pools), then reload in a fresh tab.
- Durable (declarative): `networking.hosts."192.168.0.239" = [ "hifiberry.local" ];` — Chrome reads `/etc/hosts`, so no live mDNS lookup to fail. Pin with a router DHCP reservation. Optional; only add if the browser flakiness keeps recurring (minimalism).

Related: [HiFiBerry AirPlay no-audio is device-side](hifiberry-airplay-no-audio-device-side.md).
