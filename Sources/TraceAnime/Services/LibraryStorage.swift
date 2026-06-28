import Foundation

struct LibraryStorage {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let directory: URL

    init(userDefaults: UserDefaults, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
        self.directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TraceAnime", isDirectory: true)
    }

    func loadHistory() throws -> [SearchHistoryEntry] {
        try load([SearchHistoryEntry].self, filename: "history.json", legacyKey: LibraryStorageKey.history.rawValue)
    }

    func saveHistory(_ history: [SearchHistoryEntry]) throws {
        try save(history, filename: "history.json")
    }

    func loadFavorites() throws -> [FavoriteResult] {
        try load([FavoriteResult].self, filename: "favorites.json", legacyKey: LibraryStorageKey.favorites.rawValue)
    }

    func saveFavorites(_ favorites: [FavoriteResult]) throws {
        try save(favorites, filename: "favorites.json")
    }

    private func load<T: Decodable>(_ type: T.Type, filename: String, legacyKey: String) throws -> T {
        let fileURL: URL = directory.appendingPathComponent(filename)

        if let data: Data = try? Data(contentsOf: fileURL) {
            return try decoder.decode(T.self, from: data)
        }

        // миграция: данные раньше лежали в UserDefaults (открытым текстом в plist префов)
        if let legacyData: Data = userDefaults.data(forKey: legacyKey) {
            let value: T = try decoder.decode(T.self, from: legacyData)
            try write(legacyData, filename: filename)
            userDefaults.removeObject(forKey: legacyKey)
            return value
        }

        return try decoder.decode(T.self, from: Data("[]".utf8))
    }

    private func save<T: Encodable>(_ value: T, filename: String) throws {
        let data: Data = try encoder.encode(value)
        try write(data, filename: filename)
    }

    private func write(_ data: Data, filename: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent(filename), options: .atomic)
    }
}

enum LibraryStorageKey: String {
    case history = "searchHistory"
    case favorites = "favoriteResults"
}
