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

        if PermissionService.checkScreenRecordingPermission() {
            state = .selecting
            overlayController.show()
        } else {
            // Request triggers the system dialog if permission is not yet determined.
            // This dialog is separate from our alert below — the user must respond
            // to the system dialog first, then use "Quit & Relaunch" or the native
            // "Quit & Reopen" button macOS shows in System Settings.
            PermissionService.requestScreenRecordingPermission()
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = """
            TextSnap needs Screen Recording access to capture text.

            1. If a system dialog appeared, click "Open System Settings" in it.
            2. In System Settings → Privacy & Security → Screen Recording, \
            enable TextSnap.
            3. macOS will show a "Quit & Reopen" button — click it, \
            or use "Quit & Relaunch" below.
            """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit & Relaunch")
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            PermissionService.openSystemSettings()
        case .alertSecondButtonReturn:
            relaunchApp()
        default:
            break
        }
    }

    private func relaunchApp() {
        let bundleURL = Bundle.main.bundleURL
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: bundleURL, configuration: config) { _, _ in }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApp.terminate(nil)
        }
    }

    private func isScreenCapturePermissionError(_ error: Error) -> Bool {
        let nsError = error as NSError
        let scDomain = "com.apple.ScreenCaptureKit.SCStreamErrorDomain"
        if nsError.domain == scDomain {
            return nsError.code == -3801 || nsError.code == -100
        }
        return false
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
