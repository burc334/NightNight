# NightNight — 1.0.0 release plan

## Goal

Publish NightNight 1.0.0 with the final hibernation behavior and RootHide launchd packaging.

## Scope

- Remove install-time jbroot baking from the LaunchDaemon plist.
- Resolve the current jbroot at runtime.
- Keep RootHide and rootless packaging.
- Prevent missing-runner respawn loops.
- Clean up launchd state on upgrade and uninstall.
- Update release artifacts, documentation, and test records.

## Non-goals

- Hibernation feature changes.
- Preference or UI changes.
- An APT repository.
- Rootless device testing beyond the existing build verification.

## Environment

- macOS with Xcode, Theos, ldid, and dpkg-deb.
- Tested device: iOS 18.4.1, Dopamine 3, RootHide.

## Implementation

- Plist uses the logical `/Library/MobileSubstrate/DynamicLibraries/NightNightLauncher` path for RootHide.
- Plist uses `/var/root/Library/NightNight/launcher` for the rootless build.
- No `@JBROOT@`, `/var/jb`, or randomized path appears in `ProgramArguments`.
- The C launcher scans the current `.jbroot-*` roots, requires one valid runner and dylib, and supervises the runner.
- Missing-runner retry: 60 seconds.
- launchd `ThrottleInterval`: 60 seconds.
- Post-install restores the logical plist after launchctl resolves the runtime path.

## Test matrix

- Package metadata and version.
- Source plist contains no randomized jbroot path after install.
- launchd job starts with `runs = 1`.
- Ready marker present.
- Manual hibernation and wake.
- Automatic sleep/wake thresholds.
- Charger connect and reconnect behavior.
- Missing-runner behavior: no 1-second respawn loop.
- Uninstall and reinstall.
- Full reboot/re-jailbreak and re-randomization; not performed per user instruction.
- Rootless package build.

## Packaging

- Rootless: `NightNight_1.0.0_rootless_iphoneos-arm64.deb`
- RootHide: `NightNight_1.0.0_roothide_iphoneos-arm64e.deb`
- Hashes: `SHA256SUMS.txt`
- Depiction: `https://burc334.github.io/NightNight/`
- Sileo depiction: `https://burc334.github.io/NightNight/depiction.json`

## Publishing

Update the local commit and release artifacts only. No repository push, GitHub release, tag, or Pages update without explicit approval.

## Confidence

Build and launchd-job confidence is high. RootHide's launchctl rewriting the installed `/Library/LaunchDaemons` plist to the current jbroot path and marking it `__Patched` is expected runtime behavior; the package installs a logical template and must not make the generated plist immutable. Automatic threshold hibernation and wake were confirmed at 94% on the diagnostic build, and the final clean build uses the same hibernation logic without logging.

The remaining unverified item is a full reboot/re-jailbreak and jbroot re-randomization test on the final artifact. It was not performed because the user explicitly prohibited full reboots and re-jailbreaks. Rootless remains build-verified only; no rootless device is available.
