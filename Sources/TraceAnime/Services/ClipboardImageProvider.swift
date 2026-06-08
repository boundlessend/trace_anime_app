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
        guard let tiffData: Data = image.tiffRepresentation,
              let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: tiffData),
              let jpegData: Data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
            throw AppError.unsupportedClipboardImage
        }

        return ImagePayload(data: jpegData, contentType: "image/jpeg", filename: filename)
    }
}
