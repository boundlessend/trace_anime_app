import Foundation

enum AppError: LocalizedError, Equatable {
    case emptyURL
    case invalidURL(String)
    case invalidAnilistID(String)
    case clipboardImageMissing
    case unsupportedClipboardImage
    case unsupportedFileType(URL)
    case fileTooLarge(Int)
    case fileReadFailed(URL)
    case unsupportedDrop

    var errorDescription: String? {
        switch self {
        case .emptyURL:
            return "Введите URL картинки."
        case .invalidURL(let value):
            return "Некорректный URL: \(value)"
        case .invalidAnilistID(let value):
            return "AniList ID должен быть положительным числом: \(value)"
        case .clipboardImageMissing:
            return "В буфере обмена нет изображения."
        case .unsupportedClipboardImage:
            return "Не удалось подготовить изображение из буфера обмена."
        case .unsupportedFileType(let url):
            return "Неподдерживаемый тип файла: \(url.lastPathComponent)"
        case .fileTooLarge(let bytes):
            return "Файл больше лимита trace.moe 25 MB: \(bytes) bytes"
        case .fileReadFailed(let url):
            return "Не удалось прочитать файл: \(url.path)"
        case .unsupportedDrop:
            return "Перетащенный объект не похож на изображение."
        }
    }
}
