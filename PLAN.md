# NightNight — 1.0.0 release plan

## Goal

Publish NightNight 1.0.0 as a rootless and RootHide jailbreak tweak with a tested hibernation cycle, clear documentation, and a GitHub Pages depiction. The package declares no iOS version restriction; behavior is tested on iOS 18.4.1.

## Scope

- Automatic and manual hibernation.
- Radio isolation while hibernating.
- Local notification silence with Notification Center preservation.
- Tap/lift wake blocking and wake by pressing the volume up button 3 times.
- Optional charger-connect wake.
- Low Power Mode, media pause, lock, and backlight handling.
- Recovery snapshot and state restoration.
- Settings pane with live preference updates.
- Rootless and RootHide packaging.
- GitHub README, release notes, test log, static depiction, and release review bundle.

## Non-goals

- An APT repository.
- A Control Center module.
- Third-party sleep or focus integrations.
- Analytics, telemetry, or network services.
- Automatic media resume after wake.

## Environment

- macOS with Xcode, Theos, ldid, and dpkg-deb.
- RootHide release built with the project RootHide conversion script.
- Tested device: iOS 18.4.1, Dopamine 3, RootHide.

## Evidence inspected

- Runtime source, preference bundle, launch daemon, wrapper, and packaging scripts.
- Rootless and RootHide deb metadata and payloads.
- Settings and package icon dimensions.
- Uninstall and reinstall behavior.
- GitHub Pages depiction structure and JSON.
- Source and release artifacts for personal paths and test files.

## Risks and unknowns

- The rootless build has not been installed on a second rootless device.
- The final charger behavior needs a physical charger test on 1.0.0.
- The final hibernation cycle needs a physical wake test on 1.0.0.
- The depiction URLs become live only after GitHub Pages is enabled.

## Milestones

1. Finish release documentation and depiction.
2. Build rootless and RootHide 1.0.0 release artifacts.
3. Install the RootHide artifact and complete final device checks.
4. Produce the review bundle and hashes.
5. User review and explicit publish approval.
6. Create the public repository, enable Pages, publish the release, and verify assets.

## Test matrix

- Fresh install and upgrade.
- Manual hibernation and wake by pressing the volume up button 3 times.
- Automatic sleep and wake thresholds.
- Charger connected after hibernation.
- Already charging at hibernation; unplug/reconnect wake.
- Call blocking.
- Notification Center preservation.
- macOS status remains unchanged.
- Media remains paused after wake.
- Reboot/recovery.
- Uninstall and reinstall.
- Rootless package on a rootless device.

## Packaging

- Rootless: `NightNight_1.0.0_rootless_iphoneos-arm64.deb`
- RootHide: `NightNight_1.0.0_roothide_iphoneos-arm64e.deb`
- Hashes: `SHA256SUMS.txt`
- Depiction: `https://burc334.github.io/NightNight/`
- Sileo depiction: `https://burc334.github.io/NightNight/depiction.json`

## Publishing

No repository creation, commit, push, Pages enablement, release, or asset upload is part of release preparation. Those actions require explicit publish approval.

## Confidence

Build and packaging confidence is high. Behavioral confidence remains dependent on the final physical-device checks listed above.
