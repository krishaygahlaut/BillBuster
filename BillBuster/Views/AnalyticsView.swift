import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var selectedRange: TimeRange = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Time Range", selection: $selectedRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Pie Chart - Categories
                    GroupBox(label: Text("Expenses by Category")) {
                        Chart {
                            ForEach(categorySummary) { item in
                                SectorMark(
                                    angle: .value("Total", item.total),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                            }
                        }
                        .frame(height: 250)
                    }

                    // Bar Chart - Daily Trend
                    GroupBox(label: Text("Spending Trend")) {
                        Chart {
                            ForEach(dailySummary) { day in
                                BarMark(
                                    x: .value("Date", day.date, unit: .day),
                                    y: .value("Total", day.total)
                                )
                            }
                        }
                        .frame(height: 220)
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }

    // MARK: Data Logic
    var filteredExpenses: [Expense] {
        let all = viewModel.expensesForCurrentGroup()
        let now = Date()

        switch selectedRange {
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            return all.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            return all.filter { $0.date >= monthAgo }
        }
    }

    var categorySummary: [CategoryTotal] {
        Dictionary(grouping: filteredExpenses, by: { $0.category })
            .map { CategoryTotal(category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
    }

    var dailySummary: [DateTotal] {
        let grouped = Dictionary(grouping: filteredExpenses) {
            Calendar.current.startOfDay(for: $0.date)
        }

        return grouped.map {
            DateTotal(date: $0.key, total: $0.value.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
}

// MARK: Support Types
struct CategoryTotal: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}

struct DateTotal: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
}

enum TimeRange: String, CaseIterable {
    case week, month
}
