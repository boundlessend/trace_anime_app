import Foundation

enum SearchImageSourceKind: String, Codable {
    case clipboard
    case file
    case url
    case dropped
}

struct SearchImageSnapshot: Codable, Equatable {
    let data: Data?
    let url: URL?
    let contentType: String?
    let filename: String
    let sourceKind: SearchImageSourceKind?
}

struct SearchHistoryEntry: Codable, Equatable, Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let response: TraceMoeSearchResponse
    let sourceImage: SearchImageSnapshot?
}

struct FavoriteResult: Codable, Equatable, Identifiable {
    let id: String
    let date: Date
    let result: TraceMoeResult
    let sourceImage: SearchImageSnapshot?
}

func makeHistoryEntry(title: String, response: TraceMoeSearchResponse, sourceImage: SearchImageSnapshot?)
    -> SearchHistoryEntry
{
    SearchHistoryEntry(
        id: UUID(),
        title: title,
        date: Date(),
        response: response,
        sourceImage: sourceImage
    )
}

func makeFavoriteResult(result: TraceMoeResult, sourceImage: SearchImageSnapshot?) -> FavoriteResult {
    FavoriteResult(
        id: result.id,
        date: Date(),
        result: result,
        sourceImage: sourceImage
    )
}
