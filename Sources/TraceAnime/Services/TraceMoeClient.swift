import Foundation

final class TraceMoeClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let requestTimeout: TimeInterval = 30

    init(baseURL: URL, session: URLSession, decoder: JSONDecoder) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    /// выполняет поиск через trace.moe по ссылке или загруженному файлу
    func search(input: SearchInput, options: SearchOptions) async throws -> TraceMoeSearchResponse {
        switch input {
        case .imageURL(let imageURL):
            return try await searchByURL(imageURL: imageURL, options: options)
        case .imageData(let payload):
            return try await searchByImage(payload: payload, options: options)
        }
    }

    /// запрашивает текущую квоту trace.moe
    func me(apiKey: String) async throws -> TraceMoeUser {
        let url: URL = baseURL.appending(path: "me")
        var request: URLRequest = makeAPIRequest(url: url)
        applyAPIKey(apiKey: apiKey, request: &request)

        let data: Data = try await send(request: request)
        return try decoder.decode(TraceMoeUser.self, from: data)
    }

    private func searchByURL(imageURL: URL, options: SearchOptions) async throws -> TraceMoeSearchResponse {
        var components: URLComponents = try makeSearchComponents(options: options)
        var queryItems: [URLQueryItem] = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "url", value: imageURL.absoluteString))
        components.queryItems = queryItems

        guard let url: URL = components.url else {
            throw TraceMoeAPIError.requestBuildFailed("search url components")
        }

        var request: URLRequest = makeAPIRequest(url: url)
        applyAPIKey(apiKey: options.apiKey, request: &request)

        let data: Data = try await send(request: request)
        return try decoder.decode(TraceMoeSearchResponse.self, from: data)
    }

    private func searchByImage(payload: ImagePayload, options: SearchOptions) async throws -> TraceMoeSearchResponse {
        let maxBytes: Int = 25 * 1024 * 1024
        if payload.data.count > maxBytes {
            throw AppError.fileTooLarge(payload.data.count)
        }

        let components: URLComponents = try makeSearchComponents(options: options)

        guard let url: URL = components.url else {
            throw TraceMoeAPIError.requestBuildFailed("upload url components")
        }

        var request: URLRequest = makeAPIRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = payload.data
        request.setValue(payload.contentType, forHTTPHeaderField: "Content-Type")
        applyAPIKey(apiKey: options.apiKey, request: &request)

        let data: Data = try await send(request: request)
        return try decoder.decode(TraceMoeSearchResponse.self, from: data)
    }

    private func makeSearchComponents(options: SearchOptions) throws -> URLComponents {
        let searchURL: URL = baseURL.appending(path: "search")

        guard var components: URLComponents = URLComponents(url: searchURL, resolvingAgainstBaseURL: false) else {
            throw TraceMoeAPIError.requestBuildFailed("base search url")
        }

        var queryItems: [URLQueryItem] = []

        if options.cutBorders {
            queryItems.append(URLQueryItem(name: "cutBorders", value: nil))
        }

        queryItems.append(URLQueryItem(name: "anilistInfo", value: nil))

        if let anilistID: Int = options.anilistID {
            queryItems.append(URLQueryItem(name: "anilistID", value: String(anilistID)))
        }

        components.queryItems = queryItems
        return components
    }

    private func applyAPIKey(apiKey: String, request: inout URLRequest) {
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-trace-key")
        }
    }

    /// создает запрос без системного кэша и с коротким таймаутом
    private func makeAPIRequest(url: URL) -> URLRequest {
        var request: URLRequest = URLRequest(
            url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeout)
        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        return request
    }

    private func send(request: URLRequest) async throws -> Data {
        let tuple: (Data, URLResponse) = try await session.data(for: request)

        guard let httpResponse: HTTPURLResponse = tuple.1 as? HTTPURLResponse else {
            throw TraceMoeAPIError.nonHTTPResponse
        }

        if (200...299).contains(httpResponse.statusCode) {
            return tuple.0
        }

        let apiError: TraceMoeErrorResponse? = try? decoder.decode(TraceMoeErrorResponse.self, from: tuple.0)
        throw TraceMoeAPIError.http(
            statusCode: httpResponse.statusCode,
            message: apiError?.error ?? ""
        )
    }
}

enum TraceMoeAPIError: LocalizedError, Equatable {
    case requestBuildFailed(String)
    case nonHTTPResponse
    case http(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .requestBuildFailed(let context):
            return "Не удалось собрать API request: \(context)"
        case .nonHTTPResponse:
            return "trace.moe вернул не-HTTP response."
        case .http(let statusCode, let message):
            let visibleMessage: String = message.isEmpty ? "без сообщения" : message
            return "trace.moe HTTP \(statusCode): \(visibleMessage)."
        }
    }
}
