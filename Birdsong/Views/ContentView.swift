import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: BirdStore
    
    // Håller koll på om vi ska visa startsidan eller appen
    @State private var showStartScreen = true

    var body: some View {
        Group {
            if showStartScreen {
                // VISA STARTSIDAN
                StartView {
                    // Detta körs när man klickar på knappen i StartView
                    showStartScreen = false
                }
                .transition(.opacity) // Snygg toning när den försvinner
            } else {
                // VISA DEN VANLIGA APPEN (Tab Bar)
                mainAppContent
            }
        }
    }
    
    // Vi flyttar din gamla TabView hit för att hålla koden ren
    var mainAppContent: some View {
        TabView {
            NavigationStack {
                BirdListView()
            }
            .tabItem {
                Label("Arter", systemImage: "book.closed.fill")
            }

            NavigationStack {
                QuizView()
            }
            .tabItem {
                Label("Ljudquiz", systemImage: "music.note.list")
            }

            NavigationStack {
                ImageQuizView()
            }
            .tabItem {
                Label("Bildquiz", systemImage: "photo.on.rectangle")
            }

            NavigationStack {
                StatisticsView()
            }
            .tabItem {
                Label("Statistik", systemImage: "chart.bar.xaxis")
            }
        }
    }
}
