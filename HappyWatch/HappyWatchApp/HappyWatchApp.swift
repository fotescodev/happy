import SwiftUI
import WatchConnectivity

@main
struct HappyWatchApp: App {
    @State private var appState: AppState

    init() {
        #if DEBUG
        _appState = State(initialValue: AppState.debug())
        #else
        _appState = State(initialValue: AppState())
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
