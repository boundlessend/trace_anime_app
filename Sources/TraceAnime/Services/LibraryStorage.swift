import Foundation

struct LibraryStorage {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userDefaults: UserDefaults, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    func loadHistory() throws -> [SearchHistoryEntry] {
        try load([SearchHistoryEntry].self, key: LibraryStorageKey.history.rawValue)
    }

    func saveHistory(_ history: [SearchHistoryEntry]) throws {
        try save(history, key: LibraryStorageKey.history.rawValue)
    }

    func loadFavorites() throws -> [FavoriteResult] {
        try load([FavoriteResult].self, key: LibraryStorageKey.favorites.rawValue)
    }

    func saveFavorites(_ favorites: [FavoriteResult]) throws {
        try save(favorites, key: LibraryStorageKey.favorites.rawValue)
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) throws -> T {
        guard let data: Data = userDefaults.data(forKey: key) else {
            let emptyArrayData: Data = Data("[]".utf8)
            return try decoder.decode(T.self, from: emptyArrayData)
        }

        return try decoder.decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String) throws {
        let data: Data = try encoder.encode(value)
        userDefaults.set(data, forKey: key)
    }
}

enum LibraryStorageKey: String {
    case history = "searchHistory"
    case favorites = "favoriteResults"
}
