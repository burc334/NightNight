# NightNight test log

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
