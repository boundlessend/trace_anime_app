import Foundation

enum SearchInput: Equatable {
    case imageURL(URL)
    case imageData(ImagePayload)
}

struct ImagePayload: Equatable {
    let data: Data
    let contentType: String
    let filename: String
}

struct SearchOptions: Equatable {
    let cutBorders: Bool
    let anilistID: Int?
    let apiKey: String
}

func makeSearchOptions(settings: AppSettings) throws -> SearchOptions {
    let trimmedAnilistIDText: String = settings.anilistIDText.trimmingCharacters(in: .whitespacesAndNewlines)
    let anilistID: Int?

    if trimmedAnilistIDText.isEmpty {
        anilistID = nil
    } else if let parsedAnilistID: Int = Int(trimmedAnilistIDText), parsedAnilistID > 0 {
        anilistID = parsedAnilistID
    } else {
        throw AppError.invalidAnilistID(settings.anilistIDText)
    }

    return SearchOptions(
        cutBorders: settings.cutBorders,
        anilistID: anilistID,
        apiKey: settings.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    )
}
