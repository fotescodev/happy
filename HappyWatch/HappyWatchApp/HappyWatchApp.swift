import SwiftUI
import WatchConnectivity

@main
struct HappyWatchApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
