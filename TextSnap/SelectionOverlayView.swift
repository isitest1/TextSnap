import AppKit

protocol SelectionOverlayViewDelegate: AnyObject {
    func selectionView(_ view: SelectionOverlayView, didCompleteSelection rect: NSRect)
    func selectionViewDidCancel(_ view: SelectionOverlayView)
}

final class SelectionOverlayView: NSView {
    weak var delegate: SelectionOverlayViewDelegate?

    private var startPoint: NSPoint?
    private(set) var selectionRect: NSRect = .zero

    override var acceptsFirstResponder: Bool { true }

    // Flipped so y=0 is at the top of the screen, matching ScreenCaptureKit's sourceRect orientation.
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        // Dim the entire screen with a semi-transparent overlay.
        let overlay = NSBezierPath(rect: bounds)
        if !selectionRect.isEmpty {
            // Even-odd winding rule punches out the selection area, leaving it clear.
            overlay.append(NSBezierPath(rect: selectionRect))
            overlay.windingRule = .evenOdd
        }
        NSColor.black.withAlphaComponent(0.45).setFill()
        overlay.fill()

        if !selectionRect.isEmpty {
            NSColor.white.withAlphaComponent(0.9).setStroke()
            let border = NSBezierPath(rect: selectionRect)
            border.lineWidth = 1.5
            border.stroke()
        }
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        selectionRect = .zero
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)
        selectionRect = makeRect(from: start, to: current)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint else { return }
        let end = convert(event.locationInWindow, from: nil)
        let rect = makeRect(from: start, to: end)
        startPoint = nil

        let minimumSize: CGFloat = 10
        guard rect.width >= minimumSize && rect.height >= minimumSize else {
            selectionRect = .zero
            needsDisplay = true
            delegate?.selectionViewDidCancel(self)
            return
        }

        delegate?.selectionView(self, didCompleteSelection: rect)
    }

    override func rightMouseDown(with event: NSEvent) {
        delegate?.selectionViewDidCancel(self)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            delegate?.selectionViewDidCancel(self)
        } else {
            super.keyDown(with: event)
        }
    }

    private func makeRect(from a: NSPoint, to b: NSPoint) -> NSRect {
        NSRect(
            x: min(a.x, b.x),
            y: min(a.y, b.y),
            width: abs(a.x - b.x),
            height: abs(a.y - b.y)
        )
    }
}
