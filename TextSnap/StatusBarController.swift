import AppKit
import ServiceManagement

@MainActor
final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private weak var coordinator: CaptureCoordinator?

    // Keep references for dynamic state updates.
    private var languageAutoItem: NSMenuItem!
    private var languageEnglishItem: NSMenuItem!
    private var languageJapaneseItem: NSMenuItem!
    private var correctionItem: NSMenuItem!
    private var soundItem: NSMenuItem!
    private var loginItem: NSMenuItem!

    init(coordinator: CaptureCoordinator) {
        self.coordinator = coordinator
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TextSnap")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "TextSnap"
        }

        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self

        // Capture Text
        let captureItem = NSMenuItem(title: "Capture Text", action: #selector(captureText), keyEquivalent: "2")
        captureItem.keyEquivalentModifierMask = [.command, .shift]
        captureItem.target = self
        menu.addItem(captureItem)

        menu.addItem(.separator())

        // Recognition Language submenu
        let languageSubmenu = NSMenu()

        languageAutoItem = NSMenuItem(title: "Auto (Japanese + English)", action: #selector(setLanguageAuto), keyEquivalent: "")
        languageAutoItem.target = self
        languageSubmenu.addItem(languageAutoItem)

        languageEnglishItem = NSMenuItem(title: "English", action: #selector(setLanguageEnglish), keyEquivalent: "")
        languageEnglishItem.target = self
        languageSubmenu.addItem(languageEnglishItem)

        languageJapaneseItem = NSMenuItem(title: "Japanese", action: #selector(setLanguageJapanese), keyEquivalent: "")
        languageJapaneseItem.target = self
        languageSubmenu.addItem(languageJapaneseItem)

        let languageParent = NSMenuItem(title: "Recognition Language", action: nil, keyEquivalent: "")
        languageParent.submenu = languageSubmenu
        menu.addItem(languageParent)

        // Language Correction
        correctionItem = NSMenuItem(title: "Language Correction", action: #selector(toggleLanguageCorrection), keyEquivalent: "")
        correctionItem.target = self
        menu.addItem(correctionItem)

        // Play Sound After Copy
        soundItem = NSMenuItem(title: "Play Sound After Copy", action: #selector(togglePlaySound), keyEquivalent: "")
        soundItem.target = self
        menu.addItem(soundItem)

        menu.addItem(.separator())

        // Launch at Login
        loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.target = self
        menu.addItem(loginItem)

        menu.addItem(.separator())

        // Permission Help
        let permissionItem = NSMenuItem(title: "Permission Help", action: #selector(openPermissionHelp), keyEquivalent: "")
        permissionItem.target = self
        menu.addItem(permissionItem)

        // About TextSnap
        let aboutItem = NSMenuItem(title: "About TextSnap", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit TextSnap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        return menu
    }

    private func updateCheckmarks() {
        let prefs = Preferences.shared
        languageAutoItem.state = prefs.recognitionLanguage == .auto ? .on : .off
        languageEnglishItem.state = prefs.recognitionLanguage == .english ? .on : .off
        languageJapaneseItem.state = prefs.recognitionLanguage == .japanese ? .on : .off
        correctionItem.state = prefs.languageCorrection ? .on : .off
        soundItem.state = prefs.playSoundAfterCopy ? .on : .off
        loginItem.state = LoginItemService.isEnabled ? .on : .off
    }

    @objc private func captureText() { coordinator?.startCapture() }
    @objc private func setLanguageAuto() { Preferences.shared.recognitionLanguage = .auto }
    @objc private func setLanguageEnglish() { Preferences.shared.recognitionLanguage = .english }
    @objc private func setLanguageJapanese() { Preferences.shared.recognitionLanguage = .japanese }
    @objc private func toggleLanguageCorrection() { Preferences.shared.languageCorrection.toggle() }
    @objc private func togglePlaySound() { Preferences.shared.playSoundAfterCopy.toggle() }

    @objc private func toggleLaunchAtLogin() {
        do {
            try LoginItemService.setEnabled(!LoginItemService.isEnabled)
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @objc private func openPermissionHelp() { PermissionService.openSystemSettings() }
    @objc private func showAbout() { NSApp.orderFrontStandardAboutPanel(nil) }
}

extension StatusBarController: NSMenuDelegate {
    nonisolated func menuWillOpen(_ menu: NSMenu) {
        MainActor.assumeIsolated { updateCheckmarks() }
    }
}
