import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode = false
    @EnvironmentObject var viewModel: ExpenseViewModel

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Dark Mode", isOn: $isDarkMode)

                NavigationLink("Manage Friends") {
                    MemberManagerView(viewModel: viewModel)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
