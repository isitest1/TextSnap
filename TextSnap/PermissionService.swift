import CoreGraphics
import AppKit

struct PermissionService {
    // Fast non-prompting check against TCC. Returns true if Screen Recording
    // is already granted for the currently running binary's code identity.
    static func checkScreenRecordingPermission() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    // Triggers the macOS system permission dialog when permission is not yet
    // determined. If permission is already granted or denied, this is a no-op.
    // Call only when the user explicitly requests a capture, not at app launch.
    @discardableResult
    static func requestScreenRecordingPermission() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    static func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
