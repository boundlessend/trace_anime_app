import AppKit
import Foundation

/// создает компактный снимок исходного изображения для истории и избранного
func makeSearchImageSnapshot(input: SearchInput) -> SearchImageSnapshot? {
    switch input {
    case .imageURL(let url):
        return SearchImageSnapshot(
            data: nil, url: url, filename: url.absoluteString, sourceKind: .url)
    case .imageData(let payload):
        guard let thumbnailData: Data = makeJPEGThumbnailData(data: payload.data, maxDimension: 180.0) else {
            return nil
        }

        return SearchImageSnapshot(
            data: thumbnailData,
            url: nil,
            filename: payload.filename,
            sourceKind: searchImageSourceKind(filename: payload.filename)
        )
    }
}

func searchImageSourceKind(filename: String) -> SearchImageSourceKind {
    if filename == "clipboard.jpg" {
        return .clipboard
    }

    if filename == "drop.jpg" {
        return .dropped
    }

    return .file
}

/// сжимает локальное изображение, чтобы не раздувать настройки пользователя
func makeJPEGThumbnailData(data: Data, maxDimension: CGFloat) -> Data? {
    guard let image: NSImage = NSImage(data: data),
        let cgImage: CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
        return nil
    }

    let sourceWidth: CGFloat = CGFloat(cgImage.width)
    let sourceHeight: CGFloat = CGFloat(cgImage.height)
    let scale: CGFloat = min(maxDimension / max(sourceWidth, sourceHeight), 1.0)
    let thumbnailSize: NSSize = NSSize(width: sourceWidth * scale, height: sourceHeight * scale)
    let thumbnail: NSImage = NSImage(size: thumbnailSize)

    thumbnail.lockFocus()
    NSImage(cgImage: cgImage, size: NSSize(width: sourceWidth, height: sourceHeight)).draw(
        in: NSRect(origin: .zero, size: thumbnailSize),
        from: NSRect(origin: .zero, size: NSSize(width: sourceWidth, height: sourceHeight)),
        operation: .copy,
        fraction: 1.0
    )
    thumbnail.unlockFocus()

    return jpegRepresentation(from: thumbnail, compressionFactor: 0.82)
}
