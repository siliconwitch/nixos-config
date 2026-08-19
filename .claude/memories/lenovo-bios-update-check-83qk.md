# Checking for Lenovo BIOS updates from Linux

How to check for Lenovo BIOS updates for the Yoga Slim 7 Ultra 14IPH11 (machine type 83QK) from Linux, and current BIOS status.

Machine type is **83QK** (from `/sys/class/dmi/id/product_name`). Lenovo does NOT publish this consumer model's BIOS to LVFS, so fwupd will never see updates — check Lenovo's System Update catalog directly:

```sh
curl -s "https://download.lenovo.com/catalog/83qk_win11.xml" | grep -A1 "BIOS UEFI"   # find package XML
curl -s "https://download.lenovo.com/consumer/mobiles/<pkg>.xml"                       # version + ReleaseDate + readme name
curl -s "https://download.lenovo.com/consumer/mobiles/shcnXXww.txt"                    # changelog
```

Status 2026-07-14: installed **SHCN33WW** (flashed successfully from SHCN31WW via the Linux fwupd route below — full procedure now verified END-TO-END on this machine). Post-flash ESRT version 1899364403. Changelogs: 32 = "Support Samsung 16G memory", 33 = "Add and override BOE panel edid". No audio/SoundWire fix as of 33.

**Why:** watching for a BIOS that fixes the SoundWire dual-source tables (phantom RT722) — see [Built-in audio on Panther Lake](builtin-audio-broken-panther-lake.md). That would be the one BIOS worth flashing (via WinPE stick or capsule extraction + fwupdtool, since updater is Windows-only .exe).

**How to apply:** when asked about BIOS/firmware updates, run the catalog check above and read the changelog for audio/SoundWire/RT722/cs42l43 mentions before recommending anything.

## Verified Linux flash procedure (used successfully 2026-07-14 to flash SHCN33WW)

The exe is **Insyde iFdPacker** (7zS SFX, `RunProgram="H2OFFT-Wx64.exe -sfx7z"`), embedded archive is OBFUSCATED — plain `7z x`/`unzip`/`innoextract` all FAIL. Extraction that works: python venv + `pip install biosutilities pefile dissect.util lznt1`, then `InsydeIfdExtract(input_object='shcnXXww.exe', extract_path='out')` (needs `7z` binary in PATH, e.g. `nix shell nixpkgs#p7zip`). Yields `SHCNXXWW.fd` (iFlash package: BIOS-UEFI image + embedded isflash.efi + platform.ini + BIOSCER certificate — BIOS verifies its own signature at flash time).

Flash route = fwupd capsule (nadimkobeissi/lenovo-bios-fwupd recipe, adapted since its 7z step fails here): pack `firmware.bin` (the .fd) + metainfo XML (`<firmware type="flashed">` = ESRT fw_type=1 GUID **e206e9c7-7040-49ec-a398-92234343be69**, release version = current ESRT version+1; current on SHCN31WW = 1899364401) with `gcab --create`, set `services.fwupd.daemonSettings.OnlyTrusted = false` (option verified in nixpkgs; revert after), then `sudo fwupdmgr local-install <cab> --allow-reinstall` + reboot on AC. NB fwupd 2.x: it's `local-install` for cab files, not `install`. This machine updates via capsule-on-disk; the benign-looking "Update Error: ->convert_version not implemented" in get-details is a cosmetic fwupd quirk on COD devices, not a blocker. Insyde firmware verifies + processes the iFlash package itself at boot. Alternative: WinPE/Hiren's USB running the exe. BIOS flash = NOT covered by NixOS generation rollback; BIOS settings may reset.
