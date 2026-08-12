import AppKit

protocol SelectionDelegate: AnyObject {
    func selectionDidComplete(rect: NSRect, on screen: NSScreen)
    func selectionDidCancel()
}

final class SelectionOverlayController {
    weak var delegate: SelectionDelegate?

    private struct OverlayEntry {
        let window: SelectionOverlayWindow
        let screen: NSScreen
        let view: SelectionOverlayView
    }

    private var entries: [OverlayEntry] = []

    func show() {
        // Do NOT activate the app. nonactivatingPanel lets the panel become key
        // (so it receives Escape) without stealing the active-app status from
        // whatever the user was doing before invoking the shortcut.
        for screen in NSScreen.screens {
            let window = SelectionOverlayWindow(for: screen)
            let view = SelectionOverlayView()
            view.delegate = self
            view.frame = NSRect(origin: .zero, size: screen.frame.size)
            window.contentView = view
            entries.append(OverlayEntry(window: window, screen: screen, view: view))
            window.orderFront(nil)
        }

        // Make the first overlay key so it receives keyboard events.
        if let first = entries.first {
            first.window.makeKey()
            first.window.makeFirstResponder(first.view)
        }
    }

    func hide() {
        for entry in entries {
            entry.window.close()
        }
        entries.removeAll()
    }
}

extension SelectionOverlayController: SelectionOverlayViewDelegate {
    func selectionView(_ view: SelectionOverlayView, didCompleteSelection rect: NSRect) {
        guard let entry = entries.first(where: { $0.view === view }) else { return }
        let screen = entry.screen
        hide()
        delegate?.selectionDidComplete(rect: rect, on: screen)
    }

    func selectionViewDidCancel(_ view: SelectionOverlayView) {
        hide()
        delegate?.selectionDidCancel()
    }
}
