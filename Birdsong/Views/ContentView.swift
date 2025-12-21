import SwiftUI

struct ContentView: View {
    @State private var hasStarted = false
    
    var body: some View {
        if !hasStarted {
            StartView(onStart: {
                hasStarted = true
            })
        } else {
            TabView {
                // NYTT: Inlärningsresan är nu startpunkten!
                LearningPathView()
                    .tabItem {
                        Label("Resan", systemImage: "map")
                    }
                
                // Vi behåller det gamla quizet för den som vill "öva fritt"
                QuizView()
                    .tabItem {
                        Label("Fri träning", systemImage: "music.note")
                    }
                
                ImageQuizView()
                    .tabItem {
                        Label("Bildquiz", systemImage: "photo")
                    }
                
                BirdListView()
                    .tabItem {
                        Label("Fåglar", systemImage: "book")
                    }
                
                StatisticsView()
                    .tabItem {
                        Label("Loggbok", systemImage: "chart.bar")
                    }
            }
            .accentColor(.vintageAccent) // Din snygga accentfärg
        }
    }
}
