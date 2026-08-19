# HiFiBerry AirPlay no-audio is device-side

HiFiBerry AirPlay "shows in mixer but no audio" is device-side Shairport state, not a PipeWire/IPv6 config bug.

HiFiBerry (Shairport Sync, `hifiberry.local` / 192.168.0.239) AirPlay showed up in the PipeWire mixer but played no audio. Cause was a **device-side stuck Shairport session**, fixed by **restarting the HiFiBerry sink/device** — NOT a NixOS config issue.

Key correction to avoid repeating: PipeWire's `module-raop-discover` binds the RAOP sink to the device's **IPv6 link-local** address (`fe80::e65f:1ff:fe0c:e9c3%3`, scope = wlan0). This works fine for audio once the device is healthy (sink goes `SUSPENDED` → `RUNNING`). Do **not** chase `services.avahi.ipv6 = false` or the link-local address as the cause — verified same address streams audio correctly after a device restart.

Related: [Chromium fails .local mDNS lookups](chrome-local-mdns-resolution.md).
