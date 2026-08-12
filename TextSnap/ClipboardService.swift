import AppKit

struct ClipboardService {
    static func copy(_ text: String) throws {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        guard pasteboard.setString(text, forType: .string) else {
            throw AppError.clipboardWriteFailed
        }
    }
}
