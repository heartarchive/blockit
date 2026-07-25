import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var scheduler: BlockScheduler

    @State private var morningDuration = ScheduleSettingsStore.morningDurationMinutes
    @State private var nightAutoEnabled = BlockScheduler.shared.isNightScheduleEnabled
    @State private var nightStart = ScheduleView.date(
        hour: ScheduleSettingsStore.nightStartHour,
        minute: ScheduleSettingsStore.nightStartMinute
    )
    @State private var nightEnd = ScheduleView.date(
        hour: ScheduleSettingsStore.nightEndHour,
        minute: ScheduleSettingsStore.nightEndMinute
    )

    var body: some View {
        NavigationStack {
            Form {
                Section("Morning") {
                    Stepper(value: $morningDuration, in: 5...180, step: 5) {
                        Text("Block duration: \(morningDuration) min")
                    }
                    .onChange(of: morningDuration) { newValue in
                        ScheduleSettingsStore.morningDurationMinutes = newValue
                    }
                    Text("How long apps stay blocked after you tap \"I woke up.\"")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Night") {
                    Toggle("Automatically block overnight", isOn: $nightAutoEnabled)
                        .onChange(of: nightAutoEnabled) { enabled in
                            applyNightSchedule(enabled: enabled)
                        }

                    DatePicker("Start", selection: $nightStart, displayedComponents: .hourAndMinute)
                        .onChange(of: nightStart) { _ in
                            saveNightTimes()
                            if nightAutoEnabled { applyNightSchedule(enabled: true) }
                        }

                    DatePicker("End", selection: $nightEnd, displayedComponents: .hourAndMinute)
                        .onChange(of: nightEnd) { _ in
                            saveNightTimes()
                            if nightAutoEnabled { applyNightSchedule(enabled: true) }
                        }

                    Text("Selected apps will be blocked every night from the start time until the end time.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if scheduler.isNightBlockActive {
                    Section {
                        Button("I'm awake — end sleep block now") {
                            scheduler.wakeUpNow()
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
        }
    }

    private func saveNightTimes() {
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: nightStart)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: nightEnd)
        ScheduleSettingsStore.nightStartHour = startComponents.hour ?? DefaultValues.nightStartHour
        ScheduleSettingsStore.nightStartMinute = startComponents.minute ?? DefaultValues.nightStartMinute
        ScheduleSettingsStore.nightEndHour = endComponents.hour ?? DefaultValues.nightEndHour
        ScheduleSettingsStore.nightEndMinute = endComponents.minute ?? DefaultValues.nightEndMinute
    }

    private func applyNightSchedule(enabled: Bool) {
        if enabled {
            scheduler.enableNightSchedule(
                startHour: ScheduleSettingsStore.nightStartHour,
                startMinute: ScheduleSettingsStore.nightStartMinute,
                endHour: ScheduleSettingsStore.nightEndHour,
                endMinute: ScheduleSettingsStore.nightEndMinute
            )
        } else {
            scheduler.disableNightSchedule()
        }
    }

    private static func date(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date()
        ) ?? Date()
    }
}
