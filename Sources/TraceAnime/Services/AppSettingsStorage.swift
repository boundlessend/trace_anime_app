import Foundation

struct AppSettingsStorage {
    private let userDefaults: UserDefaults
    private let keychain: KeychainStorage

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.keychain = KeychainStorage(service: "com.senya.TraceAnime", account: "trace.moe.apiKey")
    }

    func load() throws -> AppSettings {
        var settings: AppSettings = defaultAppSettings()

        // миграция: раньше ключ лежал в UserDefaults открытым текстом, переносим в Keychain
        if let legacyKey: String = userDefaults.string(forKey: SettingsStorageKey.apiKey.rawValue) {
            try keychain.write(legacyKey)
            userDefaults.removeObject(forKey: SettingsStorageKey.apiKey.rawValue)
        }

        if let apiKey: String = try keychain.read() {
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

        if let historyLimitRaw: String = userDefaults.string(forKey: SettingsStorageKey.historyLimit.rawValue),
            let historyLimit: HistorySize = HistorySize(rawValue: historyLimitRaw)
        {
            settings.historyLimit = historyLimit
        }

        if let captureHotKeyRaw: String = userDefaults.string(forKey: SettingsStorageKey.captureHotKey.rawValue),
            let captureHotKey: HotKeyOption = HotKeyOption(rawValue: captureHotKeyRaw)
        {
            settings.captureHotKey = captureHotKey
        }

        return settings
    }

    /// сохраняет дешёвые настройки в UserDefaults; вызывается часто (в т.ч. на каждое нажатие клавиши)
    func savePreferences(settings: AppSettings) {
        userDefaults.set(settings.cutBorders, forKey: SettingsStorageKey.cutBorders.rawValue)
        userDefaults.set(settings.previewSize.rawValue, forKey: SettingsStorageKey.previewSize.rawValue)
        userDefaults.set(settings.anilistIDText, forKey: SettingsStorageKey.anilistIDText.rawValue)
        userDefaults.set(settings.language.rawValue, forKey: SettingsStorageKey.language.rawValue)
        userDefaults.set(settings.historyLimit.rawValue, forKey: SettingsStorageKey.historyLimit.rawValue)
        userDefaults.set(settings.captureHotKey.rawValue, forKey: SettingsStorageKey.captureHotKey.rawValue)
    }

    /// пишет токен в Keychain; вызывается с дебаунсом, а не на каждое нажатие
    func saveAPIKey(_ apiKey: String) throws {
        try keychain.write(apiKey)
    }
}

enum SettingsStorageKey: String {
    case apiKey = "apiKey"
    case cutBorders = "cutBorders"
    case previewSize = "previewSize"
    case anilistIDText = "anilistIDText"
    case language = "language"
    case historyLimit = "historyLimit"
    case captureHotKey = "captureHotKey"
}
