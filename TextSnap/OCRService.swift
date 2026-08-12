import Vision
import CoreGraphics

final class OCRService {
    // Runs Vision text recognition on a background thread to avoid blocking the main actor.
    nonisolated func recognize(
        image: CGImage,
        language: Preferences.RecognitionLanguage,
        useCorrection: Bool
    ) async throws -> [VNRecognizedTextObservation] {
        let languages = resolvedLanguages(for: language)

        return try await withCheckedThrowingContinuation { continuation in
            // VNImageRequestHandler.perform() is synchronous; dispatch to background queue.
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest { request, error in
                    if let error {
                        continuation.resume(throwing: AppError.ocrFailed(error.localizedDescription))
                        return
                    }
                    let observations = request.results as? [VNRecognizedTextObservation] ?? []
                    continuation.resume(returning: observations)
                }
                request.recognitionLevel = .accurate
                request.recognitionLanguages = languages
                request.usesLanguageCorrection = useCorrection

                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: AppError.ocrFailed(error.localizedDescription))
                }
            }
        }
    }

    nonisolated private func resolvedLanguages(for language: Preferences.RecognitionLanguage) -> [String] {
        let supported: [String]
        do {
            let probe = VNRecognizeTextRequest()
            probe.recognitionLevel = .accurate
            supported = try probe.supportedRecognitionLanguages()
        } catch {
            return []
        }

        switch language {
        case .auto:
            let ja = supported.filter { $0.hasPrefix("ja") }
            let en = supported.filter { $0.hasPrefix("en") }
            return ja + en
        case .japanese:
            let ja = supported.filter { $0.hasPrefix("ja") }
            return ja.isEmpty ? supported : ja
        case .english:
            let en = supported.filter { $0.hasPrefix("en") }
            return en.isEmpty ? supported : en
        }
    }
}
