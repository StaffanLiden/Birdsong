import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: BirdStore

    var body: some View {
        TabView {

            NavigationStack {
                BirdListView()   // your first tab
            }
            .tabItem {
                Label("Fälthandbok", systemImage: "book.closed.fill")
            }

            NavigationStack {
                QuizView()    // second tab
            }
            .tabItem {
                Label("Ljudquiz", systemImage: "music.note.list")
            }

            NavigationStack {
                ImageQuizView()    // third tab
            }
            .tabItem {
                Label("Bildquiz", systemImage: "photo.on.rectangle")
            }

            NavigationStack {
                StatisticsView()   // THIS is where your statistics view goes
            }
            .tabItem {
                Label("Statistik", systemImage: "chart.bar.xaxis")
            }
        }
    }
}
