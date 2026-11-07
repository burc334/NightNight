# NightNight 1.0.0

NightNight 1.0.0 is the first public release of the hibernation tweak for
jailbroken iOS 18.

## Highlights

- Automatic hibernation before the battery dies.
- Manual **Hibernate Now** action.
- Airplane Mode, Wi-Fi off, and Bluetooth off while hibernating.
- Local notification silence without creating a Focus mode.
- Tap and lift wake blocking.
- Wake by pressing the volume up button 3 times.
- Optional wake when the charger connects.
- Restores the previous radio, ringer, lock, and backlight state on wake.
- Rootless and RootHide packages.

## RootHide packaging

- The LaunchDaemon uses a stable logical launcher path.
- The compiled launcher resolves the current jailbreak root at runtime.
- The source plist never stores a randomized jbroot path.
- Missing-runner retries and the launchd throttle are 60 seconds.
- `prerm` and `postrm` stop the job and remove the launcher, plist, and ready
  marker.

## Compatibility

| Build | Architecture | Compatibility |
|---|---|---|
| RootHide | `iphoneos-arm64e` | Tested on iOS 18.4.1 (Dopamine 3, RootHide) |
| Rootless | `iphoneos-arm64` | Expected to work on rootless jailbreaks |

Tested on iOS 18.4.1 (Dopamine 3, RootHide). The package does not declare an iOS
version restriction.

## Assets

- `NightNight_1.0.0_roothide_iphoneos-arm64e.deb`
- `NightNight_1.0.0_rootless_iphoneos-arm64.deb`
- `SHA256SUMS.txt`

## Install

1. Download the deb matching your jailbreak.
2. Install with Sileo, Zebra, or Filza.
3. Respring after installation so SpringBoard loads the tweak and preference
   bundle.
4. Open **Settings → NightNight** to configure the sleep and wake thresholds.

## Verification

Verify the downloaded deb against `SHA256SUMS.txt` before installing.

## Notes

This release uses GitHub Releases and the GitHub Pages depiction. No APT
repository is required.
