import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @State private var selection = AppSelectionStore.load()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FamilyActivityPicker(selection: $selection)
                        .frame(minHeight: 400)
                } header: {
                    Text("Choose what to block")
                } footer: {
                    Text("Don't select BlockIt itself, or you won't be able to reopen it to end a block early.")
                }

                Section {
                    let count = selection.applicationTokens.count
                        + selection.categoryTokens.count
                        + selection.webDomainTokens.count
                    Text("\(count) item\(count == 1 ? "" : "s") selected")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Blocked Apps")
            .onChange(of: selection) { newValue in
                AppSelectionStore.save(newValue)
            }
        }
    }
}
