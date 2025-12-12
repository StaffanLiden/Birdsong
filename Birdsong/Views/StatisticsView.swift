import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: BirdStore
    
    // Data variables
    // Vi sorterar fortfarande huvudlistorna baserat på Ljud-kunskap (Level 0-3)
    @State private var birdsByAudioLevel: [Int: [Bird]] = [:]
    @State private var statsByCategory: [String: (total: Int, learned: Int)] = [:]
    
    var body: some View {
        ScrollView {
            // --- EGEN RUBRIK ---
            Text("Min Loggbok")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundColor(.vintageInk)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            VStack(spacing: 30) {
                
                // --- TOTAL CIRCLE (Ljudfokus) ---
                VStack(spacing: 10) {
                    ZStack {
                        // Background ring
                        Circle()
                            .stroke(Color.vintageInk.opacity(0.1), lineWidth: 15)
                        
                        // Progress ring
                        Circle()
                            .trim(from: 0.0, to: totalAudioProgress)
                            .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .foregroundColor(.vintageAccent)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut, value: totalAudioProgress)
                        
                        VStack {
                            Text(String(format: "%.0f%%", totalAudioProgress * 100))
                                .font(.system(size: 44, weight: .bold, design: .serif))
                                .foregroundColor(.vintageInk)
                            Text("Ljud lärts in")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(.vintageInk.opacity(0.6))
                        }
                    }
                    .frame(width: 180, height: 180)
                    .padding(.top, 20)
                    
                    Text("Totalt \(store.birds.count) arter i databasen")
                        .font(.system(.body, design: .serif))
                        .italic()
                        .foregroundColor(.vintageInk.opacity(0.6))
                }
                
                // --- SECTION 1: PER CATEGORY ---
                VStack(alignment: .leading, spacing: 16) {
                    Text("Framsteg per Grupp (Ljud)")
                        .font(.system(.title2, design: .serif))
                        .bold()
                        .foregroundColor(.vintageLeather)
                        .padding(.bottom, 4)
                    
                    ForEach(statsByCategory.keys.sorted(), id: \.self) { category in
                        if let stat = statsByCategory[category], stat.total > 0 {
                            CategoryProgressRow(category: category, learned: stat.learned, total: stat.total)
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.4))
                .cornerRadius(4)
                .padding(.horizontal)
                
                // --- SECTION 2: JOURNAL (Levels) ---
                VStack(alignment: .leading, spacing: 16) {
                    Text("Journal")
                        .font(.system(.title2, design: .serif))
                        .bold()
                        .foregroundColor(.vintageLeather)
                    
                    // Level 3 (Mästerlig på ljud)
                    JournalSection(
                        title: "Mästerlig (Ljud)",
                        icon: "star.fill",
                        color: .vintageAccent,
                        birds: birdsByAudioLevel[3] ?? []
                    )
                    
                    // Level 2
                    JournalSection(
                        title: "På god väg (2 rätt)",
                        icon: "circle.circle.fill",
                        color: Color(red: 0.8, green: 0.7, blue: 0.4), // Mustard yellow
                        birds: birdsByAudioLevel[2] ?? []
                    )
                    
                    // Level 1
                    JournalSection(
                        title: "Nybörjare (1 rätt)",
                        icon: "circle.fill",
                        color: Color(red: 0.85, green: 0.6, blue: 0.4), // Orange
                        birds: birdsByAudioLevel[1] ?? []
                    )
                    
                    // Level 0
                    JournalSection(
                        title: "Olärt / 0 streak",
                        icon: "circle",
                        color: .vintageInk.opacity(0.3),
                        birds: birdsByAudioLevel[0] ?? []
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.87, green: 0.81, blue: 0.68).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            calculateStats()
        }
    }
    
    // --- LOGIC ---
    var totalAudioProgress: Double {
        let learnedCount = Double(birdsByAudioLevel[3]?.count ?? 0)
        let total = Double(store.birds.count)
        guard total > 0 else { return 0 }
        return learnedCount / total
    }
    
    func calculateStats() {
        // 1. Levels (Sortera baserat på Ljud-streak)
        var newMap: [Int: [Bird]] = [0: [], 1: [], 2: [], 3: []]
        for bird in store.birds {
            let streak = QuizPersistence.shared.getStreak(for: bird.id, mode: .audio)
            let level = min(streak, 3)
            newMap[level]?.append(bird)
        }
        self.birdsByAudioLevel = newMap
        
        // 2. Categories
        var newCatStats: [String: (total: Int, learned: Int)] = [:]
        let allCategories = Set(store.birds.map { $0.broadCategory })
        
        for cat in allCategories {
            let birdsInCat = store.birds.filter { $0.broadCategory == cat }
            let total = birdsInCat.count
            let learned = birdsInCat.filter { QuizPersistence.shared.getStreak(for: $0.id, mode: .audio) >= 3 }.count
            newCatStats[cat] = (total: total, learned: learned)
        }
        self.statsByCategory = newCatStats
    }
}

// --- COMPONENT: Category row ---
struct CategoryProgressRow: View {
    let category: String
    let learned: Int
    let total: Int
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(learned) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(category)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.vintageInk)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(.caption, design: .serif))
                    .bold()
                    .foregroundColor(.vintageAccent)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.vintageInk.opacity(0.1))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.vintageAccent)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// --- COMPONENT: Journal section ---
