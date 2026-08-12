import AppKit
import CoreGraphics

// SelectionOverlayView uses isFlipped=true (y=0 at top), which already matches
// ScreenCaptureKit's sourceRect coordinate space (y=0 at top-left of display, in points).
// Vision normalized coordinates have y=0 at bottom-left of the image.
struct CoordinateConverter {
    // Convert selection rect from overlay view (isFlipped, y=0 top) to
    // SCStreamConfiguration.sourceRect space (y=0 at top-left of display, in points).
    // No flip needed since overlay view already uses the same orientation.
    static func toDisplayRect(selectionRect: NSRect, on screen: NSScreen) -> CGRect {
        CGRect(
            x: selectionRect.origin.x,
            y: selectionRect.origin.y,
            width: selectionRect.width,
            height: selectionRect.height
        )
    }

    // Scale point dimensions to pixel dimensions using the screen's backing scale factor.
    // Rounds up to the nearest even number — ScreenCaptureKit requires even dimensions.
    static func toPixelSize(points: CGSize, scale: CGFloat) -> CGSize {
        func evenCeil(_ v: CGFloat) -> Int { Int((v * scale / 2).rounded(.up)) * 2 }
        return CGSize(width: evenCeil(points.width), height: evenCeil(points.height))
    }

    // Clamp a rect to the display bounds (in display points).
    static func clamp(_ rect: CGRect, to bounds: CGRect) -> CGRect {
        let x = max(bounds.minX, rect.minX)
        let y = max(bounds.minY, rect.minY)
        let maxX = min(bounds.maxX, rect.maxX)
        let maxY = min(bounds.maxY, rect.maxY)
        return CGRect(x: x, y: y, width: max(0, maxX - x), height: max(0, maxY - y))
    }
}
