import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: BirdStore
    
    // Data variabler
    @State private var birdsByLevel: [Int: [Bird]] = [:]
    @State private var statsByCategory: [String: (total: Int, learned: Int)] = [:]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. BAKGRUND
                Color.vintagePaper.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // --- TOTAL CIRKEL ---
                        VStack(spacing: 10) {
                            ZStack {
                                // Bakgrundsring (svag)
                                Circle()
                                    .stroke(Color.vintageInk.opacity(0.1), lineWidth: 15)
                                
                                // Framstegsring
                                Circle()
                                    .trim(from: 0.0, to: totalProgress)
                                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                    .foregroundColor(.vintageAccent)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeOut, value: totalProgress)
                                
                                VStack {
                                    Text(String(format: "%.0f%%", totalProgress * 100))
                                        .font(.system(size: 44, weight: .bold, design: .serif))
                                        .foregroundColor(.vintageInk)
                                    Text("Avklarade")
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
                        
                        // --- SEKTION 1: PER KATEGORI (NY!) ---
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Framsteg per Familj")
                                .font(.system(.title2, design: .serif))
                                .bold()
                                .foregroundColor(.vintageLeather)
                                .padding(.bottom, 4)
                            
                            // Vi loopar igenom kategorierna (sorterade)
                            ForEach(statsByCategory.keys.sorted(), id: \.self) { category in
                                if let stat = statsByCategory[category], stat.total > 0 {
                                    CategoryProgressRow(category: category, learned: stat.learned, total: stat.total)
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.4)) // Ljusare platta
                        .cornerRadius(4)
                        .padding(.horizontal)
                        
                        // --- SEKTION 2: JOURNAL (Nivåer) ---
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Journal")
                                .font(.system(.title2, design: .serif))
                                .bold()
                                .foregroundColor(.vintageLeather)
                            
                            // Nivå 3
                            JournalSection(
                                title: "Mästerlig (Klar)",
                                icon: "star.fill",
                                color: .vintageAccent,
                                birds: birdsByLevel[3] ?? []
                            )
                            
                            // Nivå 2
                            JournalSection(
                                title: "På god väg (2 rätt)",
                                icon: "circle.circle.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 0.4), // Senapsgul
                                birds: birdsByLevel[2] ?? []
                            )
                            
                            // Nivå 1
                            JournalSection(
                                title: "Nybörjare (1 rätt)",
                                icon: "circle.fill",
                                color: Color(red: 0.85, green: 0.6, blue: 0.4), // Orange
                                birds: birdsByLevel[1] ?? []
                            )
                            
                            // Nivå 0
                            JournalSection(
                                title: "Olärt / 0 streak",
                                icon: "circle",
                                color: .vintageInk.opacity(0.3),
                                birds: birdsByLevel[0] ?? []
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Min Loggbok")
            .toolbarBackground(Color.vintagePaper, for: .navigationBar)
            .onAppear {
                calculateStats()
            }
        }
    }
    
    // --- LOGIK ---
    var totalProgress: Double {
        let learnedCount = Double(birdsByLevel[3]?.count ?? 0)
        let total = Double(store.birds.count)
        guard total > 0 else { return 0 }
        return learnedCount / total
    }
    
    func calculateStats() {
        // 1. Nivåer
        var newMap: [Int: [Bird]] = [0: [], 1: [], 2: [], 3: []]
        for bird in store.birds {
            let streak = QuizPersistence.shared.getStreak(for: bird.id)
            let level = min(streak, 3)
            newMap[level]?.append(bird)
        }
        self.birdsByLevel = newMap
        
        // 2. Kategorier
        var newCatStats: [String: (total: Int, learned: Int)] = [:]
        let allCategories = Set(store.birds.map { $0.broadCategory })
        
        for cat in allCategories {
            let birdsInCat = store.birds.filter { $0.broadCategory == cat }
            let total = birdsInCat.count
            // Räknar "lärd" som streak >= 3
            let learned = birdsInCat.filter { QuizPersistence.shared.getStreak(for: $0.id) >= 3 }.count
            newCatStats[cat] = (total: total, learned: learned)
        }
        self.statsByCategory = newCatStats
    }
}

// --- KOMPONENT: Kategori-rad ---
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

// --- KOMPONENT: Journal-sektion ---
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
                        Text("Inga noteringar.")
                            .font(.system(.caption, design: .serif))
                            .italic()
                            .foregroundColor(.vintageInk.opacity(0.5))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(birds) { bird in
                            HStack {
                                Text(bird.swedishName)
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(.vintageInk)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.3))
                            
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
