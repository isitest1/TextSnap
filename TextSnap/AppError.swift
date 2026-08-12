import Foundation

enum AppError: Error, LocalizedError {
    case screenRecordingPermissionDenied
    case screenCaptureFailed(String)
    case displayMappingFailed
    case ocrFailed(String)
    case noTextFound
    case clipboardWriteFailed
    case hotKeyRegistrationFailed(String)
    case loginItemUpdateFailed(String)

    var errorDescription: String? {
        switch self {
        case .screenRecordingPermissionDenied:
            return "Screen Recording permission is required. Please grant it in System Settings > Privacy & Security > Screen Recording."
        case .screenCaptureFailed(let detail):
            return "Screen capture failed. \(detail)"
        case .displayMappingFailed:
            return "Failed to identify the display for the selected area."
        case .ocrFailed(let detail):
            return "Text recognition failed. \(detail)"
        case .noTextFound:
            return "No text was found in the selected area."
        case .clipboardWriteFailed:
            return "Failed to copy text to the clipboard."
        case .hotKeyRegistrationFailed(let detail):
            return "Failed to register the global shortcut (⌘⇧2). \(detail)\nAnother app may be using this key combination."
        case .loginItemUpdateFailed(let detail):
            return "Failed to update the login item setting. \(detail)"
        }
    }
}
