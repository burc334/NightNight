## Build 1.0.0 — final rebuilt release

**Built:** 2026-11-07
**Install:** final package not installed yet; device verification pending.

**Builds:**
- `builds/com.burc334.nightnight_1.0.0_iphoneos-arm64.deb`
  SHA-256: `72be1cc3ce0f461254f8d4e0c3852603568d85e13596af01353d23a438b2e5ed`
- `builds/com.burc334.nightnight_1.0.0_iphoneos-arm64e.deb`
  SHA-256: `d69b0b0fb005492362b4154292bdbddee498f534cf7209383280f5a98f4c5c2d`

### Result

Final 1.0.0 package built with the new icon, package identity, and
documentation. Device install and visual verification remain pending.

# NightNight test log

## Build 1.0.1 — RootHide launchd fix

**Built:** 2026-11-07
**Installed:** 2026-11-07 on iPhone 11 Pro Max, iOS 18.4.1, Dopamine 3, RootHide.
**Install result:** Clean RootHide `1.0.1` artifact installed; SpringBoard respringed; launcher, source plist, and ready marker present. No debug instrumentation remains.
**Log result:** No NightNight crash observed during install or respring. Temporary diagnostic logs were removed after verification.
**Crash result:** None observed.
**User confirmation:** User confirmed manual hibernation and automatic threshold hibernation/wake at 94% on the diagnostic build; the final clean build uses the same hibernation logic without logging.

**Builds:**
- RootHide: `builds/NightNight_1.0.1_roothide_iphoneos-arm64e.deb`
  SHA-256: `d0e1324c44c881f377c29f679f001fcd27652306ad4a1670bcef72c3de76fd70`
- Rootless: `builds/NightNight_1.0.1_rootless_iphoneos-arm64.deb`
  SHA-256: `7f7d870570d5acfd671f4d68e27552f7c8e52ef8a1fa816942d49ef934b6d9ee`

### Test checklist

- [x] Rootless package builds.
- [x] RootHide package builds and installs.
- [x] Package metadata reports version `1.0.1` with no iOS version restriction.
- [x] Settings bundle reports version `1.0.1`.
- [x] LaunchDaemon uses the stable logical launcher path.
- [x] Installed source plist contains no `.jbroot-` path.
- [x] Launchd job starts with `runs = 1` and does not increment continuously.
- [x] Sleep helper ready marker is present.
- [x] User confirmed manual hibernation works.
- [x] Automatic threshold hibernation and wake confirmed at 94% on the diagnostic build.
- [x] Final clean artifact installs; no debug logging or diagnostic dylib remains.
- [x] RootHide TweakInject copy is synchronized by `postinst`.
- [x] No Control Center bundle is present in the package.
- [x] Source and package contain no personal paths or test logs.
- [ ] Full reboot and re-jailbreak on the final artifact; not performed per user instruction.
- [ ] Missing-runner retry check on the final artifact.
- [ ] Rootless installation on a rootless device.
- [ ] iOS 18 device other than the tested device.

### Result

The `1.0.1` release artifact builds, installs, resprings, and starts a stable launchd supervisor on the tested RootHide device. The source plist is logical and the job reports `runs = 1`. Automatic threshold hibernation and wake were confirmed at 94%; after wake the monitor remains disarmed until the battery rises above threshold + 2. Full reboot/re-jailbreak verification remains outstanding and was not performed per user instruction.

## Build 1.0.0 — release candidate

**Built:** 2026-11-01
**Installed:** 2026-11-01 on iPhone 11 Pro Max, iOS 18.4.1, Dopamine 3, RootHide.
**Install result:** RootHide `1.0.0` release artifact installed; SpringBoard respringed; sleep helper ready marker present; uninstall and reinstall verified.
**Log result:** No NightNight crash observed during install or respring.
**Crash result:** None observed.
**User confirmation:** Core 1.0.0 hibernation behavior was reported working; the final metadata/UI-copy build is installed.
**Release approval:** User explicitly approved publication on 2026-11-01.

**Builds:**
- RootHide: `builds/NightNight_1.0.0_roothide_iphoneos-arm64e.deb`
  SHA-256: `e677af0a2d794820f5e1cb3d634ec3b40c23ef91efda7d10e417d04e3c4e0945`
- Rootless: `builds/NightNight_1.0.0_rootless_iphoneos-arm64.deb`
  SHA-256: `4402af25a12ac1a33850eba85705a95548661599c12fb6a028acdc9408a4f572`

### Test checklist

- [x] Rootless package builds.
- [x] RootHide package builds and installs.
- [x] Package metadata reports version `1.0.0` with no iOS version restriction.
- [x] Settings bundle reports version `1.0.0`.
- [x] Sleep helper starts and registers its notification after install.
- [x] Sleep helper ready marker is visible to SpringBoard.
- [x] Uninstall removes the daemon, ready marker, and old Control Center bundle.
- [x] Reinstall restores the daemon and ready marker.
- [x] No Control Center bundle is present in the package.
- [x] Settings icon assets and package icon are present at the expected sizes.
- [x] Source and package contain no personal paths or test logs.
- [ ] Final manual hibernation/wake cycle on `1.0.0`.
- [ ] Final charger-connect and already-charging reconnect tests on `1.0.0`.
- [ ] Call blocking, macOS status, Notification Center, and media-pause check on `1.0.0`.
- [ ] Automatic threshold cycle on `1.0.0`.
- [ ] Reboot and recovery check on `1.0.0`.
- [ ] Rootless installation on a rootless device.
- [ ] iOS 18 device other than the tested device.

### Result

The `1.0.0` release candidate builds, installs, resprings, and starts its sleep helper on the tested RootHide device. Final behavioral checks remain to be completed before release approval.
