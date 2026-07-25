import Foundation

/// Simple typed wrapper around the App Group defaults for the user-editable
/// schedule settings (morning duration, night start/end time).
enum ScheduleSettingsStore {
    private static var defaults: UserDefaults { AppGroup.defaults }

    static var morningDurationMinutes: Int {
        get {
            let value = defaults.integer(forKey: DefaultsKey.morningDurationMinutes)
            return value == 0 ? DefaultValues.morningDurationMinutes : value
        }
        set { defaults.set(newValue, forKey: DefaultsKey.morningDurationMinutes) }
    }

    static var nightStartHour: Int {
        get {
            defaults.object(forKey: DefaultsKey.nightStartHour) as? Int ?? DefaultValues.nightStartHour
        }
        set { defaults.set(newValue, forKey: DefaultsKey.nightStartHour) }
    }

    static var nightStartMinute: Int {
        get {
            defaults.object(forKey: DefaultsKey.nightStartMinute) as? Int ?? DefaultValues.nightStartMinute
        }
        set { defaults.set(newValue, forKey: DefaultsKey.nightStartMinute) }
    }

    static var nightEndHour: Int {
        get {
            defaults.object(forKey: DefaultsKey.nightEndHour) as? Int ?? DefaultValues.nightEndHour
        }
        set { defaults.set(newValue, forKey: DefaultsKey.nightEndHour) }
    }

    static var nightEndMinute: Int {
        get {
            defaults.object(forKey: DefaultsKey.nightEndMinute) as? Int ?? DefaultValues.nightEndMinute
        }
        set { defaults.set(newValue, forKey: DefaultsKey.nightEndMinute) }
    }

    static func nightStartComponents() -> DateComponents {
        DateComponents(hour: nightStartHour, minute: nightStartMinute)
    }

    static func nightEndComponents() -> DateComponents {
        DateComponents(hour: nightEndHour, minute: nightEndMinute)
    }
}
