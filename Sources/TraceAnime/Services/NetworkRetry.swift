import Foundation

/// повторяет сетевую операцию при временных сбоях и пробрасывает последнюю ошибку
func retryingNetwork<T>(attempts: Int, operation: () async throws -> T) async throws -> T {
    var lastError: Error?

    for attempt in 1...max(attempts, 1) {
        do {
            return try await operation()
        } catch {
            lastError = error

            if !isRetriableNetworkError(error) {
                throw error
            }

            AppLog.network.warning(
                "network attempt \(attempt, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")

            if attempt < attempts {
                try? await Task.sleep(nanoseconds: UInt64(attempt) * 300_000_000)
            }
        }
    }

    throw lastError ?? URLError(.unknown)
}

private func isRetriableNetworkError(_ error: Error) -> Bool {
    if let urlError: URLError = error as? URLError {
        return retriableURLErrorCodes.contains(urlError.code)
    }

    if let apiError: TraceMoeAPIError = error as? TraceMoeAPIError, case .http(let statusCode, _) = apiError {
        return (500...599).contains(statusCode)
    }

    if let updateError: UpdateCheckError = error as? UpdateCheckError, case .http(let statusCode) = updateError {
        return (500...599).contains(statusCode)
    }

    return false
}

private let retriableURLErrorCodes: Set<URLError.Code> = [
    .timedOut,
    .networkConnectionLost,
    .notConnectedToInternet,
    .cannotConnectToHost,
    .cannotFindHost,
    .dnsLookupFailed,
]
