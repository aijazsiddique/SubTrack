import Flutter
import UIKit
import VisionKit // Import VisionKit for document scanning
import Foundation // For DispatchGroup

@main
@objc class AppDelegate: FlutterAppDelegate, VNDocumentCameraViewControllerDelegate { // Adopt VNDocumentCameraViewControllerDelegate
    private var flutterResult: FlutterResult? // To hold the result callback from Flutter

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let ocrChannel = FlutterMethodChannel(name: "com.subtrack.app/ios_ocr",
                                              binaryMessenger: controller.binaryMessenger)

        ocrChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "scanDocument" {
                self.flutterResult = result
                self.presentDocumentCamera(from: controller)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func presentDocumentCamera(from viewController: UIViewController) {
        if VNDocumentCameraViewController.canUseDocumentScanner {
            let documentCameraViewController = VNDocumentCameraViewController()
            documentCameraViewController.delegate = self
            viewController.present(documentCameraViewController, animated: true)
        } else {
            // Handle the case where document scanner is not available
            flutterResult?(FlutterError(code: "UNAVAILABLE",
                                       message: "Document scanner not available",
                                       details: nil))
            flutterResult = nil
        }
    }

    // MARK: - VNDocumentCameraViewControllerDelegate

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            var scannedTexts: [String] = []

            let group = DispatchGroup()
            let serialQueue = DispatchQueue(label: "ocrQueue")

            for i in 0..<scan.pageCount {
                group.enter()
                let image = scan.imageOfPage(at: i)
                self.performOCR(on: image) { recognizedText in
                    serialQueue.async {
                        if let text = recognizedText {
                            scannedTexts.append(text)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.flutterResult?(scannedTexts)
                self.flutterResult = nil
            }
        }
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true) { [weak self] in
            self?.flutterResult?([]) // Return empty array if cancelled
            self?.flutterResult = nil
        }
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true) { [weak self] in
            self?.flutterResult?(FlutterError(code: "SCAN_FAILED",
                                               message: "Document scan failed",
                                               details: error.localizedDescription))
            self?.flutterResult = nil
        }
    }

    private func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizeTextObservation] else {
                completion(nil)
                return
            }
            let recognizedText = observations.compactMap {
                observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            completion(recognizedText)
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"] // Prioritize English

        do {
            try requestHandler.perform([request])
        } catch {
            print("OCR failed: \(error)")
            completion(nil)
        }
    }
}