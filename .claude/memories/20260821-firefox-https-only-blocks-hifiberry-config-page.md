2026-08-21 08:59 CEST

# Firefox HTTPS-Only Mode blocks the HiFiBerry config page

"Can't connect to hifiberry.local in Firefox" while curl gets HTTP 200: the device serves HTTP only (port 443 refuses), and Firefox has HTTPS-Only Mode on, so the forced upgrade fails. Not a DNS or NixOS problem.

**Verified 2026-08-21:**

- `curl http://hifiberry.local/` and `curl http://192.168.0.239/` both return 200.
- Port 443 on 192.168.0.239 refuses the connection. The device has no HTTPS listener.
- `prefs.js` has `dom.security.https_only_mode=true` and `network.trr.mode=3`. TRR mode 3 still resolves `.local` natively (built-in exclusion), and `getent hosts hifiberry.local` returned 192.168.0.239, so name resolution was never the problem. Do not chase the Chromium `.local` resolver issue ([Chromium fails .local mDNS lookups](chrome-local-mdns-resolution.md)); Firefox uses the system resolver here.
- Firefox's profile lives at `~/.config/mozilla/firefox/`, not `~/.mozilla`. Grep prefs there.

**Fix:** click "Continue to HTTP Site" on the error page, or add a durable exception: Settings → Privacy & Security → HTTPS-Only Mode → Manage Exceptions → `http://hifiberry.local`. Typing `http://` in the URL bar does not bypass HTTPS-Only Mode.

**Same-day companion finding:** "connected but no sound" was not the Shairport wedge this time. The raop sink existed, was the default, and was unmuted, but its volume sat at 6% (-73 dB), which is silence. Check `pactl list sinks` volume before reaching for the [device-side restart](hifiberry-airplay-no-audio-device-side.md) or the [IPv4 discriminator](20260818-hifiberry-ipv6-mdns-record-shadows-ipv4.md).

Related: [HiFiBerry sink missing after a morning resume](hifiberry-sink-missing-morning-resume.md)
