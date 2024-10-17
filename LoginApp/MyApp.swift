import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView() // Die Hauptansicht der App
                    .environmentObject(appState) // Übergibt das AppState-Objekt an die gesamte App
            }
        }
    }
}
