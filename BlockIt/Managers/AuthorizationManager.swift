import Foundation
import FamilyControls
import Combine

/// Requests and tracks Screen Time (Family Controls) authorization for the
/// current device/user. Required before app selection or shielding works.
@MainActor
final class AuthorizationManager: ObservableObject {
    @Published private(set) var status: AuthorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published var lastError: String?

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            status = AuthorizationCenter.shared.authorizationStatus
            lastError = nil
        } catch {
            lastError = error.localizedDescription
            status = AuthorizationCenter.shared.authorizationStatus
        }
    }

    func refreshStatus() {
        status = AuthorizationCenter.shared.authorizationStatus
    }

    var isAuthorized: Bool {
        status == .approved
    }
}
