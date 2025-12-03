import SwiftUI
import AVFoundation

struct BirdDetailView: View {
    let bird: Bird
    
    @State private var player: AVAudioPlayer?
    @State private var playingClipId: UUID? = nil
    
    var body: some View {
        ZStack {
            Color.vintagePaper.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- RUBRIKER ---
                    VStack(spacing: 4) {
                        Text(bird.swedishName)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(.vintageInk)
                            .multilineTextAlignment(.center)
                        
                        Text(bird.latinName)
                            .font(.system(size: 20, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(.vintageInk.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    // --- BILDEN & FOTOCREDD ---
                    VStack(spacing: 8) {
                        if let imageName = bird.imageName, let uiImage = UIImage(named: imageName) {
                            VintagePhotoFrame(image: Image(uiImage: uiImage))
                                .frame(maxWidth: 300)
                                .rotationEffect(.degrees(2))
                                .padding(.vertical, 10)
                        } else {
                            VintagePhotoFrame(image: Image(systemName: "bird.fill"))
                                .frame(width: 200, height: 200)
                        }
                        
                        // FOTOCREDD (Fixad)
                        if !bird.imageCredit.isEmpty {
                            // Vi städar bort "Photo:" om det finns i datan
                            let cleanCredit = bird.imageCredit.replacingOccurrences(of: "Photo: ", with: "")
                            Text("Foto: \(cleanCredit)")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(.vintageInk.opacity(0.5))
                        }
                    }
                    
                    // --- LJUDSPELARE (LISTA) ---
                    VStack(spacing: 12) {
                        ForEach(bird.audioClips) { clip in
                            AudioPlayerRow(
                                clip: clip,
                                isPlaying: playingClipId == clip.id,
                                onAction: {
                                    toggleSound(for: clip)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- TEXTINNEHÅLL ---
                    VStack(alignment: .leading, spacing: 20) {
                        
                        infoSection(title: "Kännetecken", text: bird.description)
                        
                        if !bird.habitats.isEmpty {
                            infoSection(title: "Miljö", text: bird.habitats.joined(separator: ", "))
                        }
                        
                        HStack {
                            Text("Svårighetsgrad:")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.vintageInk)
                            
                            HStack(spacing: 4) {
                                ForEach(1...3, id: \.self) { level in
                                    Image(systemName: level <= bird.difficulty ? "star.fill" : "star")
                                        .foregroundColor(.vintageLeather)
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .toolbarBackground(Color.vintagePaper, for: .navigationBar)
        .onDisappear {
            stopPlayer()
        }
    }
    
    func infoSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title3, design: .serif))
                .bold()
                .foregroundColor(.vintageLeather)
                .overlay(
                    Rectangle().frame(height: 1).offset(y: 4),
                    alignment: .bottomLeading
                )
            
            Text(text)
                .font(.system(.body, design: .serif))
                .lineSpacing(6)
                .foregroundColor(.vintageInk)
        }
    }
    
    func toggleSound(for clip: BirdAudio) {
        if playingClipId == clip.id {
            stopPlayer()
        } else {
            playSound(clip: clip)
        }
    }
    
    func playSound(clip: BirdAudio) {
        stopPlayer()
        
        let fileName = clip.fileName
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = nil
                player?.play()
                playingClipId = clip.id
                
                Timer.scheduledTimer(withTimeInterval: player?.duration ?? 0, repeats: false) { _ in
                    if self.playingClipId == clip.id {
                        self.playingClipId = nil
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func stopPlayer() {
        player?.stop()
        playingClipId = nil
    }
}

// --- LJUD-RAD KOMPONENTEN (Uppdaterad text) ---
struct AudioPlayerRow: View {
    let clip: BirdAudio
    let isPlaying: Bool
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.vintageAccent)
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2, y: 1)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(clip.type.capitalized)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.vintageInk)
                    
                    // FIXAD TEXT: Tar bort "Audio:" om det finns och skriver "Ljud:"
                    let cleanSource = clip.source.replacingOccurrences(of: "Audio: ", with: "")
                    Text("Ljud: \(cleanSource)")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(.vintageInk.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.vintageAccent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
