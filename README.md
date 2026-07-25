# BlockIt

An iOS app that blocks a chosen set of apps:

- **Morning:** tap **"I woke up"** to start a countdown (default 30 min,
  configurable). Selected apps stay blocked until the timer ends — the block
  is enforced by the system, so it survives BlockIt being closed or
  force-quit.
- **Night:** either tap **"Going to sleep now"** to block immediately, or
  turn on the automatic overnight schedule (e.g. 11:00 PM – 7:00 AM) so
  apps get blocked and unblocked on their own every day. "I'm awake" lifts
  the night block early if you wake up before the scheduled end.

Built on Apple's Screen Time API — `FamilyControls`, `ManagedSettings`, and
`DeviceActivity`. There is no way around it: this is real iOS system
functionality, so it cannot run on Android or as a plain web app, and it
must be built with Xcode on a Mac.

## Project layout

```
project.yml              XcodeGen project spec (generates the .xcodeproj)
BlockIt/                  Main app target
  App/                    App entry point
  Managers/               AuthorizationManager, BlockScheduler
  Models/                 ScheduleSettingsStore
  Views/                  Onboarding, Home, App picker, Schedule
  Resources/              Info.plist, entitlements, Assets.xcassets
BlockItMonitor/           DeviceActivityMonitor app extension
  MonitorExtension.swift  Applies/lifts the shield when scheduled
                          intervals start/end — runs even if the main
                          app isn't open
Shared/                   Code shared by both targets (App Group
                          constants, FamilyActivitySelection storage,
                          the ManagedSettingsStore shield helper)
```

## How the blocking actually works

1. You pick apps/categories to restrict with Apple's `FamilyActivityPicker`
   (Blocked Apps tab). The selection is saved to a shared App Group
   container so both the app and the extension can read it.
2. `BlockScheduler` sets `ManagedSettingsStore.shield` directly, which is
   what makes the chosen apps unopenable — this is OS-level state, not
   something the BlockIt app has to be running to enforce.
3. `BlockScheduler` also asks `DeviceActivityCenter` to monitor an
   interval matching the countdown (morning) or the daily start/end time
   (night). When that interval ends, iOS launches the `BlockItMonitor`
   extension in the background and calls `intervalDidEnd`, which clears
   the shield — this is what makes the timer expire reliably even if you
   killed the app or turned your phone off and on.

## Setup (on a Mac, with Xcode)

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you don't
   have it: `brew install xcodegen`
2. From the repo root: `xcodegen generate`
3. Open `BlockIt.xcodeproj` in Xcode.
4. For **both** targets (BlockIt and BlockItMonitor), in *Signing &
   Capabilities*:
   - Set your Team so Xcode can sign the app.
   - Change the bundle identifiers from `com.blockit.app` /
     `com.blockit.app.monitor` to something under an identifier you own,
     if `com.blockit.*` isn't available to your team.
   - Update the App Group in both entitlements files
     (`BlockIt/Resources/BlockIt.entitlements` and
     `BlockItMonitor/BlockItMonitor.entitlements`) — and the
     `AppGroup.identifier` constant in `Shared/BlockConstants.swift` — to
     an App Group your team registers (e.g.
     `group.<yourteamid>.blockit`).
5. Build and run on a **physical device**. Screen Time APIs
   (`FamilyControls`/`ManagedSettings`/`DeviceActivity`) do not work in the
   iOS Simulator.
6. On first launch, tap "Allow Screen Time Access" — this triggers Apple's
   system consent screen for `AuthorizationCenter.requestAuthorization(for:
   .individual)`.

### About the Family Controls entitlement

`com.apple.developer.family-controls` is a restricted entitlement.
- **For local development** (building to your own device from Xcode with a
  personal/team signing certificate), you can enable it directly in
  Xcode's Signing & Capabilities ("+ Capability" → "Family Controls") —
  no separate Apple approval is required to run it on your own device.
- **For TestFlight or App Store distribution**, Apple requires you to
  request approval for this entitlement first, via
  [developer.apple.com/contact/request/family-controls-distribution](https://developer.apple.com/contact/request/family-controls-distribution).
  Apps that use it for personal focus/self-restriction (not just
  parent-managing-child) have been approved before, but approval is
  Apple's call and isn't guaranteed.

### Known limitations

- Don't include the BlockIt app itself in your blocked-apps selection —
  the `FamilyActivityPicker` can't distinguish it, so nothing currently
  prevents you from shielding your own app icon and losing your only way
  to unblock early.
- Apple's Screen Time picker only exposes opaque tokens for the apps you
  select (`ApplicationToken`/`ActivityCategoryToken`) — the OS deliberately
  doesn't tell the app which apps you picked, by design, for privacy
  reasons. This is normal and doesn't affect blocking; it just means the
  app can't show you a human-readable list of your selection elsewhere.
- There's intentionally no "cancel" button during an active morning
  countdown, matching the "can't back out" behavior described in the
  original request. `BlockScheduler.cancelMorningBlock()` exists in code
  if you want to wire up an escape hatch.
- This project was written and organized in this session but has not been
  compiled — there's no macOS/Xcode toolchain available in this
  environment. Please build it in Xcode and fix any small API-surface
  issues Apple may have introduced in newer SDKs before relying on it.
