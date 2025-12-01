import SwiftUI
import AVFoundation

struct BirdDetailView: View {
    let bird: Bird
    
    // The player must be a State property to keep the audio alive while playing
    @State private var audioPlayer: AVAudioPlayer?
    
    // Håller koll på vilken fil som är aktiv och om den spelas
    @State private var currentFileName: String? = nil
    @State private var isPlaying: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Bird Image & Credit (UPDATED)
                VStack(spacing: 5) {
                    if let imageName = bird.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit() // Visar hela bilden utan att beskära
                            .frame(maxWidth: .infinity) // Tar upp skärmens bredd
                            .frame(maxHeight: 300)      // Begränsar höjden så den inte tar över helt
                            .clipShape(RoundedRectangle(cornerRadius: 20)) // Snygga hörn istället för cirkel
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    } else {
                        // Fallback om bild saknas
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text(String(bird.swedishName.prefix(1)))
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundStyle(.green)
                            )
                    }
                    
                    // Visa bild-cred (Fotograf & Licens)
                    if !bird.imageCredit.isEmpty {
                        Text(bird.imageCredit)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
                
                // 2. Titles
                VStack(spacing: 8) {
                    Text(bird.swedishName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(bird.latinName)
                        .font(.title3)
                        .italic()
                        .foregroundStyle(.secondary)
                }
                
                // 3. Difficulty
                HStack {
                    Text("Svårighetsgrad:")
                        .font(.headline)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .foregroundStyle(index < bird.difficulty ? .orange : .gray.opacity(0.3))
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 5)
                
                Divider()
                    .padding(.horizontal)
                
                // 4. Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Kännetecken")
                        .font(.headline)
                    
                    Text(bird.description)
                        .font(.body)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // 5. Audio Clips List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Ljud")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if bird.audioClips.isEmpty {
                        Text("Inga ljud inspelade än.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(bird.audioClips, id: \.fileName) { clip in
                            Button(action: {
                                toggleAudio(fileName: clip.fileName)
                            }) {
                                HStack {
                                    // Visa paus om den spelas, annars play
                                    let showPause = (currentFileName == clip.fileName && isPlaying)
                                    
                                    Image(systemName: showPause ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(showPause ? .red : .blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(clip.type.capitalized)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                        Text(clip.source)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle(bird.swedishName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            audioPlayer?.stop()
            isPlaying = false
            currentFileName = nil
        }
    }
    
    // Logic to toggle Play/Pause
    func toggleAudio(fileName: String) {
        if currentFileName == fileName {
            if isPlaying {
                audioPlayer?.pause()
                isPlaying = false
            } else {
                audioPlayer?.play()
                isPlaying = true
            }
        } else {
            audioPlayer?.stop()
            playSpecificFile(fileName: fileName)
            currentFileName = fileName
            isPlaying = true
        }
    }
    
    // Logic to find and play a SPECIFIC file
    func playSpecificFile(fileName: String) {
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                print("Playing: \(fileName)")
            } catch {
                print("Error creating audio player: \(error)")
            }
        } else {
            print("Error: Could not find file '\(fileName)'")
        }
    }
}

// Preview Helper (behöver uppdateras för att matcha nya Bird-structen med habitats etc, men funkar för UI-test)
#Preview {
    NavigationView {
        BirdDetailView(bird: Bird(
            id: "1",
            swedishName: "Talgoxe",
            latinName: "Parus major",
            description: "Kraftig och tydlig sång.",
            difficulty: 1,
            audioClips: [],
            imageName: "parus_major",
            habitats: ["Skog", "Trädgård"]
        ))
    }
}
