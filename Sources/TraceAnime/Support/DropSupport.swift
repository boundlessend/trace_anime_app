import Foundation

/// извлекает только локальную ссылку на файл из данных перетаскивания
func decodeDroppedFileURL(item: NSSecureCoding?) throws -> URL {
    if let url: URL = item as? URL {
        return try validatedDroppedFileURL(url)
    }

    if let data: Data = item as? Data,
       let url: URL = URL(dataRepresentation: data, relativeTo: nil) {
        return try validatedDroppedFileURL(url)
    }

    if let string: String = item as? String {
        if let url: URL = URL(string: string),
           url.isFileURL {
            return try validatedDroppedFileURL(url)
        }

        if string.hasPrefix("/") {
            return try validatedDroppedFileURL(URL(fileURLWithPath: string))
        }
    }

    throw AppError.unsupportedDrop
}

private func validatedDroppedFileURL(_ url: URL) throws -> URL {
    guard url.isFileURL else {
        throw AppError.unsupportedDrop
    }

    return url
}
