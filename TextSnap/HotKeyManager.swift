import Carbon

// Top-level C-compatible callback for Carbon event handling.
private func hotKeyEventCallback(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData else { return OSStatus(eventNotHandledErr) }
    let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async {
        manager.onHotKeyPressed?()
    }
    return noErr
}

final class HotKeyManager {
    var onHotKeyPressed: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    // Registers Command+Shift+2 as a global hotkey.
    func register() throws {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        var handlerRef: EventHandlerRef?
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventCallback,
            1,
            &eventType,
            selfPtr,
            &handlerRef
        )
        guard installStatus == noErr else {
            throw AppError.hotKeyRegistrationFailed("InstallEventHandler failed (OSStatus: \(installStatus))")
        }
        eventHandlerRef = handlerRef

        // Virtual key code 19 = "2" on standard keyboard.
        // Signature "TSNP" identifies this app's hotkey group.
        let signature: FourCharCode = 0x54534E50
        let hotKeyID = EventHotKeyID(signature: signature, id: 1)
        var keyRef: EventHotKeyRef?
        let registerStatus = RegisterEventHotKey(
            UInt32(19),
            UInt32(cmdKey | shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &keyRef
        )
        guard registerStatus == noErr else {
            throw AppError.hotKeyRegistrationFailed("RegisterEventHotKey failed (OSStatus: \(registerStatus))")
        }
        hotKeyRef = keyRef
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }
}
