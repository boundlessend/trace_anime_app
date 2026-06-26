import AppKit

extension Notification.Name {
    static let runClipboardSearch = Notification.Name("TraceAnime.runClipboardSearch")
}

/// захватывает выделенную область экрана в буфер обмена через системный screencapture
final class ScreenCaptureService {
    /// запускает интерактивный выбор области; true если изображение попало в буфер обмена
    func captureSelectionToClipboard() async -> Bool {
        let changeCountBefore: Int = NSPasteboard.general.changeCount
        let process: Process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", "-c"]

        do {
            try process.run()
        } catch {
            return false
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            process.terminationHandler = { _ in
                continuation.resume()
            }
        }

        return NSPasteboard.general.changeCount != changeCountBefore
    }
}
