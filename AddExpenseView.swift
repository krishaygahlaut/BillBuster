import SwiftUI
import VisionKit
import Vision

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var title = ""
    @State private var amount = ""
    @State private var paidBy = "You"
    @State private var selectedParticipants: Set<String> = []
    @State private var category = "General"

    let categories = ["Food", "Travel", "Shopping", "Bills", "Entertainment", "General"]

    @State private var scannedText: String = ""
    @State private var showScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 📄 Expense Info
                    GroupBox(label: Text("Expense Info")) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Title", text: $title)
                                .textFieldStyle(.roundedBorder)

                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            Picker("Paid by", selection: $paidBy) {
                                ForEach(viewModel.members, id: \.self) { person in
                                    Text(person)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    // 👥 Shared With
                    GroupBox(label: Text("Shared With")) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.members, id: \.self) { person in
                                MultipleSelectionRow(title: person, isSelected: selectedParticipants.contains(person)) {
                                    if selectedParticipants.contains(person) {
                                        selectedParticipants.remove(person)
                                    } else {
                                        selectedParticipants.insert(person)
                                    }
                                }
                            }
                        }
                    }

                    // 🔖 Category Picker
                    GroupBox(label: Text("Category")) {
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // 📷 Receipt Scan
                    GroupBox(label: Text("Scan Receipt")) {
                        Button("📷 Scan Receipt") {
                            showScanner = true
                        }

                        if !scannedText.isEmpty {
                            Text("Detected: \(scannedText)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // ➕ Add Expense
                    Button("➕ Add Expense") {
                        if let amt = Double(amount), !selectedParticipants.isEmpty {
                            let expense = Expense(
                                id: UUID(),
                                title: title,
                                amount: amt,
                                paidBy: paidBy,
                                participants: Array(selectedParticipants),
                                date: Date(),
                                category: category
                            )
                            viewModel.addExpense(expense)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    .disabled(title.isEmpty || amount.isEmpty || selectedParticipants.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add Expense")
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(scannedText: $scannedText)
        }
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}
