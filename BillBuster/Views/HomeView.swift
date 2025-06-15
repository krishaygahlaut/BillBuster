import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showAddExpense = false
    @State private var showGroupSelector = false

    var body: some View {
        NavigationStack {
            VStack {
                let expenses = viewModel.expensesForCurrentGroup()
                if expenses.isEmpty {
                    Spacer()
                    Text("No expenses yet.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(expenses) { expense in
                        VStack(alignment: .leading) {
                            Text(expense.title).font(.headline)
                            Text("₹\(expense.amount, specifier: "%.2f") • Paid by \(expense.paidBy)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

                NavigationLink("View Split Summary") {
                    SplitSummaryView(viewModel: viewModel)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("💸 \(viewModel.currentGroup?.name ?? "BillBuster")")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Groups") { showGroupSelector = true }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
                        Label("Add Expense", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showGroupSelector) {
                GroupSelectorView()
                    .environmentObject(viewModel)
            }
        }
    }
}
