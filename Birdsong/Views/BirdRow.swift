import SwiftUI

struct BirdRow: View {
    let bird: Bird
    
    var body: some View {
        HStack {
            // ICON LOGIC: Image OR Letter
            if let imageName = bird.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            } else {
                // Fallback: Green Circle
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(String(bird.swedishName.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }
            
            // NAMES
            VStack(alignment: .leading) {
                Text(bird.swedishName)
                    .font(.headline)
                Text(bird.latinName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // DIFFICULTY DOTS
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < bird.difficulty ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BirdRow(bird: Bird(
        id: "1", swedishName: "Talgoxe", latinName: "Parus major", description: "Test", difficulty: 1, audioClips: [],
        imageName: "parus_major" // Test with image
    ))
}
