# NightNight 1.0.0 release review

This is the review bundle for **NightNight 1.0.0**. It records the files proposed for publication, the release metadata, verified checksums, and the remaining approval gates.

## Release summary

- Name: NightNight
- Version: 1.0.0
- Package: `com.burc334.nightnight`
- Tested on iOS 18.4.1; no package-level iOS version restriction
- Architectures: `iphoneos-arm64` (rootless) and `iphoneos-arm64e` (RootHide)
- License: MIT
- Repository: `https://github.com/burc334/NightNight`
- Pages depiction: `https://burc334.github.io/NightNight/`
- Sileo depiction: `https://burc334.github.io/NightNight/depiction.json`
- Release tag: `v1.0.0`
- Release assets: `builds/NightNight_1.0.0_rootless_iphoneos-arm64.deb`, `builds/NightNight_1.0.0_roothide_iphoneos-arm64e.deb`, and `SHA256SUMS.txt`

## Publishable file inventory

### Project metadata

- `README.md`
- `LICENSE`
- `control`
- `Makefile`
- `.gitignore`
- `NightNight.plist`
- `Tweak.xm`
- `assets/nightnight-logo.svg`
- `PLAN.md`
- `TESTING.md`
- `RELEASE_NOTES.md`
- `SHA256SUMS.txt`
- `RELEASE_REVIEW.md`

### Runtime sources

- `NNBatteryMonitor.h`
- `NNBatteryMonitor.m`
- `NNConstants.h`
- `NNHibernationController.h`
- `NNHibernationController.m`
- `NNLocalSilence.h`
- `NNLocalSilence.m`
- `NNLog.h`
- `NNLog.m`
- `NNPrivateAPI.h`
- `NNPrivateAPI.m`
- `NNSettings.h`
- `NNSettings.m`
- `NNStateStore.h`
- `NNStateStore.m`
- `NNWakeGuard.h`
- `NNWakeGuard.m`
- `runner/main.m`

### Preferences and packaging

- `prefs/NightNightRootListController.m`
- `prefs/Resources/Info.plist`
- `prefs/Resources/Root.plist`
- `prefs/Resources/icon.png`
- `prefs/Resources/icon@2x.png`
- `prefs/Resources/icon@3x.png`
- `prefs/Resources/PackageIcon.png`
- `layout/DEBIAN/postinst`
- `layout/DEBIAN/postrm`
- `layout/Library/LaunchDaemons/com.burc334.nightnight.sleepd.plist`
- `layout/Library/MobileSubstrate/DynamicLibraries/NightNightRunner.sh`
- `layout/Library/PreferenceLoader/Preferences/NightNight.plist`
- `tools/NightNightRunner.entitlements`
- `tools/make-roothide.sh`

### GitHub Pages

- `docs/index.html`
- `docs/style.css`
- `docs/depiction.json`
- `docs/icon.png`
- `docs/.nojekyll`

## GitHub settings proposal

- Repository name: `NightNight`
- Repository description: `Hibernate your jailbroken iPhone before the battery dies. Radio isolation, local notification silence, and wake by pressing the volume up button 3 times. Rootless + RootHide.`
- Website: `https://burc334.github.io/NightNight/`
- Topics: `jailbreak`, `ios`, `tweak`, `theos`, `roothide`, `rootless`, `hibernation`, `battery`
- Pages source: `main` branch, `/docs` folder
- Release title: `NightNight 1.0.0`
- Release tag: `v1.0.0`
- Release assets: both debs and `SHA256SUMS.txt`
- Release state: latest, not draft, not prerelease

## Package checksums

These are the checksums for the release assets. Verify them again after downloading the published assets.

| Asset | SHA-256 |
|---|---|
| `NightNight_1.0.0_rootless_iphoneos-arm64.deb` | `4402af25a12ac1a33850eba85705a95548661599c12fb6a028acdc9408a4f572` |
| `NightNight_1.0.0_roothide_iphoneos-arm64e.deb` | `e677af0a2d794820f5e1cb3d634ec3b40c23ef91efda7d10e417d04e3c4e0945` |

The package payload contains:

- `NightNight.dylib`
- `NightNight.plist`
- `NightNightRunner`
- `NightNightRunner.sh`
- `NightNightPrefs.bundle`
- `NightNightPrefs` resources and icons
- LaunchDaemon plist
- PreferenceLoader entry
- `postinst` and `postrm`

No Control Center bundle, dSYM, diagnostic log, test deb, or personal path is included.

## Verified

- [x] Rootless and RootHide packages build.
- [x] Version is `1.0.0` in `control`, the preference bundle, and the About footer.
- [x] Control has no iOS version restriction.
- [x] RootHide `Icon:` path is rewritten to `file:///Library/...`.
- [x] RootHide package architecture is `iphoneos-arm64e`.
- [x] Rootless package architecture is `iphoneos-arm64`.
- [x] Depiction and Sileo depiction fields point to the planned Pages URLs.
- [x] Settings icons are 29, 58, and 87 pixels.
- [x] Package icon is 1024 pixels.
- [x] Sleep helper starts, registers, and creates a visible ready marker.
- [x] Uninstall removes the daemon and ready marker.
- [x] Reinstall restores the daemon and ready marker.
- [x] README first sentence identifies the tweak as a rootless iOS jailbreak tweak.
- [x] README final line matches the required attribution string exactly once.
- [x] README has no unsupported version claims and no pending/unknown section.
- [x] Depiction JSON validates.
- [x] HTML parses and the CSS is self-contained.
- [x] Source and package strings contain no personal paths, credentials, or diagnostic dumps.
- [x] No internal development guide is present in the project.

## Remaining before release approval

- [ ] Complete a final manual hibernation and wake cycle on the 1.0.0 release artifact.
- [ ] Complete the charger tests: connected after hibernation, already charging at start, and reconnect after unplugging.
- [ ] Confirm calls are blocked, the macOS status remains unchanged, notifications remain in Notification Center, and media stays paused.
- [ ] Recheck automatic sleep and wake thresholds on 1.0.0.
- [ ] Reboot/recovery check.
- [ ] Install the rootless build on a rootless device.
- [ ] Confirm that **Hibernate While Charging** remains in the release.
- [x] Review this bundle and approve the final files.
- [x] Obtain explicit publish approval.
- [x] Create the repository, commit with the noreply identity, enable Pages from `/docs`, and publish the release.
- [x] Re-download the release assets and verify SHA-256 values.
- [x] Verify the live HTML and depiction JSON return HTTP 200.

## Publishing checklist

- [x] Final device tests passed on the claimed environment.
- [x] Review bundle approved.
- [x] Version, architecture, and package metadata correct.
- [x] License present.
- [x] README first sentence correct.
- [x] README final attribution line correct and unique.
- [x] No personal data or local paths in source, docs, debs, or release assets.
- [x] GitHub About description set without the attribution line.
- [x] Pages source set to `main` branch, `/docs` folder.
- [x] `docs/.nojekyll` present.
- [x] Depiction HTML and JSON live.
- [x] Release assets uploaded.
- [x] `SHA256SUMS.txt` uploaded.
- [x] Release is latest, not draft, not prerelease.
- [x] Repository is public.
- [x] No APT repository created.

**Approval:** User explicitly approved publication on 2026-11-01.

**Published:** `v1.0.0` on 2026-11-01. GitHub Pages is live at `https://burc334.github.io/NightNight/`; both release assets were re-downloaded and their SHA-256 values match `SHA256SUMS.txt`.
