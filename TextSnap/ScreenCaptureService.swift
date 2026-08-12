import ScreenCaptureKit
import AppKit

final class ScreenCaptureService {
    func capture(rect: NSRect, on screen: NSScreen) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)

        guard let display = matchDisplay(for: screen, in: content.displays) else {
            throw AppError.displayMappingFailed
        }

        // Exclude our own app windows so overlays don't appear in the capture.
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let excludedApps = content.applications.filter { $0.bundleIdentifier == bundleID }
        let filter = SCContentFilter(display: display, excludingApplications: excludedApps, exceptingWindows: [])

        let scale = screen.backingScaleFactor
        let sourceRect = CoordinateConverter.toDisplayRect(selectionRect: rect, on: screen)
        let pixelSize = CoordinateConverter.toPixelSize(points: sourceRect.size, scale: scale)

        let config = SCStreamConfiguration()
        config.width = Int(pixelSize.width)
        config.height = Int(pixelSize.height)
        config.sourceRect = sourceRect
        config.showsCursor = false

        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }

    private func matchDisplay(for screen: NSScreen, in displays: [SCDisplay]) -> SCDisplay? {
        guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return nil
        }
        return displays.first { $0.displayID == screenNumber }
    }
}
