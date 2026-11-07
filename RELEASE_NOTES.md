# NightNight 1.0.1

NightNight 1.0.1 is a packaging and launchd correctness update for RootHide. Hibernation, settings, and UI behavior are unchanged.

## RootHide launchd fix

- Removed install-time `@JBROOT@` substitution from the LaunchDaemon plist.
- The plist now uses a stable logical launcher path and never stores a randomized jbroot path in the source configuration.
- Added a small compiled launcher that resolves the current `.jbroot-*` at runtime.
- The launcher requires exactly one valid runner/dylib pair, with a rootless fallback.
- Missing-runner retries are spaced at 60 seconds; the launchd throttle is 60 seconds. The previous 1-second respawn loop cannot recur.
- The launcher supervises the runner and preserves the existing ready-marker behavior.
- `prerm` and `postrm` stop the job and remove the launcher, plist, and ready marker.

## Compatibility

| Build | Architecture | Compatibility |
|---|---|---|
| RootHide | `iphoneos-arm64e` | Tested on iOS 18.4.1 (Dopamine 3, RootHide) |
| Rootless | `iphoneos-arm64` | Expected to work on rootless jailbreaks |

Tested on iOS 18.4.1 (Dopamine 3, RootHide). The package does not declare an iOS version restriction.

## Assets

- `NightNight_1.0.1_roothide_iphoneos-arm64e.deb`
- `NightNight_1.0.1_rootless_iphoneos-arm64.deb`
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
