import Foundation

struct TripGroup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var expenses: [Expense]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.expenses = []
    }

    static func == (lhs: TripGroup, rhs: TripGroup) -> Bool {
        lhs.id == rhs.id
    }
}
