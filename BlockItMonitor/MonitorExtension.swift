import DeviceActivity
import Foundation

/// Runs in the system's DeviceActivity extension process — independent of
/// whether the main BlockIt app is open or has been force-quit. This is what
/// guarantees the morning countdown auto-lifts on time, and the night
/// schedule shields/unshields apps automatically.
class MonitorExtension: DeviceActivityMonitor {

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard activity == ActivityName.night else { return }
        let selection = AppSelectionStore.load()
        ShieldController.applyShield(for: selection)
        AppGroup.defaults.set(true, forKey: DefaultsKey.nightBlockActive)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        ShieldController.clearShield()

        switch activity {
        case ActivityName.morning:
            AppGroup.defaults.set(false, forKey: DefaultsKey.morningBlockActive)
            AppGroup.defaults.removeObject(forKey: DefaultsKey.morningBlockEndDate)
        case ActivityName.night:
            AppGroup.defaults.set(false, forKey: DefaultsKey.nightBlockActive)
        default:
            break
        }
    }
}
