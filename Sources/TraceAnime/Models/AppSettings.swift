import Foundation

struct AppSettings: Equatable {
    var apiKey: String
    var cutBorders: Bool
    var previewSize: PreviewSize
    var anilistIDText: String
    var language: AppLanguage
}

enum PreviewSize: String, CaseIterable, Identifiable {
    case small = "s"
    case medium = "m"
    case large = "l"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .small:
            return "S"
        case .medium:
            return "M"
        case .large:
            return "L"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case french = "fr"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        case .french:
            return "Français"
        }
    }
}

func defaultAppSettings() -> AppSettings {
    AppSettings(
        apiKey: "",
        cutBorders: true,
        previewSize: .medium,
        anilistIDText: "",
        language: .english
    )
}
