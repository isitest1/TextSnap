import Foundation

final class Preferences {
    static let shared = Preferences()

    enum RecognitionLanguage: String {
        case auto = "auto"
        case english = "en"
        case japanese = "ja"

        var displayName: String {
            switch self {
            case .auto: return "Auto (Japanese + English)"
            case .english: return "English"
            case .japanese: return "Japanese"
            }
        }
    }

    private let defaults = UserDefaults.standard

    var recognitionLanguage: RecognitionLanguage {
        get {
            guard let raw = defaults.string(forKey: "recognitionLanguage"),
                  let lang = RecognitionLanguage(rawValue: raw) else { return .auto }
            return lang
        }
        set { defaults.set(newValue.rawValue, forKey: "recognitionLanguage") }
    }

    var languageCorrection: Bool {
        get { defaults.object(forKey: "languageCorrection") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "languageCorrection") }
    }

    var playSoundAfterCopy: Bool {
        get { defaults.object(forKey: "playSoundAfterCopy") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "playSoundAfterCopy") }
    }
}
