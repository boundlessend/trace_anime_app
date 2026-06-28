import AppKit
import Foundation
import UniformTypeIdentifiers

struct FileImageProvider {
    private let maxUploadBytes: Int = traceMoeMaxUploadBytes

    /// открывает системный выбор изображения или видео для поиска
    func pickImageFile() throws -> URL? {
        let panel: NSOpenPanel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image, .movie, .mpeg4Movie, .quickTimeMovie]
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        let response: NSApplication.ModalResponse = panel.runModal()

        if response == .OK {
            return panel.url
        }

        return nil
    }

    /// проверяет файл до чтения в память и готовит данные для trace.moe
    func imagePayload(fileURL: URL) throws -> ImagePayload {
        try validateReadableMediaFile(fileURL: fileURL, maxBytes: maxUploadBytes)

        let data: Data = try Data(contentsOf: fileURL)
        let contentType: String = contentTypeForFile(fileURL: fileURL)
        return ImagePayload(data: data, contentType: contentType, filename: fileURL.lastPathComponent)
    }

    /// отсекает нелокальные, слишком большие и неподдерживаемые файлы
    private func validateReadableMediaFile(fileURL: URL, maxBytes: Int) throws {
        guard fileURL.isFileURL else {
            throw AppError.unsupportedDrop
        }

        let resourceValues: URLResourceValues
        do {
            resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey, .contentTypeKey])
        } catch {
            throw AppError.fileReadFailed(fileURL)
        }

        guard resourceValues.isRegularFile == true else {
            throw AppError.fileReadFailed(fileURL)
        }

        guard let fileSize: Int = resourceValues.fileSize else {
            throw AppError.fileReadFailed(fileURL)
        }

        if fileSize > maxBytes {
            throw AppError.fileTooLarge(fileSize)
        }

        guard isSupportedMediaFile(fileURL: fileURL, contentType: resourceValues.contentType) else {
            throw AppError.unsupportedFileType(fileURL)
        }
    }

    private func isSupportedMediaFile(fileURL: URL, contentType: UTType?) -> Bool {
        let resolvedContentType: UTType? = contentType ?? UTType(filenameExtension: fileURL.pathExtension)

        guard let resolvedContentType: UTType else {
            return false
        }

        return resolvedContentType.conforms(to: .image) || resolvedContentType.conforms(to: .movie)
    }

    private func contentTypeForFile(fileURL: URL) -> String {
        let contentType: UTType? = UTType(filenameExtension: fileURL.pathExtension)
        return contentType?.preferredMIMEType ?? "application/octet-stream"
    }
}
