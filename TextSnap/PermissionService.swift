import CoreGraphics
import AppKit

struct PermissionService {
    // CGRequestScreenCaptureAccess registers this app in TCC and triggers the
    // system permission dialog on first call. Returns true immediately if the
    // app already has permission; returns false and shows the dialog otherwise.
    // Unlike CGPreflightScreenCaptureAccess, this actually makes the app appear
    // in System Settings → Privacy & Security → Screen Recording.
    static func checkScreenRecordingPermission() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    static func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
