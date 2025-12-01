import SwiftUI

@main
struct BirdSongApp: App {
    // Initialize the store once here
    @StateObject private var store = BirdStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store) // Pass it down to all child views
        }
    }
}
