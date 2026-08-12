import Vision

// Sorts VNRecognizedTextObservation results into reading order (top-to-bottom, left-to-right).
// Vision bounding boxes use normalized coordinates with y=0 at the bottom of the image,
// so higher y values correspond to text that is higher on screen.
struct OCRTextLayoutService {
    static func sortedText(from observations: [VNRecognizedTextObservation]) -> String {
        guard !observations.isEmpty else { return "" }

        // Sort by Y descending: higher y = higher on screen = first in reading order.
        let byY = observations.sorted { $0.boundingBox.midY > $1.boundingBox.midY }

        // Group observations into lines based on vertical overlap.
        var lines: [[VNRecognizedTextObservation]] = []
        for obs in byY {
            var placed = false
            for i in 0..<lines.count {
                let lineAvgY = lines[i].map { $0.boundingBox.midY }.reduce(0, +) / CGFloat(lines[i].count)
                let lineMaxHeight = lines[i].compactMap { $0.boundingBox.height }.max() ?? 0
                if abs(obs.boundingBox.midY - lineAvgY) < lineMaxHeight * 0.6 {
                    lines[i].append(obs)
                    placed = true
                    break
                }
            }
            if !placed {
                lines.append([obs])
            }
        }

        // Sort each line by X (left to right).
        let sortedLines = lines.map { $0.sorted { $0.boundingBox.minX < $1.boundingBox.minX } }

        let lineStrings = sortedLines.map { lineObs in
            lineObs.compactMap { $0.topCandidates(1).first?.string }
                   .joined(separator: " ")
                   .trimmingCharacters(in: .whitespaces)
        }

        return lineStrings
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
