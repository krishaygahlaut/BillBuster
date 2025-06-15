import SwiftUI


@main
struct BillBusterApp: App {
    @AppStorage("isDarkMode") var isDarkMode = false
    @StateObject var expenseVM = ExpenseViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    TabView {
                        HomeView()
                            .environmentObject(expenseVM)
                            .tabItem { Label("Trips", systemImage: "list.bullet") }

                        AnalyticsView(viewModel: expenseVM)
                            .tabItem { Label("Analytics", systemImage: "chart.pie") }

                        SettingsView()
                            .environmentObject(expenseVM)
                            .tabItem { Label("Settings", systemImage: "gear") }
                    }
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    showSplash = false
                }
            }
        }
    }
}
