import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("BillBuster")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)

                Text("Project by Krishay Gahlaut")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
