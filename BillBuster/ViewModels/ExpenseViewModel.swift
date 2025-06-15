import Foundation
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var groups: [TripGroup] = []
    @Published var selectedGroupID: UUID?

    @AppStorage("members") var savedMembers: String = "You,Friend 1"
    var members: [String] {
        get { savedMembers.components(separatedBy: ",").filter { !$0.isEmpty } }
        set { savedMembers = newValue.joined(separator: ",") }
    }

    var currentGroup: TripGroup? {
        get { groups.first(where: { $0.id == selectedGroupID }) }
    }

    init() {
        // Example seed group
        let defaultGroup = TripGroup(name: "Default")
        self.groups = [defaultGroup]
        self.selectedGroupID = defaultGroup.id
    }

    func addGroup(named name: String) {
        let newGroup = TripGroup(name: name)
        groups.append(newGroup)
        selectedGroupID = newGroup.id
    }

    func deleteGroup(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
        if selectedGroupID != nil && !groups.contains(where: { $0.id == selectedGroupID }) {
            selectedGroupID = groups.first?.id
        }
    }

    func addExpense(_ expense: Expense) {
        guard let id = selectedGroupID, let index = groups.firstIndex(where: { $0.id == id }) else { return }
        groups[index].expenses.append(expense)
    }

    func expensesForCurrentGroup() -> [Expense] {
        currentGroup?.expenses ?? []
    }

    func calculateSplit() -> [String: Double] {
        var balance = [String: Double]()
        for member in members { balance[member] = 0.0 }

        for expense in expensesForCurrentGroup() {
            let share = expense.amount / Double(expense.participants.count)
            for person in expense.participants {
                balance[person, default: 0] -= share
            }
            balance[expense.paidBy, default: 0] += expense.amount
        }

        return balance
    }
}
