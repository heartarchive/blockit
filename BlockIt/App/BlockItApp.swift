import SwiftUI

@main
struct BlockItApp: App {
    @StateObject private var authManager = AuthorizationManager()
    @StateObject private var scheduler = BlockScheduler.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(scheduler)
        }
    }
}
