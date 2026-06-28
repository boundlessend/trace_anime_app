import os

/// единые категории структурного логирования приложения
enum AppLog {
    static let capture: Logger = Logger(subsystem: "com.senya.TraceAnime", category: "capture")
    static let network: Logger = Logger(subsystem: "com.senya.TraceAnime", category: "network")
    static let preview: Logger = Logger(subsystem: "com.senya.TraceAnime", category: "preview")
}