struct JournalSection: View {
    let title: String
    let icon: String
    let color: Color
    let birds: [Bird]
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.vintageInk)
                    
                    Spacer()
                    
                    Text("\(birds.count)")
                        .font(.system(.body, design: .serif))
                        .bold()
                        .foregroundColor(.vintageInk.opacity(0.6))
                        .padding(.trailing, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.vintageInk.opacity(0.4))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 0) {
                    if birds.isEmpty {
                        Text("Inga arter här.")
                            .font(.system(.caption, design: .serif))
                            .italic()
                            .foregroundColor(.vintageInk.opacity(0.5))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        // NYHET: Klickbar rad med ikoner för både ljud och bild
                        ForEach(birds) { bird in
                            NavigationLink(destination: BirdDetailView(bird: bird)) {
                                JournalRow(bird: bird)
                            }
                            .buttonStyle(PlainButtonStyle()) // Tar bort blå länkfärg
                            
                            Divider().background(Color.vintageInk.opacity(0.1))
                        }
                    }
                }
                .padding(.leading, 10)
            }
        }
        .padding(.bottom, 8)
    }
}

// --- KOMPONENT: JournalRow (Nu med färgkodade nivåer) ---
struct JournalRow: View {
    let bird: Bird
    
    // Hämta exakt streak (0, 1, 2, eller 3+)
    var audioStreak: Int {
        QuizPersistence.shared.getStreak(for: bird.id, mode: .audio)
    }
    var imageStreak: Int {
        QuizPersistence.shared.getStreak(for: bird.id, mode: .image)
    }
    
    var body: some View {
        HStack {
            Text(bird.swedishName)
                .font(.system(.body, design: .serif))
                .foregroundColor(.vintageInk)
            
            Spacer()
            
            // Ljud-ikon (färgkodad)
            statusIcon(streak: audioStreak, icon: "music.mic")
            
            // Bild-ikon (färgkodad)
            statusIcon(streak: imageStreak, icon: "photo")
                .padding(.leading, 8)
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.vintageInk.opacity(0.3))
                .padding(.leading, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color.white.opacity(0.3))
    }
    
    func statusIcon(streak: Int, icon: String) -> some View {
            // Bestäm färg baserat på streak
            let color: Color
            switch streak {
            case 3...: color = .vintageAccent                       // Klar (Grön)
            case 2:    color = Color(red: 0.8, green: 0.7, blue: 0.4) // På god väg (Gul/Senap)
            case 1:    color = Color(red: 0.85, green: 0.6, blue: 0.4)// Nybörjare (Orange)
            default:   color = .vintageInk.opacity(0.2)               // Ej startad (Grå)
            }
            
            // Bestäm ikon (fylld om man har minst 1 rätt, annars ofylld)
            let iconName = (streak > 0) ? icon + ".circle.fill" : icon
            
            return Image(systemName: iconName)
                .font(.system(size: 18)) // Lite större fast storlek
                .foregroundColor(color)
                .frame(width: 24, height: 24) // Fast ram så de alltid tar lika stor plats
                // Tog bort .scaleEffect härifrån
        }
}
