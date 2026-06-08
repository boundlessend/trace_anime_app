import Foundation

func displayTitle(anilist: AnilistReference) -> String {
    switch anilist {
    case .id(let id):
        return "AniList \(id)"
    case .info(let info):
        let candidates: [String?] = [
            info.title.english,
            info.title.romaji,
            info.title.native,
            info.synonyms.first
        ]

        return candidates.compactMap { $0 }.first { !$0.isEmpty } ?? "AniList \(info.id)"
    }
}

func anilistID(anilist: AnilistReference) -> Int {
    switch anilist {
    case .id(let id):
        return id
    case .info(let info):
        return info.id
    }
}

func displayEpisode(_ episode: EpisodeReference?, language: AppLanguage) -> String {
    guard let episode: EpisodeReference else {
        return t(.episodeUnknown, language: language)
    }

    switch episode {
    case .number(let value):
        return "\(t(.episode, language: language)) \(trimmedNumber(value))"
    case .text(let value):
        return "\(t(.episode, language: language)) \(value)"
    case .list(let values):
        let prefix: String = "\(t(.episode, language: language)) "
        let joined: String = values.map {
            displayEpisode($0, language: language).replacingOccurrences(of: prefix, with: "")
        }.joined(separator: ", ")
        return "\(t(.episode, language: language)) \(joined)"
    }
}

func displayTimestamp(_ seconds: Double?) -> String {
    guard let seconds: Double else {
        return "00:00"
    }

    let rounded: Int = Int(seconds.rounded())
    let minutes: Int = rounded / 60
    let remainingSeconds: Int = rounded % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}

func displaySimilarity(_ value: Double) -> String {
    String(format: "%.1f%%", value * 100.0)
}

func trimmedNumber(_ value: Double) -> String {
    if value.rounded() == value {
        return String(Int(value))
    }

    return String(format: "%.2f", value)
}

func previewURL(_ url: URL, size: PreviewSize, muteVideo: Bool) -> URL {
    guard var components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return url
    }

    var queryItems: [URLQueryItem] = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: "size", value: size.rawValue))

    if muteVideo {
        queryItems.append(URLQueryItem(name: "mute", value: nil))
    }

    components.queryItems = queryItems
    return components.url ?? url
}
