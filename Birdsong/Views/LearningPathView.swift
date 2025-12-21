import SwiftUI

struct MapLocation: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
}

struct LearningPathView: View {
    @EnvironmentObject var store: BirdStore
    @AppStorage("highestUnlockedLevel") private var unlockedLevel = 1
    
    let locations: [MapLocation] = [
        MapLocation(id: 1, x: 0.35, y: 0.99), // Start
        MapLocation(id: 2, x: 0.39, y: 0.92), // Trädgården
        MapLocation(id: 3, x: 0.80, y: 0.87), // Byn
        MapLocation(id: 4, x: 0.40, y: 0.78), // Ängen
        MapLocation(id: 5, x: 0.70, y: 0.72), // Öppna Landskap
        MapLocation(id: 6, x: 0.74, y: 0.63), // Gläntan
        MapLocation(id: 7, x: 0.30, y: 0.58), // Lövskogen
        MapLocation(id: 8, x: 0.75, y: 0.45), // Granskogen
        MapLocation(id: 9, x: 0.25, y: 0.42), // Strandängen
        MapLocation(id: 10, x: 0.55, y: 0.34), // Vassen
        MapLocation(id: 11, x: 0.84, y: 0.25), // Rovfåglar
        MapLocation(id: 12, x: 0.39, y: 0.27), // Kusten
        MapLocation(id: 13, x: 0.40, y: 0.12), // Fjällen
        MapLocation(id: 14, x: 0.58, y: 0.18), // Nattens ljud
        MapLocation(id: 15, x: 0.65, y: 0.05)  // Nästa nivå
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        Image("learningMap").resizable().scaledToFit().frame(width: geometry.size.width)
                        
                        ForEach(locations) { loc in
                            if let levelData = LevelData.shared.getLevel(id: loc.id) {
                                let isLocked = loc.id > unlockedLevel
                                
                                // Calculate Status
                                let birds = LevelData.shared.getBirdsForLevel(id: loc.id, allBirds: store.birds)
                                let birdIds = birds.map { $0.id }
                                let hasSilver = QuizPersistence.shared.hasSilver(birdIds: birdIds)
                                let hasGold = QuizPersistence.shared.hasGold(birdIds: birdIds)
                                
                                NavigationLink(destination: QuizView(level: levelData)) {
                                    LevelButton(
                                        number: levelData.id,
                                        name: levelData.title,
                                        isLocked: isLocked,
                                        hasSilver: hasSilver,
                                        hasGold: hasGold
                                    )
                                }
                                .position(x: loc.x * geometry.size.width, y: loc.y * (geometry.size.width * 3))
                                .disabled(isLocked)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .defaultScrollAnchor(.bottom)
            }
        }
    }
}

// Ensure this Struct matches the arguments passed above!
struct LevelButton: View {
    let number: Int
    let name: String
    let isLocked: Bool
    let hasSilver: Bool
    let hasGold: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(buttonColor)
                    .frame(width: 35, height: 35)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    .overlay(Circle().stroke(borderColor, lineWidth: 2))
                
                if isLocked {
                    Image(systemName: "lock.fill").font(.caption).foregroundColor(.white.opacity(0.8))
                } else if hasGold {
                    Image(systemName: "star.fill").font(.caption).foregroundColor(.white)
                } else if hasSilver {
                    Text("Ljud").font(.caption2).bold().foregroundColor(.white)
                } else {
                    Text("\(number)").font(.custom("AmericanTypewriter-Bold", size: 18)).foregroundColor(Color(red: 0.36, green: 0.25, blue: 0.20))
                }
            }
            
            Text(name)
                .font(.custom("AmericanTypewriter", size: 11))
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(red: 0.36, green: 0.25, blue: 0.20).opacity(0.9)))
                .foregroundColor(Color(red: 0.96, green: 0.89, blue: 0.76))
                .shadow(radius: 2)
        }
    }
    
    var buttonColor: Color {
        if isLocked { return Color.gray.opacity(0.7) }
        if hasGold { return Color.yellow }
        if hasSilver { return Color.gray }
        return Color(red: 0.96, green: 0.89, blue: 0.76)
    }
    
    var borderColor: Color {
        if hasGold { return .orange }
        return Color(red: 0.36, green: 0.25, blue: 0.20)
    }
}
