import AppKit
import Foundation

/// хранит загруженные превью, чтобы они не мигали при возврате во вкладку поиска
final class PreviewImageCache {
    static let shared: PreviewImageCache = PreviewImageCache()

    private let cache: NSCache<NSURL, NSData> = {
        let cache: NSCache<NSURL, NSData> = NSCache()
        cache.countLimit = 80
        return cache
    }()

    func image(url: URL) -> NSImage? {
        guard let data: NSData = cache.object(forKey: url as NSURL) else {
            return nil
        }

        return NSImage(data: data as Data)
    }

    func store(data: Data, url: URL) {
        cache.setObject(data as NSData, forKey: url as NSURL)
    }

    func clear() {
        cache.removeAllObjects()
        URLCache.shared.removeAllCachedResponses()
    }
}

func clearPreviewImageCache() {
    PreviewImageCache.shared.clear()
}
