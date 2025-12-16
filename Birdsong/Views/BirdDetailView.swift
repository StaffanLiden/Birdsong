import SwiftUI
import AVFoundation

struct BirdDetailView: View {
    let bird: Bird
    
    @State private var player: AVAudioPlayer?
    @State private var playingFileName: String? = nil
    
    var body: some View {
        ZStack {
            // 1. BAKGRUND
            Color(red: 0.87, green: 0.81, blue: 0.68)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- BILD & FOTOGRAF ---
                    VStack(spacing: 8) {
                        VintagePhotoFrame(image: safeImage(name: bird.imageName))
                            .frame(height: 250)
                            .padding(.horizontal, 40)
                            .rotationEffect(.degrees(-2))
                        
                        // FOTOCRED
                        Text(bird.imageCredit)
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.vintageInk.opacity(0.6))
                            .italic()
                    }
                    .padding(.top, 20)
                    
                    // --- TITEL & LATIN ---
                    VStack(spacing: 4) {
                        Text(bird.swedishName)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(.vintageInk)
                            .multilineTextAlignment(.center)
                        
                        Text(bird.latinName)
                            .font(.system(size: 18, design: .serif))
                            .italic()
                            .foregroundColor(.vintageInk.opacity(0.7))
                    }
                    
                    // --- LJUDLISTA ---
                    VStack(spacing: 12) {
                        ForEach(bird.audioClips, id: \.fileName) { clip in
                            AudioRow(
                                title: translateType(clip.type),
                                credit: clip.source,
                                isPlaying: playingFileName == clip.fileName,
                                action: { toggleSound(for: clip) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .background(Color.vintageInk.opacity(0.2))
                        .padding(.horizontal, 40)
                    
                    // --- BESKRIVNING ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kännetecken")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(.vintageLeather)
                            .underline(color: .vintageLeather)
                        
                        Text(bird.description)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(6)
                            .foregroundColor(.vintageInk)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // --- FAKTA-RUTOR ---
                    HStack(alignment: .top, spacing: 20) {
                        InfoBox(title: "Miljö", text: bird.habitats.joined(separator: ", "))
                        InfoBox(title: "Kategori", text: bird.broadCategory)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        // --- HÄR ÄR FIXEN FÖR DET LJUSA FÄLTET ---
        .toolbarBackground(.hidden, for: .navigationBar) // Döljer systemets bakgrund
        .navigationBarTitleDisplayMode(.inline)          // Håller titeln diskret
        .onDisappear {
            stopPlayer()
        }
    }
    
    // --- FUNKTIONER ---
    
    func translateType(_ type: String) -> String {
        switch type.lowercased() {
        case "song": return "Sång"
        case "call": return "Lockläte"
        case "flight call": return "Flyktläte"
        case "alarm call": return "Varningsläte"
        case "drumming": return "Trumning"
        case "begging call": return "Tiggarläte"
        case "wing flutter": return "Vingbuller"
        case "bill clapping": return "Näbbklapper"
        default: return type.capitalized
        }
    }
    
    func safeImage(name: String?) -> Image {
        if let name = name, let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "bird.fill")
    }
    
    func toggleSound(for clip: BirdAudio) {
        if playingFileName == clip.fileName {
            stopPlayer()
        } else {
            playSound(fileName: clip.fileName)
        }
    }
    
    func playSound(fileName: String) {
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                player?.stop()
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                playingFileName = fileName
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Filen hittades ej: \(name).\(ext)")
        }
    }
    
    func stopPlayer() {
        player?.stop()
        playingFileName = nil
    }
}

// --- HJÄLPKOMPONENTER ---

struct AudioRow: View {
    let title: String
    let credit: String
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.5, green: 0.6, blue: 0.5))
                        .frame(width: 44, height: 44)
                        .shadow(radius: 2)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.vintageInk)
                    
                    Text(credit)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.vintageInk.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.vintageInk.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoBox: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundColor(.vintageInk.opacity(0.5))
                .tracking(1)
            
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(.vintageInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.4))
        .cornerRadius(8)
    }
}
