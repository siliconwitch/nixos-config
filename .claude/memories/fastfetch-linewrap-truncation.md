# fastfetch truncation is terminal DECAWM clipping

fastfetch truncation = terminal DECAWM clipping; last-column garbage char is inherent, upstream won't fix.

fastfetch 2.65.0 flipped `display.disableLinewrap` default to false (lines wrapped, breaking the logo layout); fixed 2026-07-11 by setting `"disableLinewrap": true` in `fastfetch/config.jsonc`.

The "truncation" is not fastfetch cutting strings — it only disables terminal auto-wrap (DECAWM), and the terminal overwrites the last column with each overflow character, so the last visible char is the string's *final* char (e.g. "workstation" → "workstan"). Inherent terminal behavior; upstream declined width-aware truncation (issue #321, closed not-planned). Raj chose to accept the artifact rather than cap fields with fixed-width `{name:-25}`-style ellipsis truncation (which exists but isn't terminal-width-aware and can't apply to static title text).
