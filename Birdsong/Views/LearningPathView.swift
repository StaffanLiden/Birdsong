import SwiftUI

struct Level: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let x: CGFloat // 0.0 = Vänster, 1.0 = Höger
    let y: CGFloat // 0.0 = Toppen, 1.0 = Botten
    var isLocked: Bool
}

struct LearningPathView: View {
    
    // Alla 14 stationer utplacerade längs stigen (nedifrån och upp)
    // Du kan behöva finjustera x och y lite för att träffa stigen exakt!
    let levels: [Level] = [
        // ZON 1: Stugan & Trädgården (Längst ner)
        Level(number: 1, name: "Stugan", x: 0.55, y: 0.94, isLocked: false),
        Level(number: 2, name: "Trädgården", x: 0.35, y: 0.89, isLocked: false),
        Level(number: 3, name: "Byn", x: 0.20, y: 0.84, isLocked: false),
        
        // ZON 2: Äng & Skog
        Level(number: 4, name: "Lövskogen", x: 0.40, y: 0.78, isLocked: true),
        Level(number: 5, name: "Öppna Landskap", x: 0.70, y: 0.72, isLocked: true),
        Level(number: 6, name: "Barrskogen", x: 0.50, y: 0.65, isLocked: true),
        
        // ZON 3: Vatten & Vass
        Level(number: 7, name: "Sjön", x: 0.35, y: 0.58, isLocked: true),
        Level(number: 8, name: "Vassen", x: 0.55, y: 0.52, isLocked: true),
        
        // ZON 4: Kust & Klippor
        Level(number: 9, name: "Kusten", x: 0.75, y: 0.45, isLocked: true),
        Level(number: 10, name: "Klipporna", x: 0.55, y: 0.38, isLocked: true),
        
        // ZON 5: Specialisterna & Natten
        Level(number: 11, name: "Rovfåglar", x: 0.35, y: 0.30, isLocked: true),
        Level(number: 12, name: "Nattens ljud", x: 0.60, y: 0.22, isLocked: true),
        
        // ZON 6: Fjäll & Examen (Längst upp)
        Level(number: 13, name: "Fjällen", x: 0.40, y: 0.12, isLocked: true),
        Level(number: 14, name: "Toppen", x: 0.65, y: 0.05, isLocked: true)
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        
                        // 1. Bakgrundskartan
                        Image("learningMap")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width)
                        
                        // 2. Nivå-knapparna
                        ForEach(levels) { level in
                            LevelButton(level: level)
                                .position(
                                    x: level.x * geometry.size.width,
                                    y: level.y * (geometry.size.width * 3) // Anpassat för 1:3 format
                                )
                                // Lägg till en NavigationLink här senare!
                                .onTapGesture {
                                    if !level.isLocked {
                                        print("Startar nivå \(level.name)")
                                    }
                                }
                        }
                    }
                }
                .ignoresSafeArea() // TAR BORT VITA FÄLTET I TOPPEN!
                .defaultScrollAnchor(.bottom)
            }
        }
    }
}

// Uppdaterad knapp-design
struct LevelButton: View {
    let level: Level
    
    var body: some View {
        VStack(spacing: 2) { // Tajtare avstånd mellan knapp och text
            ZStack {
                // Cirkelns bakgrund
                Circle()
                    .fill(level.isLocked ? Color.gray.opacity(0.7) : Color(red: 0.96, green: 0.89, blue: 0.76))
                    .frame(width: 35, height: 35) // Lite mindre, elegantare
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.36, green: 0.25, blue: 0.20), lineWidth: 2)
                    )
                
                // Innehåll (Lås eller Siffra)
                if level.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("\(level.number)")
                        .font(.custom("AmericanTypewriter-Bold", size: 18)) // RÄTT FONT!
                        .foregroundColor(Color(red: 0.36, green: 0.25, blue: 0.20))
                }
            }
            
            // Textskylt (Snyggare!)
            Text(level.name)
                .font(.custom("AmericanTypewriter", size: 11)) // RÄTT FONT!
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(red: 0.36, green: 0.25, blue: 0.20).opacity(0.9)) // Mörkbrun bakgrund
                )
                .foregroundColor(Color(red: 0.96, green: 0.89, blue: 0.76)) // Beige text
                .shadow(radius: 2)
        }
    }
}

#Preview {
    LearningPathView()
}
