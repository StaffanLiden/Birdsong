import SwiftUI

struct ContentView: View {
    
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
        // 1. Färga den valda ikonen ljus (Papper)
        .tint(Color.vintagePaper)
        // 2. Tvinga bakgrunden till mörkbrun (Läder)
        .toolbarBackground(Color.vintageLeather, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
