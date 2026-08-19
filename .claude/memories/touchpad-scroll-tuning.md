# Touchpad scroll tuning

How touchpad scroll speed is tuned per-app via niri window-rule scroll-factor (terminals fast, GUI comfortable); foot multiplier is primary-screen-only.

Touchpad scroll speed is tuned per-application using niri's **window-rule `scroll-factor`** (niri 26.04; the property landed in 25.02). The window-rule factor is *multiplied* with the input-device factor: `effective = input.touchpad.scroll-factor × window-rule.scroll-factor`.

Current setup in `niri/config.kdl`:
- `input { touchpad { scroll-factor 0.5 } }` — the comfortable global GUI speed for every GUI app.
- `window-rule { match app-id=r#"^foot"#; scroll-factor 2.0 }` — boosts foot terminals only, so terminals = `0.5 × 2.0 = 1.0` (smooth + fast for helix/Claude Code etc.). The terminals' app-id is **`footclient`** (also `foot.launcher`, `footclient.floating`) — `^foot` matches all.

Other settings:
- `foot/foot.ini` `[scrollback] multiplier = 4` — affects ONLY the primary-screen scrollback (cat/bat/shell); foot deliberately does NOT apply it on the alternate screen (issue #787), so it does nothing for TUIs. With foot's effective scroll-factor 1.0, cat/bat ≈ `1.0 × 4`.
- TUIs scroll by whole lines; per-app per-notch step (helix `scroll-lines`, Claude Code `CLAUDE_CODE_SCROLL_SPEED`, default ~3) is left at default — cranking it makes scrolling chunky, not smooth.

**Why this design:** earlier approach was global scroll-factor 1.0 + a Firefox `user.js` damper (`mousewheel.default.delta_multiplier_{x,y}`). The window-rule replaces that: GUI speed is set once globally and terminals are boosted in isolation, so no Firefox-specific hack and all GUI apps stay consistent. The Firefox `user.js` (in the untracked profile `p1rvxb1f.default`) was reset to 100 (no-op) and can be deleted after one Firefox restart.

To apply: niri auto-reloads; restart Firefox once to clear the sticky delta_multiplier from prefs.js; open a new foot window for the multiplier.
