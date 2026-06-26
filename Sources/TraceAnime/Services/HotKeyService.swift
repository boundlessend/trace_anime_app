import AppKit
import Carbon.HIToolbox

extension Notification.Name {
    static let captureHotKeyChanged = Notification.Name("TraceAnime.captureHotKeyChanged")
}

/// предустановленные варианты глобального хоткея захвата экрана
enum HotKeyOption: String, CaseIterable, Identifiable {
    case optionCommandS
    case controlCommandS
    case optionCommandA
    case controlCommandA

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .optionCommandS:
            return "⌥⌘S"
        case .controlCommandS:
            return "⌃⌘S"
        case .optionCommandA:
            return "⌥⌘A"
        case .controlCommandA:
            return "⌃⌘A"
        }
    }

    var keyCode: UInt32 {
        switch self {
        case .optionCommandS, .controlCommandS:
            return UInt32(kVK_ANSI_S)
        case .optionCommandA, .controlCommandA:
            return UInt32(kVK_ANSI_A)
        }
    }

    var modifiers: UInt32 {
        switch self {
        case .optionCommandS, .optionCommandA:
            return UInt32(optionKey | cmdKey)
        case .controlCommandS, .controlCommandA:
            return UInt32(controlKey | cmdKey)
        }
    }
}

/// регистрирует глобальный системный хоткей через Carbon и вызывает обработчик при нажатии
final class HotKeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
        installHandler()
    }

    private func installHandler() {
        var eventType: EventTypeSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData: UnsafeMutableRawPointer else {
                    return noErr
                }

                let service: HotKeyService = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
                service.handler()
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
    }

    /// регистрирует хоткей, снимая предыдущую регистрацию, если она была
    func register(keyCode: UInt32, modifiers: UInt32) {
        if let hotKeyRef: EventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        let hotKeyID: EventHotKeyID = EventHotKeyID(signature: OSType(0x5452_4143), id: 1)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    deinit {
        if let hotKeyRef: EventHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }

        if let eventHandlerRef: EventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }
}
