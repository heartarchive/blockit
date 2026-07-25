import Foundation
import DeviceActivity
import FamilyControls
import Combine

/// Drives the two block modes:
///  - Morning: a one-shot countdown started by "I woke up", enforced by the
///    DeviceActivityMonitor extension so it lifts on time even if this app
///    isn't running.
///  - Night: an optional repeating daily schedule (auto shield/unshield),
///    plus a manual "Going to sleep now" / "I'm awake" override.
@MainActor
final class BlockScheduler: ObservableObject {
    static let shared = BlockScheduler()

    private let center = DeviceActivityCenter()
    private let defaults = AppGroup.defaults

    @Published private(set) var isMorningBlockActive: Bool
    @Published private(set) var morningBlockEndDate: Date?
    @Published private(set) var isNightBlockActive: Bool
    @Published var isNightScheduleEnabled: Bool

    private init() {
        isMorningBlockActive = defaults.bool(forKey: DefaultsKey.morningBlockActive)
        morningBlockEndDate = defaults.object(forKey: DefaultsKey.morningBlockEndDate) as? Date
        isNightBlockActive = defaults.bool(forKey: DefaultsKey.nightBlockActive)
        isNightScheduleEnabled = defaults.bool(forKey: DefaultsKey.nightEnabled)

        // If a stored morning block's end date has already passed (e.g. the
        // app was relaunched after the extension already lifted it), reconcile.
        if isMorningBlockActive, let end = morningBlockEndDate, end <= Date() {
            isMorningBlockActive = false
            morningBlockEndDate = nil
        }
    }

    /// Re-reads state written by the extension, call on app foreground.
    func refreshState() {
        isMorningBlockActive = defaults.bool(forKey: DefaultsKey.morningBlockActive)
        morningBlockEndDate = defaults.object(forKey: DefaultsKey.morningBlockEndDate) as? Date
        isNightBlockActive = defaults.bool(forKey: DefaultsKey.nightBlockActive)
        isNightScheduleEnabled = defaults.bool(forKey: DefaultsKey.nightEnabled)

        if isMorningBlockActive, let end = morningBlockEndDate, end <= Date() {
            cancelMorningBlock()
        }
    }

    // MARK: - Morning ("I woke up")

    func startMorningBlock(durationMinutes: Int) {
        let selection = AppSelectionStore.load()
        ShieldController.applyShield(for: selection)

        let now = Date()
        let end = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: now)
            ?? now.addingTimeInterval(TimeInterval(durationMinutes * 60))

        let startComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: end)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )

        do {
            try center.startMonitoring(ActivityName.morning, during: schedule)
        } catch {
            print("BlockScheduler: failed to start morning monitoring — \(error)")
        }

        defaults.set(true, forKey: DefaultsKey.morningBlockActive)
        defaults.set(end, forKey: DefaultsKey.morningBlockEndDate)
        isMorningBlockActive = true
        morningBlockEndDate = end
    }

    /// Ends the morning block early. Not exposed in the default UI (the
    /// point of the timer is to not be able to bail out), but available for
    /// recovery — e.g. the user picked the wrong duration by mistake.
    func cancelMorningBlock() {
        center.stopMonitoring([ActivityName.morning])
        ShieldController.clearShield()
        defaults.set(false, forKey: DefaultsKey.morningBlockActive)
        defaults.removeObject(forKey: DefaultsKey.morningBlockEndDate)
        isMorningBlockActive = false
        morningBlockEndDate = nil
    }

    // MARK: - Night schedule (automatic)

    func enableNightSchedule(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        let startComponents = DateComponents(hour: startHour, minute: startMinute)
        let endComponents = DateComponents(hour: endHour, minute: endMinute)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: true
        )

        do {
            try center.startMonitoring(ActivityName.night, during: schedule)
        } catch {
            print("BlockScheduler: failed to start night monitoring — \(error)")
        }

        defaults.set(true, forKey: DefaultsKey.nightEnabled)
        isNightScheduleEnabled = true
    }

    func disableNightSchedule() {
        center.stopMonitoring([ActivityName.night])
        defaults.set(false, forKey: DefaultsKey.nightEnabled)
        isNightScheduleEnabled = false

        if isNightBlockActive {
            ShieldController.clearShield()
            defaults.set(false, forKey: DefaultsKey.nightBlockActive)
            isNightBlockActive = false
        }
    }

    // MARK: - Night manual override

    /// "Going to sleep now" — shields immediately, independent of the
    /// scheduled start time. Lifted automatically at the schedule's end
    /// time (if enabled) or manually via wakeUpNow().
    func goToSleepNow() {
        let selection = AppSelectionStore.load()
        ShieldController.applyShield(for: selection)
        defaults.set(true, forKey: DefaultsKey.nightBlockActive)
        isNightBlockActive = true
    }

    /// "I'm awake" — lifts the night shield early.
    func wakeUpNow() {
        ShieldController.clearShield()
        defaults.set(false, forKey: DefaultsKey.nightBlockActive)
        isNightBlockActive = false
    }
}
