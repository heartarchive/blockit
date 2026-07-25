import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authManager: AuthorizationManager
    @EnvironmentObject private var scheduler: BlockScheduler
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if authManager.isAuthorized {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .task {
            authManager.refreshStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                authManager.refreshStatus()
                scheduler.refreshState()
            }
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "sun.max.fill") }

            AppPickerView()
                .tabItem { Label("Blocked Apps", systemImage: "app.badge.checkmark") }

            ScheduleView()
                .tabItem { Label("Schedule", systemImage: "moon.zzz.fill") }
        }
    }
}
