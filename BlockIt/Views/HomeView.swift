import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var scheduler: BlockScheduler
    @State private var selectedDuration = ScheduleSettingsStore.morningDurationMinutes
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if scheduler.isMorningBlockActive, let end = scheduler.morningBlockEndDate {
                    morningActiveView(end: end)
                } else if scheduler.isNightBlockActive {
                    nightActiveView
                } else {
                    idleView
                }

                Spacer()
            }
            .padding()
            .navigationTitle("BlockIt")
            .onReceive(timer) { date in
                now = date
                if scheduler.isMorningBlockActive,
                   let end = scheduler.morningBlockEndDate,
                   end <= date {
                    scheduler.refreshState()
                }
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Ready when you are")
                .font(.title2.bold())

            Stepper(value: $selectedDuration, in: 5...180, step: 5) {
                Text("Block apps for \(selectedDuration) min")
            }
            .padding(.horizontal, 32)
            .onChange(of: selectedDuration) { newValue in
                ScheduleSettingsStore.morningDurationMinutes = newValue
            }

            Button {
                scheduler.startMorningBlock(durationMinutes: selectedDuration)
            } label: {
                Text("I woke up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .disabled(AppSelectionStore.isEmpty)

            if AppSelectionStore.isEmpty {
                Text("Choose apps to block on the \"Blocked Apps\" tab first.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button("Going to sleep now") {
                scheduler.goToSleepNow()
            }
            .disabled(AppSelectionStore.isEmpty)
        }
    }

    private func morningActiveView(end: Date) -> some View {
        let remaining = max(0, end.timeIntervalSince(now))
        return VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Apps blocked")
                .font(.title2.bold())

            Text(timeString(from: remaining))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("Unlocks automatically at \(end.formatted(date: .omitted, time: .shortened))")
                .foregroundStyle(.secondary)
        }
    }

    private var nightActiveView: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)

            Text("Sleep mode is on")
                .font(.title2.bold())

            Text("Selected apps are blocked until your scheduled wake time.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Button("I'm awake") {
                scheduler.wakeUpNow()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
