import Foundation

struct AppSettingsStorage {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func load() throws -> AppSettings {
        var settings: AppSettings = defaultAppSettings()

        if let apiKey: String = userDefaults.string(forKey: SettingsStorageKey.apiKey.rawValue) {
            settings.apiKey = apiKey
        }

        if userDefaults.object(forKey: SettingsStorageKey.cutBorders.rawValue) != nil {
            settings.cutBorders = userDefaults.bool(forKey: SettingsStorageKey.cutBorders.rawValue)
        }

        if let previewSizeRaw: String = userDefaults.string(forKey: SettingsStorageKey.previewSize.rawValue),
            let previewSize: PreviewSize = PreviewSize(rawValue: previewSizeRaw)
        {
            settings.previewSize = previewSize
        }

        if let anilistIDText: String = userDefaults.string(forKey: SettingsStorageKey.anilistIDText.rawValue) {
            settings.anilistIDText = anilistIDText
        }

        if let languageRaw: String = userDefaults.string(forKey: SettingsStorageKey.language.rawValue),
            let language: AppLanguage = AppLanguage(rawValue: languageRaw)
        {
            settings.language = language
        }

        return settings
    }

    func save(settings: AppSettings) throws {
        userDefaults.set(settings.apiKey, forKey: SettingsStorageKey.apiKey.rawValue)
        userDefaults.set(settings.cutBorders, forKey: SettingsStorageKey.cutBorders.rawValue)
        userDefaults.set(settings.previewSize.rawValue, forKey: SettingsStorageKey.previewSize.rawValue)
        userDefaults.set(settings.anilistIDText, forKey: SettingsStorageKey.anilistIDText.rawValue)
        userDefaults.set(settings.language.rawValue, forKey: SettingsStorageKey.language.rawValue)
    }
}

enum SettingsStorageKey: String {
    case apiKey = "apiKey"
    case cutBorders = "cutBorders"
    case previewSize = "previewSize"
    case anilistIDText = "anilistIDText"
    case language = "language"
}
