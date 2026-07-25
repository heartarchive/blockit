import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var authManager: AuthorizationManager
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("BlockIt")
                .font(.largeTitle.bold())

            Text("BlockIt blocks distracting apps for a set time after you wake up, and overnight while you sleep. It needs Screen Time permission to restrict apps.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            if let error = authManager.lastError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                Task {
                    isRequesting = true
                    await authManager.requestAuthorization()
                    isRequesting = false
                }
            } label: {
                if isRequesting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Allow Screen Time Access")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .disabled(isRequesting)

            Spacer()
        }
    }
}
