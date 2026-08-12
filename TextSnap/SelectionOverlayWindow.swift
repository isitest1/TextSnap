import AppKit

// NSPanel with .nonactivatingPanel lets this window become key (receive keyboard events)
// without making TextSnap the active application. When the panel closes, the previously
// active app remains active — no app-switch handoff that can hang the window server.
final class SelectionOverlayWindow: NSPanel {
    override var canBecomeKey: Bool { true }

    init(for screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .screenSaver
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        acceptsMouseMovedEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovable = false
    }
}
