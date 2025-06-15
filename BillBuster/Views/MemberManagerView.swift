import SwiftUI

struct MemberManagerView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var newMember = ""
    @State private var showContactPicker = false
    @State private var pickedContactName = ""

    var body: some View {
        Form {
            Section(header: Text("Current Members")) {
                ForEach(viewModel.members, id: \.self) { member in
                    Text(member)
                }
                .onDelete(perform: delete)
            }

            Section(header: Text("Add Manually")) {
                TextField("Enter name", text: $newMember)
                Button("Add") {
                    guard !newMember.isEmpty else { return }
                    var updated = viewModel.members
                    updated.append(newMember)
                    viewModel.members = updated
                    newMember = ""
                }
            }

            Section(header: Text("Add from Contacts")) {
                Button("➕ Add From Contacts") {
                    showContactPicker = true
                }
                if !pickedContactName.isEmpty {
                    Text("Picked: \(pickedContactName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Manage Members")
        .sheet(isPresented: $showContactPicker, onDismiss: {
            if !pickedContactName.isEmpty {
                var updated = viewModel.members
                updated.append(pickedContactName)
                viewModel.members = updated
                pickedContactName = ""
            }
        }) {
            ContactPicker(selectedName: $pickedContactName)
        }
        .toolbar {
            EditButton()
        }
    }

    private func delete(at offsets: IndexSet) {
        var updated = viewModel.members
        updated.remove(atOffsets: offsets)
        viewModel.members = updated
    }
}
