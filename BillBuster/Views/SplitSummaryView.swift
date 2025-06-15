import SwiftUI
import MessageUI

struct SplitSummaryView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var showMessage = false
    @State private var recipient = ""
    @State private var messageBody = ""

    var body: some View {
        let balances = viewModel.calculateSplit()

        NavigationStack {
            List {
                ForEach(viewModel.members, id: \.self) { person in
                    let balance = balances[person] ?? 0.0

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(person).font(.headline)
                            Spacer()
                            Text("₹\(abs(balance), specifier: "%.2f")")
                                .foregroundColor(balance == 0 ? .gray : (balance > 0 ? .green : .red))
                            Text(balance > 0 ? "gets" : (balance < 0 ? "owes" : "settled"))
                                .foregroundColor(balance == 0 ? .gray : (balance > 0 ? .green : .red))
                        }

                        if balance < 0 {
                            HStack {
                                Button("Pay via UPI") {
                                    let amount = abs(balance)
                                    if let url = URL(string: "upi://pay?pa=krishay@upi&pn=Krishay&am=\(amount)&cu=INR") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .buttonStyle(.borderedProminent)

                                Spacer()

                                Button("Remind via SMS") {
                                    recipient = "" // Optional: prefill with known number
                                    messageBody = """
                                    Hi \(person) 👋,
                                    You owe ₹\(abs(balance).formatted()) for our recent shared expense. Kindly pay via UPI: krishay@upi 💸
                                    Thanks!
                                    """
                                    showMessage = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Split Summary")
        }
        .sheet(isPresented: $showMessage) {
            MessageComposeView(recipients: [recipient], body: messageBody)
        }
    }
}

struct MessageComposeView: UIViewControllerRepresentable {
    var recipients: [String]
    var body: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = recipients
        vc.body = body
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }
}
