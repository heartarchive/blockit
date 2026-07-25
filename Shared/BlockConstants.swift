import Foundation
import DeviceActivity
import ManagedSettings

/// Shared identifiers and storage used by both the main app and the
/// DeviceActivityMonitor extension. Must stay in sync with the App Group
/// configured in project.yml (`group.com.blockit.shared`).
enum AppGroup {
    static let identifier = "group.com.blockit.shared"

    static var defaults: UserDefaults {
        guard let suite = UserDefaults(suiteName: identifier) else {
            fatalError("App Group '\(identifier)' is not configured for this target.")
        }
        return suite
    }
}

enum ActivityName {
    /// One-shot interval used for the "I woke up" countdown.
    static let morning = DeviceActivityName("morningBlock")
    /// Repeating daily interval used for the automatic night schedule.
    static let night = DeviceActivityName("nightBlock")
}

enum ShieldStoreName {
    static let shared = ManagedSettingsStore.Name("blockitShield")
}

enum DefaultsKey {
    static let selection = "appSelection"
    static let morningDurationMinutes = "morningDurationMinutes"
    static let nightEnabled = "nightAutoScheduleEnabled"
    static let nightStartHour = "nightStartHour"
    static let nightStartMinute = "nightStartMinute"
    static let nightEndHour = "nightEndHour"
    static let nightEndMinute = "nightEndMinute"
    static let morningBlockActive = "morningBlockActive"
    static let morningBlockEndDate = "morningBlockEndDate"
    static let nightBlockActive = "nightBlockActive"
}

enum DefaultValues {
    static let morningDurationMinutes = 30
    static let nightStartHour = 23
    static let nightStartMinute = 0
    static let nightEndHour = 7
    static let nightEndMinute = 0
}
