import SwiftUI

struct GroupSelectorView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var newGroup = ""

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Trips/Groups")) {
                    ForEach(viewModel.groups) { group in
                        HStack {
                            Text(group.name)
                            Spacer()
                            if group.id == viewModel.selectedGroupID {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedGroupID = group.id
                        }
                    }
                    .onDelete(perform: viewModel.deleteGroup)
                }

                Section(header: Text("Create New Group")) {
                    TextField("Group Name", text: $newGroup)
                    Button("Add Group") {
                        guard !newGroup.isEmpty else { return }
                        viewModel.addGroup(named: newGroup)
                        newGroup = ""
                    }
                }
            }
            .navigationTitle("Manage Trips/Groups")
            .toolbar {
                EditButton()
            }
        }
    }
}
