import SwiftUI

struct BirdListView: View {
    @EnvironmentObject var store: BirdStore
    
    // Vi använder vår nya globala spelare
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    
    // För uppdatering av stjärnor vid återbesök
    @State private var lastUpdate = Date()

    var body: some View {
        NavigationView {
            List(store.birds) { bird in
                HStack {
                    // --- NYTT: Play-knapp i listan ---
                    // Vi visar knappen om fågeln har minst ett ljudklipp
                    if let clip = bird.audioClips.first {
                        Button(action: {
                            audioManager.play(fileName: clip.fileName)
                        }) {
                            Image(systemName: audioManager.isFilePlaying(fileName: clip.fileName) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Viktigt! Annars klickar man på hela raden
                        .padding(.trailing, 5)
                    } else {
                        // Platshållare om inget ljud finns, för att hålla layouten snygg
                        Image(systemName: "speaker.slash")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 25)
                            .padding(.trailing, 5)
                    }
                    // ---------------------------------
                    
                    NavigationLink(destination: BirdDetailView(bird: bird)) {
                        HStack {
                            // Bild
                            if let imgName = bird.imageName, !imgName.isEmpty {
                                Image(imgName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 50, height: 50)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(bird.swedishName)
                                    .font(.headline)
                                Text(bird.latinName)
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Status (Stjärnor/Prickar)
                            statusView(for: bird, trigger: lastUpdate)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Fåglar")
            .onAppear {
                lastUpdate = Date()
            }
            .onDisappear {
                // Stoppa ljudet om man lämnar listan (valfritt)
                audioManager.stop()
            }
        }
    }
    
    @ViewBuilder
    func statusView(for bird: Bird, trigger: Date) -> some View {
        let streak = QuizPersistence.shared.getStreak(for: bird.id)
        
        if streak >= 3 {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title3)
        } else if streak > 0 {
            HStack(spacing: 3) {
                ForEach(0..<streak, id: \.self) { _ in
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
        } else {
            EmptyView()
        }
    }
}
