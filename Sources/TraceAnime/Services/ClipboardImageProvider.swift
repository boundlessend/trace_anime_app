import AppKit
import Foundation

struct ClipboardImageProvider {
    func imagePayload() throws -> ImagePayload {
        let pasteboard: NSPasteboard = NSPasteboard.general

        if let image: NSImage = NSImage(pasteboard: pasteboard) {
            return try payload(from: image, filename: "clipboard.jpg")
        }

        throw AppError.clipboardImageMissing
    }

    private func payload(from image: NSImage, filename: String) throws -> ImagePayload {
        guard let data: Data = jpegRepresentation(from: image, compressionFactor: searchImageJPEGCompression) else {
            throw AppError.unsupportedClipboardImage
        }

        return ImagePayload(data: data, contentType: "image/jpeg", filename: filename)
    }
}

/// фактор сжатия JPEG для изображений, отправляемых на поиск
let searchImageJPEGCompression: Double = 0.92

/// кодирует NSImage в JPEG для отправки в trace.moe и сохранения превью
func jpegRepresentation(from image: NSImage, compressionFactor: Double) -> Data? {
    guard let tiffData: Data = image.tiffRepresentation,
        let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: tiffData)
    else {
        return nil
    }

    return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor])
}
