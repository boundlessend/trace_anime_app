import Foundation

struct TraceMoeUser: Decodable, Equatable {
    let id: String
    let priority: Int
    let concurrency: Int
    let quota: Int
    let quotaUsed: Int

    enum CodingKeys: String, CodingKey {
        case id
        case priority
        case concurrency
        case quota
        case quotaUsed
    }

    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.priority = try decodeIntOrString(container: container, key: .priority)
        self.concurrency = try decodeIntOrString(container: container, key: .concurrency)
        self.quota = try decodeIntOrString(container: container, key: .quota)
        self.quotaUsed = try decodeIntOrString(container: container, key: .quotaUsed)
    }
}

/// декодирует числовые поля trace.moe, которые api иногда возвращает строками
func decodeIntOrString<Key: CodingKey>(container: KeyedDecodingContainer<Key>, key: Key) throws -> Int {
    if let value: Int = try? container.decode(Int.self, forKey: key) {
        return value
    }

    let text: String = try container.decode(String.self, forKey: key)
    guard let value: Int = Int(text) else {
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "expected integer-compatible value for \(key.stringValue), got \(text)"
        )
    }

    return value
}

struct TraceMoeSearchResponse: Codable, Equatable {
    let frameCount: Int
    let error: String
    let result: [TraceMoeResult]
}

struct TraceMoeResult: Codable, Equatable, Identifiable {
    let anilist: AnilistReference
    let filename: String
    let episode: EpisodeReference?
    let duration: Double?
    let from: Double
    let to: Double
    let at: Double?
    let similarity: Double
    let video: URL
    let image: URL

    var id: String {
        "\(filename)-\(from)-\(to)-\(similarity)"
    }
}

enum AnilistReference: Codable, Equatable {
    case id(Int)
    case info(AnilistInfo)

    init(from decoder: Decoder) throws {
        let container: SingleValueDecodingContainer = try decoder.singleValueContainer()

        if let id: Int = try? container.decode(Int.self) {
            self = .id(id)
            return
        }

        self = .info(try container.decode(AnilistInfo.self))
    }

    func encode(to encoder: Encoder) throws {
        var container: SingleValueEncodingContainer = encoder.singleValueContainer()

        switch self {
        case .id(let id):
            try container.encode(id)
        case .info(let info):
            try container.encode(info)
        }
    }
}

struct AnilistInfo: Codable, Equatable {
    let id: Int
    let idMal: Int?
    let isAdult: Bool
    let synonyms: [String]
    let title: AnilistTitle
}

struct AnilistTitle: Codable, Equatable {
    let native: String?
    let romaji: String?
    let english: String?
}

enum EpisodeReference: Codable, Equatable {
    case number(Double)
    case text(String)
    case list([EpisodeReference])

    init(from decoder: Decoder) throws {
        let container: SingleValueDecodingContainer = try decoder.singleValueContainer()

        if let value: Double = try? container.decode(Double.self) {
            self = .number(value)
            return
        }

        if let value: String = try? container.decode(String.self) {
            self = .text(value)
            return
        }

        self = .list(try container.decode([EpisodeReference].self))
    }

    func encode(to encoder: Encoder) throws {
        var container: SingleValueEncodingContainer = encoder.singleValueContainer()

        switch self {
        case .number(let value):
            try container.encode(value)
        case .text(let value):
            try container.encode(value)
        case .list(let values):
            try container.encode(values)
        }
    }
}

struct TraceMoeErrorResponse: Decodable, Equatable {
    let error: String
}
