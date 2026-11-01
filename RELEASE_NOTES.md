# NightNight 1.0.0

NightNight 1.0.0 is the first public release of the iOS hibernation tweak. It hibernates an iPhone before the battery dies, isolates its radios while asleep, and restores the previous system state on wake.

## Highlights

- Automatic hibernation at a configurable battery threshold.
- Manual **Hibernate Now** from Settings.
- Airplane Mode on and Wi-Fi/Bluetooth off while hibernating. Calls and messages cannot arrive.
- Local notification silence while notifications remain in Notification Center.
- Tap, pencil, and lift wake blocked during hibernation.
- Wake by pressing the volume up button 3 times.
- Optional **Wake When Charger Connects**, including waiting for the next reconnect when already charging.
- Low Power Mode, media pause, screen lock, and backlight handling.
- Restores radios, ringer, Low Power Mode, lock, and proximity state after wake.
- Settings apply immediately; no respring is needed after changing them.

## Compatibility

| Build | Architecture | Compatibility |
|---|---|---|
| RootHide | `iphoneos-arm64e` | Tested on iOS 18.4.1 (Dopamine 3, RootHide) |
| Rootless | `iphoneos-arm64` | Expected to work on rootless jailbreaks |

Tested on iOS 18.4.1 (Dopamine 3, RootHide). The package does not declare an iOS version restriction.

## Assets

- `NightNight_1.0.0_roothide_iphoneos-arm64e.deb`
- `NightNight_1.0.0_rootless_iphoneos-arm64.deb`
- `SHA256SUMS.txt`

## Install

1. Download the deb matching your jailbreak.
2. Install with Sileo, Zebra, or Filza.
3. Respring after installation so SpringBoard loads the tweak and preference bundle.
4. Open **Settings → NightNight** to configure the sleep and wake thresholds.

## Verification

Verify the downloaded deb against `SHA256SUMS.txt` before installing.

## Notes

This release uses GitHub Releases and the GitHub Pages depiction. No APT repository is required.
