import SwiftUI

@main
struct AudiraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 920, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)

        Settings {
            SettingsView()
        }
    }
}
