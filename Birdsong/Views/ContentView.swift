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
                LearningPathView()
                    .tabItem {
                        Label("Resan", systemImage: "map")
                    }
                
                QuizView()
                    .tabItem {
                        Label("Fri träning", systemImage: "music.note")
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
            .tint(.vintageAccent)
        }
    }
}
