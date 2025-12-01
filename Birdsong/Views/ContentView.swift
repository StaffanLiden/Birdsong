import SwiftUI

struct ContentView: View {
    // Se till att store skapas här eller skickas in via @main
    // @StateObject var store = BirdStore() // Om du inte redan gör det i App-filen
    
    var body: some View {
        TabView {
            // Tab 1: Listan
            BirdListView()
                .tabItem {
                    Label("Lär dig", systemImage: "book")
                }
            
            // Tab 2: Quiz
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "infinity.circle") // Bytte ikon till evighet
                }
            
            // Tab 3: Statistik (Tidigare Settings)
            StatisticsView()
                .tabItem {
                    Label("Statistik", systemImage: "chart.bar")
                }
        }
    }
}
