import AppKit

@MainActor
final class CaptureCoordinator {
    private let overlayController = SelectionOverlayController()
    private let captureService = ScreenCaptureService()
    private let ocrService = OCRService()

    private enum State { case idle, selecting, capturing }
    private var state: State = .idle

    init() {
        overlayController.delegate = self
    }

    func startCapture() {
        guard state == .idle else { return }

        Task {
            let hasPermission = await PermissionService.checkScreenRecordingPermission()
            guard hasPermission else {
                showPermissionAlert()
                return
            }
            state = .selecting
            overlayController.show()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "TextSnap needs Screen Recording access to capture the selected area.\n\nPlease grant access in System Settings > Privacy & Security > Screen Recording, then restart TextSnap."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            PermissionService.openSystemSettings()
        }
    }

    private func showErrorAlert(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }

    private func playSuccessSound() {
        NSSound(named: "Tink")?.play()
    }

    private func playEmptyResultSound() {
        NSSound(named: "Basso")?.play()
    }
}

extension CaptureCoordinator: SelectionDelegate {
    func selectionDidComplete(rect: NSRect, on screen: NSScreen) {
        state = .capturing

        Task {
            do {
                // Allow the screen to refresh after overlays close before capturing.
                try await Task.sleep(for: .milliseconds(150))

                let image = try await captureService.capture(rect: rect, on: screen)

                let prefs = Preferences.shared
                let observations = try await ocrService.recognize(
                    image: image,
                    language: prefs.recognitionLanguage,
                    useCorrection: prefs.languageCorrection
                )

                let text = OCRTextLayoutService.sortedText(from: observations)

                guard !text.isEmpty else {
                    playEmptyResultSound()
                    state = .idle
                    return
                }

                try ClipboardService.copy(text)

                if Preferences.shared.playSoundAfterCopy {
                    playSuccessSound()
                }
            } catch {
                showErrorAlert(error)
            }

            state = .idle
        }
    }

    func selectionDidCancel() {
        state = .idle
    }
}
