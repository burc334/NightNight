# NightNight 1.0.1 release review

This is the review bundle for **NightNight 1.0.1**. It records the files prepared for publication, the release metadata, and the verification status.

## Release summary

- Name: NightNight
- Version: 1.0.1
- Package: `com.burc334.nightnight`
- Tested on iOS 18.4.1; no package-level iOS version restriction
- Architectures: `iphoneos-arm64` (rootless) and `iphoneos-arm64e` (RootHide)
- License: MIT
- Repository: `https://github.com/burc334/NightNight`
- Pages depiction: `https://burc334.github.io/NightNight/`
- Sileo depiction: `https://burc334.github.io/NightNight/depiction.json`
- Release tag: `v1.0.1`
- Release assets: `builds/NightNight_1.0.1_rootless_iphoneos-arm64.deb`, `builds/NightNight_1.0.1_roothide_iphoneos-arm64e.deb`, and `SHA256SUMS.txt`

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
- `launcher/main.c`

### Preferences and packaging

- `prefs/NightNightRootListController.m`
- `prefs/Resources/Info.plist`
- `prefs/Resources/Root.plist`
- `prefs/Resources/icon.png`
- `prefs/Resources/icon@2x.png`
- `prefs/Resources/icon@3x.png`
- `prefs/Resources/PackageIcon.png`
- `layout/DEBIAN/postinst`
- `layout/DEBIAN/prerm`
- `layout/DEBIAN/postrm`
- `layout/Library/MobileSubstrate/DynamicLibraries/NightNightSleepd-RootHide.plist`
- `layout/Library/MobileSubstrate/DynamicLibraries/NightNightSleepd-Rootless.plist`
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
- Release title: `NightNight 1.0.1`
- Release tag: `v1.0.1`
- Release assets: both debs and `SHA256SUMS.txt`
- Release state: latest, not draft, not prerelease

## Package checksums

| Asset | SHA-256 |
|---|---|
| `NightNight_1.0.1_rootless_iphoneos-arm64.deb` | `7f7d870570d5acfd671f4d68e27552f7c8e52ef8a1fa816942d49ef934b6d9ee` |
| `NightNight_1.0.1_roothide_iphoneos-arm64e.deb` | `d0e1324c44c881f377c29f679f001fcd27652306ad4a1670bcef72c3de76fd70` |

The package payload contains:

- `NightNight.dylib`
- `NightNight.plist`
- `NightNightRunner`
- `NightNightLauncher`
- `NightNightPrefs.bundle`
- `NightNightPrefs` resources and icons
- Launcher templates for RootHide and rootless
- PreferenceLoader entry
- `postinst`, `prerm`, and `postrm`

No Control Center bundle, dSYM, diagnostic log, test deb, or personal path is included.

## Verified

- [x] Rootless and RootHide packages build.
- [x] Version is `1.0.1` in `control`, the preference bundle, and the About footer.
- [x] Control has no iOS version restriction.
- [x] RootHide `Icon:` path is rewritten to `file:///Library/...`.
- [x] RootHide package architecture is `iphoneos-arm64e`.
- [x] Rootless package architecture is `iphoneos-arm64`.
- [x] Depiction and Sileo depiction fields point to the planned Pages URLs.
- [x] Settings icons are 29, 58, and 87 pixels.
- [x] Package icon is 1024 pixels.
- [x] Installed source plist uses the logical launcher path and contains no `.jbroot-` path.
- [x] Launchd job starts with `runs = 1`.
- [x] Sleep helper ready marker is present.
- [x] User confirmed the tweak works.
- [x] Automatic threshold hibernation and wake confirmed at 94% on the diagnostic build.
- [x] Final clean artifact installs; no debug instrumentation or debug log remains.
- [x] RootHide TweakInject copy is synchronized by `postinst`.
- [x] No Control Center bundle is present in the package.
- [x] Source and package strings contain no personal paths, credentials, or diagnostic dumps.
- [x] Depiction JSON validates.
- [x] HTML parses and the CSS is self-contained.

## Remaining before release approval

- [ ] Full reboot/re-jailbreak and RootHide re-randomization check on the final artifact; not performed per user instruction.
- [ ] Missing-runner retry check on the final artifact.
- [ ] Install the rootless build on a rootless device.
- [x] Review this bundle and approve the final files.
- [x] Commit the update locally.
- [ ] Obtain explicit publish approval before any push, tag, Pages update, or GitHub release.

## Publishing checklist

- [x] Version, architecture, and package metadata correct.
- [x] License present.
- [x] README first sentence correct.
- [x] README final attribution line correct and unique.
- [x] No personal data or local paths in source, docs, debs, or release assets.
- [x] GitHub About description set without the attribution line.
- [x] Pages source set to `main` branch, `/docs` folder.
- [x] `docs/.nojekyll` present.
- [ ] Final full reboot/re-jailbreak verification.
- [ ] Final review approval.
- [ ] Push and publish.
- [ ] Re-download release assets and verify SHA-256 values.
- [ ] Verify live HTML and depiction JSON.
- [ ] No APT repository created.
