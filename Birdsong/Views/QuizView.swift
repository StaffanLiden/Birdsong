import SwiftUI
import Combine
import AVFoundation

struct QuizView: View {
    @EnvironmentObject var store: BirdStore
    @Environment(\.dismiss) private var dismiss
    
    // Default to image mode, but will be re-configured in startQuiz
    @StateObject private var quizManager = QuizManager(birds: [], mode: .image)
    @State private var player: AVAudioPlayer?
    @State private var showHelp = false
    
    // The specific level to play (if coming from Map). Nil = Free Play.
    var level: GameLevel? = nil
    
    // --- FREE PLAY SETTINGS ---
    @State private var selectedLevelId: Int = 0 // 0 = "Alla"
    @State private var selectedBroadCategory: String = "Alla"
    @State private var switchVisuals: Bool = true
    @State private var switchComplexity: Bool = false
    
    // Helper for Picker
    var categoryOptions: [String] {
        let categories = store.birds.map { $0.broadCategory }
        let unique = Array(Set(categories)).sorted()
        return ["Alla"] + unique
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.vintagePaper.ignoresSafeArea()
                
                VStack {
                    if quizManager.isGameOver {
                        gameOverView
                    } else if quizManager.currentQuestion == nil {
                        // Choose between Map Level Start or Free Play Dashboard
                        if level != nil {
                            levelStartView
                        } else {
                            freePlayStartView
                        }
                    } else {
                        activeGameView
                    }
                }
            }
            .toolbarBackground(Color.vintagePaper, for: .navigationBar)
            .toolbar {
                // "Avsluta" Button
                if quizManager.currentQuestion != nil && !quizManager.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Avsluta") { quizManager.quitSession() }
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.vintageInk)
                    }
                }
                // Help Button
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
            if level != nil { startQuiz() }
        }
        .onDisappear { player?.stop() }
        .onChange(of: quizManager.isGameOver) { _, newValue in
            if newValue {
                player?.stop()
                checkUnlocks()
            }
        }
    }
    
    // MARK: - VIEWS
    
    // --- 1. CLEAN FREE PLAY DASHBOARD ---
    var freePlayStartView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Header Icon
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 60))
                .foregroundStyle(Color.vintageAccent)
                .padding(.bottom, 10)
            
            Text("Fri Träning")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(.vintageInk)
            
            Text("Skräddarsy din övning")
                .font(.subheadline)
                .italic()
                .foregroundColor(.vintageInk.opacity(0.6))
            
            // CONTROLS CONTAINER
            VStack(spacing: 24) {
                
                // A. FILTERS
                VStack(spacing: 12) {
                    Text("FILTRERA")
                        .font(.caption).bold().foregroundColor(.vintageInk.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Area Picker
                    HStack {
                        Text("Område")
                            .foregroundColor(.vintageInk)
                        Spacer()
                        Picker("Område", selection: $selectedLevelId) {
                            Text("Alla").tag(0)
                            ForEach(LevelData.shared.levels.filter { $0.id != 15 }) { lvl in
                                Text(lvl.title).tag(lvl.id)
                            }
                        }
                        .tint(.vintageAccent)
                        .pickerStyle(.menu)
                    }
                    
                    Divider()
                    
                    // Category Picker
                    HStack {
                        Text("Familj")
                            .foregroundColor(.vintageInk)
                        Spacer()
                        Picker("Familj", selection: $selectedBroadCategory) {
                            Text("Alla").tag("Alla")
                            ForEach(categoryOptions, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .tint(.vintageAccent)
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
                
                // B. SETTINGS
                VStack(spacing: 12) {
                    Text("INSTÄLLNINGAR")
                        .font(.caption).bold().foregroundColor(.vintageInk.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Visuals Toggle
                    Toggle(isOn: $switchVisuals) {
                        Text("Visa Bilder")
                            .foregroundColor(.vintageInk)
                    }
                    .tint(.vintageAccent)
                    
                    Divider()
                    
                    // Difficulty Toggle
                    Toggle(isOn: $switchComplexity) {
                        VStack(alignment: .leading) {
                            Text("Svårare Alternativ")
                                .foregroundColor(.vintageInk)
                            Text(switchComplexity ? "Visar arter från samma familj" : "Visar slumpmässiga arter")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.vintageAccent)
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // START BUTTON
            Button(action: startQuiz) {
                Text("STARTA ÖVNING")
                    .font(.system(.title3, design: .serif))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.vintageLeather)
                    .cornerRadius(8)
                    .shadow(radius: 2, y: 2)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // --- 2. LEVEL START VIEW (Map Mode) ---
    var levelStartView: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: "music.mic.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.vintageAccent)
            
            VStack(spacing: 8) {
                Text(level?.title ?? "Nivå")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                
                if let level = level {
                    let birdIds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds).map { $0.id }
                    if QuizPersistence.shared.hasSilver(birdIds: birdIds) {
                        Text("🥇 Guldjakt (Endast Ljud)")
                            .font(.headline)
                            .foregroundColor(.orange)
                    } else {
                        Text("🥈 Silverjakt (Bild & Ljud)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
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
    
    // --- 3. ACTIVE QUIZ VIEW ---
    var activeGameView: some View {
        VStack(spacing: 0) {
            
            // Header
            if level != nil {
                // Map Mode Header
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
                HStack {
                    Image(systemName: quizManager.mode == .image ? "eye.fill" : "ear.fill")
                    Text(quizManager.mode == .image ? "Visuell Träning" : "Ljudträning")
                }
                .font(.caption).bold().foregroundColor(.vintageInk.opacity(0.4))
                .padding(.top, 10)
            }
            
            Spacer()
            
            // Image (If Mode is Image)
            if quizManager.mode == .image, let bird = quizManager.currentQuestion?.correctBird {
                VintagePhotoFrame(image: safeImage(for: bird))
                    .padding(.horizontal, 25)
                    .rotationEffect(.degrees(-2))
                    .layoutPriority(1)
            } else {
                // Audio Placeholder
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
            
            // Play Sound Button
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
            
            // Options
            if let question = quizManager.currentQuestion {
                VStack(spacing: 12) {
                    ForEach(question.options) { bird in
                        ZStack(alignment: .trailing) {
                            VintageOptionButton(
                                text: bird.swedishName,
                                state: buttonState(for: bird),
                                action: { quizManager.submitAnswer(bird) }
                            )
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
    
    // --- 4. GAME OVER VIEW ---
    var gameOverView: some View {
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
                if isLevelMode {
                    Text("Dina framsteg")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk.opacity(0.6))
                    Text("\(masteredCount) / 10")
                        .font(.system(size: 60, weight: .bold, design: .serif))
                        .foregroundColor(.vintageAccent)
                    Divider().padding()
                    
                    if silver && !gold {
                        Text("🥈 SILVER UPPNÅTT!")
                            .font(.title3).bold().foregroundColor(.gray)
                        Text("Nu startar guldjakten (endast ljud)!")
                            .font(.caption).italic().foregroundColor(.orange)
                    } else if gold {
                        Text("🥇 GULD UPPNÅTT!")
                            .font(.title2).bold().foregroundColor(.yellow)
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
                        Text(lvl.title).font(.headline)
                    } else {
                        Text("Alla områden").font(.headline)
                    }
                    Text(selectedBroadCategory).font(.headline)
                }
            }
            .padding(40)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            
            Spacer()
            
            Button("Spela igen") { startQuiz() }
                .buttonStyle(.borderedProminent)
                .tint(Color.vintageAccent)
            
            Button(isLevelMode ? "Tillbaks till kartan" : "Avsluta") {
                if isLevelMode {
                    dismiss()
                } else {
                    quizManager.isGameOver = false
                    quizManager.currentQuestion = nil
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - LOGIC
    
    func startQuiz() {
        if let level = level {
            // MAP MODE
            let birds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds)
            let birdIds = birds.map { $0.id }
            let hasSilver = QuizPersistence.shared.hasSilver(birdIds: birdIds)
            
            quizManager.isFreePlay = false
            quizManager.useImages = !hasSilver
            quizManager.useSimilarSpecies = false
            quizManager.mode = hasSilver ? .audio : .image
            
            quizManager.setBirds(birds)
            quizManager.startQuiz()
        } else {
            // FREE PLAY MODE
            var filtered = store.birds
            
            // 1. Filter by Level
            if selectedLevelId != 0 {
                filtered = LevelData.shared.getBirdsForLevel(id: selectedLevelId, allBirds: store.birds)
            }
            
            // 2. Filter by Category
            if selectedBroadCategory != "Alla" {
                filtered = filtered.filter { $0.broadCategory == selectedBroadCategory }
            }
            
            if filtered.isEmpty { filtered = store.birds }
            
            quizManager.isFreePlay = true
            quizManager.useImages = switchVisuals
            quizManager.useSimilarSpecies = switchComplexity
            quizManager.mode = switchVisuals ? .image : .audio
            
            quizManager.setBirds(filtered)
            quizManager.startQuiz()
        }
    }
    
    // MARK: - HELPERS (Standard)
    
    func checkUnlocks() {
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

// Progress Bar Helper (Unchanged)
struct MasteryProgressBar: View {
    let total: Int
    let current: Int
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.vintageInk.opacity(0.1))
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
