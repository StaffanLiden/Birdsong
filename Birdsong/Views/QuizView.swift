import SwiftUI
import Combine
import AVFoundation

struct QuizView: View {
    @EnvironmentObject var store: BirdStore
    @Environment(\.dismiss) private var dismiss
    
    // Default to image mode, updated in startQuiz
    @StateObject private var quizManager = QuizManager(birds: [], mode: .image)
    @State private var player: AVAudioPlayer?
    @State private var showHelp = false
    
    var level: GameLevel? = nil
    
    // FILTERS for Free Play
    // 0 = "Alla" for levels
    @State private var selectedLevelId: Int = 0
    @State private var selectedBroadCategory: String = "Alla"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.87, green: 0.81, blue: 0.68).ignoresSafeArea()
                
                VStack {
                    if quizManager.isGameOver {
                        gameOverView
                    } else if quizManager.currentQuestion == nil {
                        startView
                    } else {
                        activeGameView
                    }
                }
            }
            .toolbarBackground(Color.vintagePaper, for: .navigationBar)
            .toolbar {
                // Toolbar: "Avsluta" (Quit Session)
                if quizManager.currentQuestion != nil && !quizManager.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Avsluta") { quizManager.quitSession() }
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.vintageInk)
                    }
                }
                // Toolbar: Help
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showHelp = true }) {
                        Image(systemName: "info.circle").foregroundColor(.vintageInk)
                    }
                }
            }
            .sheet(isPresented: $showHelp) { HelpView() }
        }
        .onAppear {
            player?.stop()
            // If a specific level is passed, start immediately (skip filters)
            if level != nil { startQuiz() }
        }
        .onDisappear { player?.stop() }
        .onChange(of: quizManager.isGameOver) { _, newValue in
            if newValue {
                player?.stop()
                checkUnlocks() // Check unlocks only if in Level mode
            }
        }
    }
    
    // --- START VIEW (Free Play Filters) ---
    var startView: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "music.mic.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.vintageAccent)
            
            VStack(spacing: 8) {
                Text(level?.title ?? "Fri Träning")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                
                if let level = level {
                    // LEVEL MODE: Show Status
                    let birdIds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds).map { $0.id }
                    if QuizPersistence.shared.hasSilver(birdIds: birdIds) {
                        Text("🥇 Guldjakt (Endast Ljud)")
                            .font(.headline).foregroundColor(.orange)
                    } else {
                        Text("🥈 Silverjakt (Bild & Ljud)")
                            .font(.headline).foregroundColor(.gray)
                    }
                } else {
                    // FREE PLAY: Show Filters
                    VStack(spacing: 16) {
                        Text("Välj vilka fåglar du vill öva på:")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.vintageInk)
                        
                        // Filter 1: Area (GameLevel)
                        HStack {
                            Text("Område:")
                            Picker("Område", selection: $selectedLevelId) {
                                Text("Alla").tag(0)
                                // Filter out ID 15 ("Next Level") as it has no birds
                                ForEach(LevelData.shared.levels.filter { $0.id != 15 }) { lvl in
                                    Text(lvl.title).tag(lvl.id)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(8)
                        
                        // Filter 2: Category (BroadCategory)
                        HStack {
                            Text("Kategori:")
                            Picker("Kategori", selection: $selectedBroadCategory) {
                                Text("Alla").tag("Alla")
                                ForEach(uniqueBroadCategories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            Button(action: startQuiz) {
                Text("STARTA")
                    .font(.system(.title3, design: .serif))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.vintageLeather)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // --- ACTIVE GAME VIEW ---
    var activeGameView: some View {
        VStack(spacing: 0) {
            
            // 1. Mastery Progress Bar (ONLY IN LEVEL MODE)
            if let level = level {
                VStack(spacing: 4) {
                    HStack {
                        Text(quizManager.mode == .image ? "👁️ Visuell Träning" : "👂 Ljudträning")
                            .font(.caption).bold().foregroundColor(.vintageInk.opacity(0.6))
                        Spacer()
                        Text("Bemästrade: \(countMasteredInCurrentMode()) / 10")
                            .font(.caption).bold().foregroundColor(.vintageAccent)
                    }
                    .padding(.horizontal, 20)
                    
                    MasteryProgressBar(
                        total: 10,
                        current: countMasteredInCurrentMode()
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
            } else {
                // Free Play Header
                Text(quizManager.mode == .image ? "Visuell Träning" : "Ljudträning")
                    .font(.caption).bold().foregroundColor(.vintageInk.opacity(0.4))
                    .padding(.top, 10)
            }
            
            // 2. The Question Image (Only if Visual Mode)
            Spacer()
            
            if quizManager.mode == .image, let bird = quizManager.currentQuestion?.correctBird {
                VintagePhotoFrame(image: safeImage(for: bird))
                    .padding(.horizontal, 25)
                    .rotationEffect(.degrees(-2))
                    .layoutPriority(1)
            } else {
                // Audio Only Mode Placeholder
                VStack(spacing: 20) {
                    Image(systemName: "music.quarternote.3")
                        .font(.system(size: 80))
                        .foregroundColor(.vintageInk.opacity(0.2))
                    Text("Lyssna noga...")
                        .font(.system(.title3, design: .serif))
                        .italic()
                        .foregroundColor(.vintageInk.opacity(0.5))
                }
                .frame(height: 200)
            }
            
            Spacer()
            
            // 3. Audio Player
            Button { playCurrentQuestionAudio() } label: {
                ZStack {
                    Circle()
                        .fill(Color.vintagePaper)
                        .frame(width: 90, height: 90)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 4, y: 4)
                        .overlay(Circle().stroke(Color.vintageInk.opacity(0.1), lineWidth: 1))
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.vintageAccent)
                }
            }
            .padding(.vertical, 10)
            
            // 4. Options
            if let question = quizManager.currentQuestion {
                VStack(spacing: 12) {
                    ForEach(question.options) { bird in
                        ZStack(alignment: .trailing) {
                            VintageOptionButton(
                                text: bird.swedishName,
                                state: buttonState(for: bird),
                                action: { quizManager.submitAnswer(bird) }
                            )
                            
                            // Show progress dots even in free play?
                            // Yes, useful feedback.
                            streakDots(for: bird)
                                .padding(.trailing, 16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.bottom, 90)
        .onChange(of: quizManager.currentQuestion?.id) { _, newValue in
            if newValue != nil { playCurrentQuestionAudio() }
        }
    }
    
    // --- GAME OVER VIEW ---
    var gameOverView: some View {
        // Prepare Level Data (only if level exists)
        let isLevelMode = (level != nil)
        let birdIds = getBirdIds()
        let silver = isLevelMode ? QuizPersistence.shared.hasSilver(birdIds: birdIds) : false
        let gold = isLevelMode ? QuizPersistence.shared.hasGold(birdIds: birdIds) : false
        let masteredCount = countMasteredInCurrentMode()
        
        return VStack(spacing: 30) {
            Spacer()
            Text("Omgång Avslutad")
                .font(.system(.largeTitle, design: .serif))
                .bold()
                .foregroundStyle(Color.vintageInk)
            
            VStack(spacing: 10) {
                // Different Summary for Level vs Free Play
                if let _ = level {
                    Text("Dina framsteg")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk.opacity(0.6))
                    
                    Text("\(masteredCount) / 10")
                        .font(.system(size: 60, weight: .bold, design: .serif))
                        .foregroundColor(.vintageAccent)
                    
                    Text("Bemästrade arter")
                        .font(.caption)
                        .foregroundColor(.vintageInk)
                    
                    Divider().padding()
                    
                    if silver && !gold {
                        Text("🥈 SILVER UPPNÅTT!")
                            .font(.title3).bold().foregroundColor(.gray)
                        Text("Nästa nivå är upplåst.")
                            .font(.caption)
                        Text("Nu startar guldjakten (endast ljud)!")
                            .font(.caption).italic().foregroundColor(.orange)
                    } else if gold {
                        Text("🥇 GULD UPPNÅTT!")
                            .font(.title2).bold().foregroundColor(.yellow)
                        Text("Du är en mästare på denna nivå.")
                            .font(.caption)
                    } else {
                        Text("Du behöver 7 för att nå Silver.")
                            .font(.body).foregroundColor(.red)
                    }
                } else {
                    // FREE PLAY SUMMARY
                    Text("Bra jobbat!")
                        .font(.title2).bold()
                        .foregroundColor(.vintageAccent)
                    
                    Text("Du har tränat på:")
                        .font(.caption)
                        .foregroundColor(.vintageInk)
                    
                    if selectedLevelId != 0, let lvl = LevelData.shared.getLevel(id: selectedLevelId) {
                        Text(lvl.title)
                            .font(.headline)
                    } else {
                        Text("Alla områden")
                            .font(.headline)
                    }
                    
                    Text(selectedBroadCategory)
                        .font(.headline)
                }
            }
            .padding(40)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            
            Spacer()
            
            // Buttons
            Button("Spela igen") {
                startQuiz()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.vintageAccent)
            
            // "Avsluta" or "Tillbaks till kartan"
            Button(isLevelMode ? "Tillbaks till kartan" : "Avsluta") {
                if isLevelMode {
                    dismiss()
                } else {
                    // LINK: Reset to StartView (Filters)
                    quizManager.isGameOver = false
                    quizManager.currentQuestion = nil
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
    }
    
    // --- HELPERS ---
    
    // Helper to get unique broad categories
    var uniqueBroadCategories: [String] {
        let items = store.birds.map { $0.broadCategory }
        return Array(Set(items)).sorted()
    }
    
    func startQuiz() {
        if let level = level {
            // --- LEVEL MODE ---
            let birds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds)
            let birdIds = birds.map { $0.id }
            
            // Auto-detect mode based on Silver status
            let hasSilver = QuizPersistence.shared.hasSilver(birdIds: birdIds)
            quizManager.mode = hasSilver ? .audio : .image
            
            quizManager.isFreePlay = false // Ensure it's Level Mode
            quizManager.setBirds(birds)
            quizManager.startQuiz()
            
        } else {
            // --- FREE PLAY MODE (Apply Filters) ---
            var filtered = store.birds
            
            // 1. Filter by Map Area (GameLevel)
            if selectedLevelId != 0 {
                filtered = LevelData.shared.getBirdsForLevel(id: selectedLevelId, allBirds: store.birds)
            }
            
            // 2. Filter by Broad Category
            if selectedBroadCategory != "Alla" {
                filtered = filtered.filter { $0.broadCategory == selectedBroadCategory }
            }
            
            // Handle case where filters result in 0 birds (prevent crash)
            if filtered.isEmpty {
                // Fallback: Just take all birds if filter is too strict
                print("Warning: Filters resulted in 0 birds. Resetting to all.")
                filtered = store.birds
            }
            
            // Default to Image mode for Free Play
            quizManager.mode = .image
            quizManager.isFreePlay = true // Enable Free Play Mode
            quizManager.setBirds(filtered)
            quizManager.startQuiz()
        }
    }
    
    func checkUnlocks() {
        // Only unlock levels if we are actually playing a level
        guard let level = level else { return }
        let birdIds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds).map { $0.id }
        
        if QuizPersistence.shared.hasSilver(birdIds: birdIds) {
            QuizPersistence.shared.unlockNextLevel(currentLevel: level.id)
        }
    }
    
    func countMasteredInCurrentMode() -> Int {
        guard let level = level else { return 0 }
        let birdIds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds).map { $0.id }
        return QuizPersistence.shared.countMastered(birdIds: birdIds, mode: quizManager.mode)
    }
    
    func getBirdIds() -> [String] {
        guard let level = level else { return [] }
        return LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds).map { $0.id }
    }
    
    // ... UI Helpers (SafeImage, streakDots, etc) ...
    
    func safeImage(for bird: Bird) -> Image {
        if let imageName = bird.imageName, let uiImage = UIImage(named: imageName) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "bird.fill")
    }
    
    func buttonState(for bird: Bird) -> VintageOptionButton.ButtonState {
        guard let selected = quizManager.selectedBird else { return .neutral }
        if bird.id == quizManager.currentQuestion?.correctBird.id { return .correct }
        if bird.id == selected.id { return .wrong }
        return .disabled
    }
    
    func playCurrentQuestionAudio() {
        player?.stop()
        guard let question = quizManager.currentQuestion,
              let clip = question.correctBird.audioClips.first else { return }
        let name = (clip.fileName as NSString).deletingPathExtension
        let ext = (clip.fileName as NSString).pathExtension
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
        }
    }
    
    func streakDots(for bird: Bird) -> some View {
        let streak = QuizPersistence.shared.getStreak(for: bird.id, mode: quizManager.mode)
        return HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .strokeBorder(Color.vintageInk.opacity(0.3), lineWidth: 1)
                    .background(Circle().fill(index < streak ? Color.vintageAccent : Color.clear))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// Progress Bar Helper
struct MasteryProgressBar: View {
    let total: Int
    let current: Int
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.vintageInk.opacity(0.1))
                // Target line at 70%
                Rectangle()
                    .fill(Color.vintageInk.opacity(0.3))
                    .frame(width: 2, height: geo.size.height)
                    .offset(x: geo.size.width * 0.7)
                
                Capsule()
                    .fill(current >= 7 ? Color.vintageAccent : Color(red: 0.85, green: 0.6, blue: 0.4))
                    .frame(width: max(0, geo.size.width * (Double(current) / Double(total))))
                    .animation(.spring(), value: current)
            }
        }
        .frame(height: 12)
    }
}
