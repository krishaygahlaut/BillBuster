import VisionKit
import SwiftUI
import Vision

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedText: $scannedText)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var scannedText: String

        init(scannedText: Binding<String>) {
            _scannedText = scannedText
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)

            var allText = ""

            let request = VNRecognizeTextRequest { request, error in
                if let results = request.results as? [VNRecognizedTextObservation] {
                    for observation in results {
                        if let topCandidate = observation.topCandidates(1).first {
                            allText += topCandidate.string + "\n"
                        }
                    }

                    // ✅ Fix: Use self.scannedText to avoid closure capture error
                    self.scannedText = allText
                }
            }

            request.recognitionLevel = .accurate

            let queue = DispatchQueue(label: "OCR")
            queue.async {
                for page in 0..<scan.pageCount {
                    let image = scan.imageOfPage(at: page)
                    guard let cgImage = image.cgImage else { continue }
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try? handler.perform([request])
                }
            }
        }
    }
}
