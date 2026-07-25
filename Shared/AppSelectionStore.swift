import Foundation
import FamilyControls

/// Persists the user's chosen set of apps/categories/web domains to block,
/// in the shared App Group container so both the host app and the
/// DeviceActivityMonitor extension can read it.
enum AppSelectionStore {
    static func save(_ selection: FamilyActivitySelection) {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        AppGroup.defaults.set(data, forKey: DefaultsKey.selection)
    }

    static func load() -> FamilyActivitySelection {
        guard
            let data = AppGroup.defaults.data(forKey: DefaultsKey.selection),
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return FamilyActivitySelection()
        }
        return selection
    }

    static var isEmpty: Bool {
        let selection = load()
        return selection.applicationTokens.isEmpty
            && selection.categoryTokens.isEmpty
            && selection.webDomainTokens.isEmpty
    }
}
