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
        guard PermissionService.checkScreenRecordingPermission() else {
            showPermissionAlert()
            return
        }
        state = .selecting
        overlayController.show()
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "TextSnap needs Screen Recording access.\n\nIf the system dialog appeared, click Allow there.\nIf not, open System Settings → Privacy & Security → Screen Recording and enable TextSnap.\n\nThen click \"Quit & Relaunch\" to apply the change."
        alert.addButton(withTitle: "Quit & Relaunch")
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            relaunchApp()
        case .alertSecondButtonReturn:
            PermissionService.openSystemSettings()
        default:
            break
        }
    }

    private func isScreenCapturePermissionError(_ error: Error) -> Bool {
        // SCStreamError domain error codes for permission issues.
        // Code -3801 (userDeclined) and -100 appear when ScreenCaptureKit
        // cannot access screen content due to missing permission.
        let nsError = error as NSError
        let scDomain = "com.apple.ScreenCaptureKit.SCStreamErrorDomain"
        if nsError.domain == scDomain {
            return nsError.code == -3801 || nsError.code == -100
        }
        return false
    }

    private func relaunchApp() {
        let path = Bundle.main.bundlePath
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        try? task.run()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.terminate(nil)
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
                // ScreenCaptureKit returns an error when permission was granted
                // in TCC but the app has not yet been restarted. Reuse the
                // permission alert so the user can quit and relaunch.
                if isScreenCapturePermissionError(error) {
                    showPermissionAlert()
                } else {
                    showErrorAlert(error)
                }
            }

            state = .idle
        }
    }

    func selectionDidCancel() {
        state = .idle
    }
}
