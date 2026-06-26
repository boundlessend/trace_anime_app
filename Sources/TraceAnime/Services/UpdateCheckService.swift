import Foundation

struct AppRelease: Equatable {
    let version: String
    let url: URL
}

struct GitHubRelease: Decodable, Equatable {
    let tagName: String
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

enum UpdateCheckError: LocalizedError, Equatable {
    case nonHTTPResponse
    case http(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .nonHTTPResponse:
            return "GitHub вернул не-HTTP response при проверке обновлений."
        case .http(let statusCode):
            return "GitHub HTTP \(statusCode) при проверке обновлений."
        }
    }
}

/// проверяет последний релиз приложения на GitHub Releases
final class UpdateCheckService {
    private let session: URLSession
    private let releasesURL: URL
    private let decoder: JSONDecoder

    init(session: URLSession, releasesURL: URL, decoder: JSONDecoder) {
        self.session = session
        self.releasesURL = releasesURL
        self.decoder = decoder
    }

    /// возвращает последний релиз, если его версия новее текущей, иначе nil
    func availableUpdate(currentVersion: String) async throws -> AppRelease? {
        var request: URLRequest = URLRequest(
            url: releasesURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let payload: (Data, URLResponse) = try await session.data(for: request)

        guard let response: HTTPURLResponse = payload.1 as? HTTPURLResponse else {
            throw UpdateCheckError.nonHTTPResponse
        }

        guard (200...299).contains(response.statusCode) else {
            throw UpdateCheckError.http(statusCode: response.statusCode)
        }

        let release: GitHubRelease = try decoder.decode(GitHubRelease.self, from: payload.0)
        let latestVersion: String = normalizedVersion(release.tagName)

        guard isVersion(latestVersion, newerThan: currentVersion) else {
            return nil
        }

        return AppRelease(version: latestVersion, url: release.htmlURL)
    }
}

func currentAppVersion() -> String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
}

func normalizedVersion(_ version: String) -> String {
    version.hasPrefix("v") ? String(version.dropFirst()) : version
}

func isVersion(_ candidate: String, newerThan current: String) -> Bool {
    let candidateParts: [Int] = versionComponents(candidate)
    let currentParts: [Int] = versionComponents(current)
    let count: Int = max(candidateParts.count, currentParts.count)

    for index in 0..<count {
        let candidatePart: Int = index < candidateParts.count ? candidateParts[index] : 0
        let currentPart: Int = index < currentParts.count ? currentParts[index] : 0

        if candidatePart != currentPart {
            return candidatePart > currentPart
        }
    }

    return false
}

func versionComponents(_ version: String) -> [Int] {
    version.split(separator: ".").map { Int($0) ?? 0 }
}
