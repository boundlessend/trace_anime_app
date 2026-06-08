import AppKit
import Foundation

/// хранит загруженные превью, чтобы они не мигали при возврате во вкладку поиска
actor PreviewImageCache {
    static let shared: PreviewImageCache = PreviewImageCache()

    private let maxEntries: Int = 80
    private var images: [URL: Data] = [:]
    private var urls: [URL] = []

    func image(url: URL) -> NSImage? {
        guard let data: Data = images[url] else {
            return nil
        }

        return NSImage(data: data)
    }

    func store(data: Data, url: URL) {
        if images[url] == nil {
            urls.append(url)
        }

        images[url] = data
        trim()
    }

    func clear() {
        images.removeAll()
        urls.removeAll()
        URLCache.shared.removeAllCachedResponses()
    }

    /// ограничивает память, занятую превью из результатов поиска
    private func trim() {
        while urls.count > maxEntries {
            let removedURL: URL = urls.removeFirst()
            images.removeValue(forKey: removedURL)
        }
    }
}

func clearPreviewImageCache() {
    Task {
        await PreviewImageCache.shared.clear()
    }
}
