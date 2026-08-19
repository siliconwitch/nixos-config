# Bluetooth wedges until a cold power cycle

On mist, Intel btintel_pcie Bluetooth can wedge in "error state" after a crash/warm reboot; a full cold power-off recovers it.

`mist` has an **Intel PCIe-attached Bluetooth** controller (driver `btintel_pcie`, firmware `intel/ibt-00a0-01a1-pci.sfi`). After a compositor crash or a warm reboot it can come up dead: firmware loads, then `Bluetooth: hci0: Controller in error state` + `Timeout … on alive interrupt (intel_reset1)` + `Failed to send frame (-62)`. `rfkill` shows it unblocked and `bluetooth.service` is active, but `bluetoothctl list` is empty.

**Fix:** a full **cold power-off** (`shutdown -h now`, wait ~10s, power on) — *not* a warm reboot — because the warm path doesn't power-cycle the PCIe BT controller. A `modprobe -r btintel_pcie && modprobe btintel_pcie` reload is worth trying first but the cold boot is the reliable reset. Confirmed working 2026-06-10.

Same root theme as [niri crashes from a Mesa iris Tile4 segfault](niri-mesa-iris-tile4-crash.md) and [Built-in audio on Panther Lake](builtin-audio-broken-panther-lake.md): very new Intel silicon, immature drivers on `linuxPackages_latest`.
