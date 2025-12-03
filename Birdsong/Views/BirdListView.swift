import SwiftUI
import AVFoundation




struct BirdListView: View {
    @EnvironmentObject var store: BirdStore
    
    @State private var player: AVAudioPlayer?
    @State private var playingBirdId: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. BAKGRUND
                Color.vintagePaper
                    .ignoresSafeArea()
                
                // 2. LISTAN
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(store.birds) { bird in
                            
                            // Här är det nya upplägget:
                            // Vi lägger kortet som en knapp för navigering,
                            // MEN vi hanterar ljudknappen separat.
                            
                            ZStack(alignment: .bottomTrailing) {
                                
                                // A. Själva kortet (Länken till detaljvyn)
                                NavigationLink(destination: BirdDetailView(bird: bird)) {
                                    VintageCardOnlyVisual(bird: bird, isPlaying: playingBirdId == bird.id)
                                }
                                .buttonStyle(PlainButtonStyle()) // Tar bort blå länkfärg
                                
                                // B. Ljudknappen (Ligger OVANPÅ kortet)
                                // Vi placerar den manuellt för att den ska vara "fri" från länken
                                Button(action: {
                                    toggleSound(for: bird)
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: playingBirdId == bird.id ? "stop.circle.fill" : "play.circle.fill")
                                        Text(playingBirdId == bird.id ? "Stoppa" : "Lyssna")
                                    }
                                    .font(.system(.caption2, design: .serif))
                                    .foregroundColor(playingBirdId == bird.id ? .vintageInk : .vintageAccent)
                                    .padding(.horizontal, 12) // Lite större träffyta
                                    .padding(.vertical, 8)
                                    .background(
                                        (playingBirdId == bird.id ? Color.vintageAccent : Color.vintageAccent.opacity(0.1))
                                            .cornerRadius(4)
                                    )
                                }
                                .padding([.bottom, .trailing], 24) // Justera positionen så den hamnar rätt på kortet
                            }
                        }
                    }
                    .padding()
                }
            }
                        // ÄNDRA HÄR:
                        .navigationTitle("Fågelsång")
                    }
        .onDisappear {
            stopPlayer()
        }
    }
    
    // --- LJUDLOGIK (Samma som förut) ---
    func toggleSound(for bird: Bird) {
        if playingBirdId == bird.id {
            stopPlayer()
        } else {
            stopPlayer()
            playSound(for: bird)
        }
    }
    
    func playSound(for bird: Bird) {
        guard let clip = bird.audioClips.first else { return }
        let fileName = clip.fileName
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                playingBirdId = bird.id
            } catch { print("Error: \(error)") }
        }
    }
    
    func stopPlayer() {
        player?.stop()
        playingBirdId = nil
    }
}

// --- HJÄLPKOMPONENT: BARA GRAFIKEN ---
// Vi har skalat bort knappen från VintageCard så att vi kan placera den själva i listan
struct VintageCardOnlyVisual: View {
    let bird: Bird
    let isPlaying: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Bild
            VintagePhotoFrame(image: safeImage(name: bird.imageName))
                .frame(width: 90, height: 90)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(bird.swedishName)
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.vintageInk)
                
                Text(bird.latinName)
                    .font(.system(.caption, design: .serif))
                    .italic()
                    .foregroundColor(.vintageInk.opacity(0.7))
                
                Spacer()
                
                // OBS: Vi ritar INTE knappen här, bara tom plats för den
                // så att texten inte krockar med knappen vi lägger ovanpå
                Color.clear.frame(height: 30)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vintagePaper)
        .cornerRadius(2)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    func safeImage(name: String?) -> Image {
        if let name = name, let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "bird.fill")
    }
}
