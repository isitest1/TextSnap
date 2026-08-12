import SwiftUI

@main
struct TextSnapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("TextSnap", systemImage: "text.viewfinder") {
            AppMenuContent(coordinator: appDelegate.coordinator)
        }
        .menuBarExtraStyle(.menu)
    }
}
