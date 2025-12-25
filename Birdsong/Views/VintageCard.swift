import SwiftUI



struct VintageCard: View {
    let bird: Bird
    // NYTT: Vi skickar in om just denna fågel spelas
    let isPlaying: Bool
    var onPlay: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Bilden
            VintagePhotoFrame(image: safeImage(name: bird.imageName))
                .frame(width: 90, height: 90)
            
            // Texten
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
                
                // --- KNAPPEN (Nu med logik för ikon) ---
                Button(action: {
                    onPlay?()
                }) {
                    HStack(spacing: 4) {
                        // Ändra ikon och text beroende på status
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        Text(isPlaying ? "Stoppa" : "Lyssna")
                    }
                    .font(.system(.caption2, design: .serif))
                    // Om den spelar gör vi den lite mörkare/tydligare
                    .foregroundColor(isPlaying ? .vintageInk : .vintageAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (isPlaying ? Color.vintageAccent : Color.vintageAccent.opacity(0.1))
                            .cornerRadius(4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vintagePaper)
        .cornerRadius(2)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    func safeImage(name: String?) -> Image {
        if let name = name, let uiImage = UIImage(named: name) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "bird.fill")
    }
}
