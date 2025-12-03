import SwiftUI

struct ContentView: View {
    // Ingen init() här - vi sköter det i BirdsongApp
    
    var body: some View {
        TabView {
            // Tab 1: Fälthandboken
            BirdListView()
                .tabItem {
                    Label("Fälthandbok", systemImage: "book.closed.fill")
                }
            
            // Tab 2: Ljudquiz
            QuizView()
                .tabItem {
                    Label("Ljudquiz", systemImage: "music.note.list")
                }
            
            // Tab 3: Bildquiz
            ImageQuizView()
                .tabItem {
                    Label("Bildquiz", systemImage: "photo.on.rectangle")
                }
            
            // Tab 4: Statistik
            StatisticsView()
                .tabItem {
                    Label("Statistik", systemImage: "chart.bar.xaxis")
                }
        }
        // Vi sätter bara tintfärgen här (färgen på den VALDA ikonen)
        // Resten sköter BirdsongApp
        .tint(Color.vintageLeather)
    }
}
