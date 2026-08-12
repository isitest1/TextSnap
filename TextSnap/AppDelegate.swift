import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // Coordinator is created here so the SwiftUI menu can reference it.
    let coordinator = CaptureCoordinator()
    private var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[TextSnap] applicationDidFinishLaunching called")
        let hotKey = HotKeyManager()
        hotKey.onHotKeyPressed = { [weak self] in
            self?.coordinator.startCapture()
        }
        hotKeyManager = hotKey

        do {
            try hotKey.register()
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager?.unregister()
    }
}
