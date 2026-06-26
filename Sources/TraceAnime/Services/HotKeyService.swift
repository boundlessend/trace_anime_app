import AppKit
import Carbon.HIToolbox

/// регистрирует глобальный системный хоткей через Carbon и вызывает обработчик при нажатии
final class HotKeyService {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func register(keyCode: UInt32, modifiers: UInt32) {
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
