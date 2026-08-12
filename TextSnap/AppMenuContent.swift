import SwiftUI

struct AppMenuContent: View {
    let coordinator: CaptureCoordinator

    // @AppStorage uses the same UserDefaults keys as Preferences.shared,
    // so both stay in sync automatically.
    @AppStorage("recognitionLanguage") private var languageRaw = "auto"
    @AppStorage("languageCorrection")  private var languageCorrection = false
    @AppStorage("playSoundAfterCopy")  private var playSoundAfterCopy = true

    var body: some View {
        Button("Capture Text") {
            coordinator.startCapture()
        }
        .keyboardShortcut("2", modifiers: [.command, .shift])

        Divider()

        Picker("Recognition Language", selection: $languageRaw) {
            Text("Auto (Japanese + English)")
                .tag(Preferences.RecognitionLanguage.auto.rawValue)
            Text("English")
                .tag(Preferences.RecognitionLanguage.english.rawValue)
            Text("Japanese")
                .tag(Preferences.RecognitionLanguage.japanese.rawValue)
        }

        Toggle("Language Correction", isOn: $languageCorrection)
        Toggle("Play Sound After Copy", isOn: $playSoundAfterCopy)

        Divider()

        LaunchAtLoginToggle()

        Divider()

        Button("Permission Help") {
            PermissionService.openSystemSettings()
        }
        Button("About TextSnap") {
            NSApp.orderFrontStandardAboutPanel(nil)
        }

        Divider()

        Button("Quit TextSnap") {
            NSApp.terminate(nil)
        }
    }
}

private struct LaunchAtLoginToggle: View {
    @State private var isEnabled = LoginItemService.isEnabled

    var body: some View {
        Toggle("Launch at Login", isOn: $isEnabled)
            .onChange(of: isEnabled) { _, newValue in
                try? LoginItemService.setEnabled(newValue)
            }
            .onAppear {
                isEnabled = LoginItemService.isEnabled
            }
    }
}
