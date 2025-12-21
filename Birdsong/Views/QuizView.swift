import SwiftUI
import Combine
import AVFoundation

struct QuizView: View {
    @EnvironmentObject var store: BirdStore
    @StateObject private var quizManager = QuizManager(birds: [], mode: .audio)
    @State private var player: AVAudioPlayer?
    @State private var showHelp = false
    
    // NYTT: Vi kan skicka in en specifik nivå
    var level: GameLevel? = nil
    
    // Filter (Används bara om vi kör "Fritt spel", inte Level-mode)
    @State private var selectedHabitat: String = "Alla"
    let habitats = ["Alla", "Skog", "Hav & Kust", "Äng & Åker", "Fjäll", "Trädgård", "Stad"]
    @State private var selectedCategory: String = "Alla"
    let categories = ["Alla", "Sångfåglar", "Vattenfåglar", "Rovfåglar & Ugglor", "Hackspettar", "Övriga Landfåglar"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.87, green: 0.81, blue: 0.68)
                    .ignoresSafeArea()
                
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
                if quizManager.currentQuestion != nil && !quizManager.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Avsluta") { quizManager.quitSession() }
                            .foregroundColor(.vintageInk)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showHelp = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.vintageInk)
                    }
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            player?.stop()
            // Om vi skickades hit med en nivå, starta direkt!
            if level != nil {
                startQuiz()
            }
        }
        .onDisappear { player?.stop() }
        .onChange(of: quizManager.isGameOver) { _, newValue in
            if newValue {
                player?.stop()
                checkLevelCompletion() // Kolla om vi klarade nivån!
            }
        }
    }
    
    // --- STARTSKÄRM ---
    var startView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "music.mic.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.vintageAccent)
                .shadow(color: .vintageAccent.opacity(0.3), radius: 10)
            
            VStack(spacing: 8) {
                // Visa nivåns namn om vi kör en nivå
                Text(level?.title ?? "Ljudquiz")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                
                Text(level != nil ? "Lyssna och lär!" : "Kan du höra vem det är?")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.7))
            }
            
            // Visa bara filter om vi INTE kör en nivå
            if level == nil {
                VStack(spacing: 16) {
                    filterPicker(title: "Miljö", selection: $selectedHabitat, options: habitats)
                    filterPicker(title: "Kategori", selection: $selectedCategory, options: categories)
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal)
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
                    .shadow(radius: 4, y: 2)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // --- SPELSKÄRM ---
    var activeGameView: some View {
            VStack(spacing: 0) { // Nollställ spacing, vi använder Spacers istället
                
                // 1. Topp-rad med poäng
                HStack {
                    Text("Poäng: \(quizManager.sessionScore)")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(Color.vintageInk)
                    Spacer()
                    if let bird = quizManager.currentQuestion?.correctBird {
                        streakDots(for: bird)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5) // Lite luft under poängen
                
                // 2. Bilden (Om nivå-läge) - NU STOR IGEN!
                if let level = level, level.showVisualAid, let bird = quizManager.currentQuestion?.correctBird {
                    VintagePhotoFrame(image: safeImage(for: bird))
                        // VIKTIGT: Ingen frame(height) här, vi låter den växa!
                        .padding(.horizontal, 25) // Minskad marginal (var 40) -> Större bild
                        .rotationEffect(.degrees(-2))
                        .layoutPriority(1) // Prioritera att ge bilden plats
                }
                
                Spacer() // Trycker isär bild och spelare
                
                // 3. Ljudspelaren (Kompaktare versionen)
                Button {
                    playCurrentQuestionAudio()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.vintagePaper)
                            .frame(width: 90, height: 90) // Fortfarande smidig
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 4, y: 4)
                            .overlay(Circle().stroke(Color.vintageInk.opacity(0.1), lineWidth: 1))
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.vintageAccent)
                    }
                }
                .padding(.vertical, 10) // Lite luft runt knappen
                
                Text("Tryck för att lyssna igen")
                    .font(.system(.caption2, design: .serif))
                    .italic()
                    .foregroundStyle(Color.vintageInk.opacity(0.6))
                    .padding(.bottom, 15)
                
                // 4. Svarsalternativ
                if let question = quizManager.currentQuestion {
                    VStack(spacing: 12) {
                        ForEach(question.options) { bird in
                            VintageOptionButton(
                                text: bird.swedishName,
                                state: buttonState(for: bird),
                                action: { quizManager.submitAnswer(bird) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer() // Balans i botten
            }
            .padding(.bottom, 90) // Håller oss borta från TabBar
            .onChange(of: quizManager.currentQuestion?.id) { _, newValue in
                if newValue != nil { playCurrentQuestionAudio() }
            }
        }
    
    // --- GAME OVER ---
    var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Omgång Avslutad")
                .font(.system(.largeTitle, design: .serif))
                .bold()
                .foregroundStyle(Color.vintageInk)
            
            VStack(spacing: 5) {
                Text("Ditt resultat")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.6))
                Text("\(quizManager.sessionScore) av \(quizManager.questionsAnswered)")
                    .font(.system(size: 50, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageAccent)
                
                // Visa om vi klarade nivån
                if let level = level {
                    if quizManager.sessionScore >= level.requiredScore {
                        Text("Nivå klarad! Nästa upplåst.")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.top, 10)
                    } else {
                        Text("Du behöver \(level.requiredScore) rätt.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
            }
            .padding(40)
            .background(
                Circle()
                    .stroke(Color.vintageInk.opacity(0.1), lineWidth: 2)
                    .background(Circle().fill(Color.white.opacity(0.4)))
            )
            
            Spacer()
            
            Button("Spela igen") { quizManager.startQuiz() }
                .buttonStyle(.borderedProminent)
                .tint(Color.vintageAccent)
            
            // Om vi klarade nivån kan vi gå tillbaka till kartan
            Button("Tillbaks till kartan") {
                // Navigera tillbaka (SwiftUI dismissar automatiskt om man "backar" via nav stack)
                // Men vi nollställer bara state här så får användaren klicka "Back" i toolbaren
                quizManager.isGameOver = false
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.vintageInk)
            .padding(.bottom, 20)
        }
    }
    
    // --- HJÄLPFUNKTIONER ---
    
    func startQuiz() {
        if let level = level {
            // LEVEL MODE: Hämta specifika fåglar från LevelData
            let levelBirds = LevelData.shared.getBirdsForLevel(id: level.id, allBirds: store.birds)
            
            if levelBirds.isEmpty {
                print("Varning: Inga fåglar hittades för nivå \(level.id)")
            }
            
            quizManager.setBirds(levelBirds)
            quizManager.startQuiz()
            
        } else {
            // FRI MODE: Använd filter
            let filtered = store.birds.filter { bird in
                (selectedHabitat == "Alla" || bird.habitats.contains(selectedHabitat)) &&
                (selectedCategory == "Alla" || bird.broadCategory == selectedCategory)
            }
            quizManager.setBirds(filtered)
            quizManager.startQuiz()
        }
    }
    
    func checkLevelCompletion() {
        guard let level = level else { return }
        
        // Om vi har tillräckligt med poäng
        if quizManager.sessionScore >= level.requiredScore {
            // Lås upp nästa nivå via vår Persistence-klass
            QuizPersistence.shared.unlockNextLevel(currentLevel: level.id)
        }
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
    
    func filterPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(title).font(.system(.caption, design: .serif)).foregroundStyle(Color.vintageInk)
            Spacer()
            Menu {
                Picker(title, selection: selection) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue).font(.system(.body, design: .serif)).bold()
                    Image(systemName: "chevron.down").font(.caption)
                }
                .foregroundStyle(Color.vintageLeather)
            }
        }
    }
    
    func streakDots(for bird: Bird) -> some View {
        let streak = QuizPersistence.shared.getStreak(for: bird.id, mode: .audio)
        return HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < streak ? Color.vintageAccent : Color.vintageInk.opacity(0.1))
                    .frame(width: 8, height: 8)
            }
        }
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
}
