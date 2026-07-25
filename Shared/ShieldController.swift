import Foundation
import ManagedSettings
import FamilyControls

/// Applies/clears the actual system-level app shield. This is what makes the
/// blocked apps unopenable — it works regardless of whether the host app is
/// running, since ManagedSettingsStore state is owned by the system.
enum ShieldController {
    static let store = ManagedSettingsStore(named: ShieldStoreName.shared)

    static func applyShield(for selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens

        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil
            : selection.webDomainTokens
    }

    static func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
