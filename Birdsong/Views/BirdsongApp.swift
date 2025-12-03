import SwiftUI

@main
struct BirdsongApp: App {
    @StateObject private var store = BirdStore()

    init() {
        // VIKTIGT: Detta måste köras när appen startar
        VintageTheme.apply()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
