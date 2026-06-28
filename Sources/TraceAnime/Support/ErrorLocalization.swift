import Foundation

func localizedErrorText(_ error: Error, language: AppLanguage) -> String {
    if let appError: AppError = error as? AppError {
        return localizedAppError(appError, language: language)
    }

    if let apiError: TraceMoeAPIError = error as? TraceMoeAPIError {
        return localizedAPIError(apiError, language: language)
    }

    return error.localizedDescription
}

private func localizedAppError(_ error: AppError, language: AppLanguage) -> String {
    switch language {
    case .english:
        return englishAppError(error)
    case .russian:
        return error.localizedDescription
    case .french:
        switch error {
        case .emptyURL:
            return "Saisissez l'URL de l'image."
        case .invalidURL(let value):
            return "URL incorrecte: \(value)"
        case .invalidAnilistID(let value):
            return "L'ID AniList doit être un nombre positif: \(value)"
        case .clipboardImageMissing:
            return "Le presse-papiers ne contient pas d'image."
        case .unsupportedClipboardImage:
            return "Impossible de préparer l'image du presse-papiers."
        case .unsupportedFileType(let url):
            return "Type de fichier non pris en charge: \(url.lastPathComponent)"
        case .fileTooLarge(let bytes):
            return "Le fichier dépasse la limite trace.moe de 25 MB: \(bytes) bytes"
        case .fileReadFailed(let url):
            return "Impossible de lire le fichier: \(url.path)"
        case .unsupportedDrop:
            return "L'élément déposé ne ressemble pas à une image."
        }
    }
}

private func localizedAPIError(_ error: TraceMoeAPIError, language: AppLanguage) -> String {
    switch language {
    case .english:
        return englishAPIError(error)
    case .russian:
        return error.localizedDescription
    case .french:
        switch error {
        case .requestBuildFailed(let context):
            return "Impossible de créer la requête API: \(context)"
        case .nonHTTPResponse:
            return "trace.moe a renvoyé une réponse non HTTP."
        case .http(let statusCode, let message):
            let visibleMessage: String = message.isEmpty ? "sans message" : message
            return "trace.moe HTTP \(statusCode): \(visibleMessage)."
        }
    }
}

private func englishAppError(_ error: AppError) -> String {
    switch error {
    case .emptyURL:
        return "Enter an image URL."
    case .invalidURL(let value):
        return "Invalid URL: \(value)"
    case .invalidAnilistID(let value):
        return "AniList ID must be a positive number: \(value)"
    case .clipboardImageMissing:
        return "Clipboard does not contain an image."
    case .unsupportedClipboardImage:
        return "Could not prepare the clipboard image."
    case .unsupportedFileType(let url):
        return "Unsupported file type: \(url.lastPathComponent)"
    case .fileTooLarge(let bytes):
        return "File exceeds trace.moe 25 MB limit: \(bytes) bytes"
    case .fileReadFailed(let url):
        return "Could not read file: \(url.path)"
    case .unsupportedDrop:
        return "Dropped item does not look like an image."
    }
}

private func englishAPIError(_ error: TraceMoeAPIError) -> String {
    switch error {
    case .requestBuildFailed(let context):
        return "Could not build API request: \(context)"
    case .nonHTTPResponse:
        return "trace.moe returned a non-HTTP response."
    case .http(let statusCode, let message):
        let visibleMessage: String = message.isEmpty ? "no message" : message
        return "trace.moe HTTP \(statusCode): \(visibleMessage)."
    }
}
