import SwiftUI
import Combine
import AVFoundation

struct QuizView: View {
    @EnvironmentObject var store: BirdStore
    @StateObject private var quizManager = QuizManager(birds: [])
    @State private var player: AVAudioPlayer?
    
    // Filter
    @State private var selectedHabitat: String = "Alla"
    let habitats = ["Alla", "Skog", "Hav & Kust", "Äng & Åker", "Fjäll", "Trädgård", "Stad"]
    @State private var selectedCategory: String = "Alla"
    let categories = ["Alla", "Sångfåglar", "Vattenfåglar", "Rovfåglar & Ugglor", "Hackspettar", "Övriga Landfåglar", "Övriga"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.vintagePaper.ignoresSafeArea()
                
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
            }
        }
        .onAppear { player?.stop() }
        .onDisappear {
                    // Stoppa ljudet om man byter flik
                    player?.stop()
                }
        .onChange(of: quizManager.isGameOver) { _, newValue in
            if newValue { player?.stop() }
        }
    }
    
    // --- STARTSKÄRM ---
    var startView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "music.mic.circle.fill") // En symbol för ljud
                .font(.system(size: 80))
                .foregroundStyle(Color.vintageAccent)
                .shadow(color: .vintageAccent.opacity(0.3), radius: 10)
            
            VStack(spacing: 8) {
                Text("Ljudquiz")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                
                Text("Kan du höra vem det är?")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.7))
            }
            
            // Filter-sektion (Lite snyggare inramning)
            VStack(spacing: 16) {
                filterPicker(title: "Miljö", selection: $selectedHabitat, options: habitats)
                filterPicker(title: "Kategori", selection: $selectedCategory, options: categories)
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(10)
            .padding(.horizontal)
            
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
        VStack(spacing: 20) {
            // Header med poäng
            HStack {
                Text("Poäng: \(quizManager.sessionScore)")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                Spacer()
                // Streak-indikator (om du vill ha kvar den, annars ta bort)
                if let bird = quizManager.currentQuestion?.correctBird {
                    streakDots(for: bird)
                }
            }
            .padding()
            
            Spacer()
            
            // LJUDSPELAREN (Visuellt center)
            Button {
                playCurrentQuestionAudio()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.vintagePaper)
                        .frame(width: 180, height: 180)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 5, y: 5)
                        .overlay(Circle().stroke(Color.vintageInk.opacity(0.1), lineWidth: 1))
                    
                    VStack(spacing: 10) {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.vintageAccent)
                        Text("Spela Ljud")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.vintageInk)
                    }
                }
            }
            
            Text("Tryck för att lyssna igen")
                .font(.system(.caption, design: .serif))
                .italic()
                .foregroundStyle(Color.vintageInk.opacity(0.6))
            
            Spacer()
            
            // SVARSALTERNATIV
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
                .padding()
            }
        }
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
            
            Button("Huvudmeny") { quizManager.isGameOver = false }
                .buttonStyle(.plain)
                .foregroundStyle(Color.vintageInk)
                .padding(.bottom, 20)
        }
    }
    
    // --- HJÄLPFUNKTIONER ---
    
    func buttonState(for bird: Bird) -> VintageOptionButton.ButtonState {
        guard let selected = quizManager.selectedBird else { return .neutral }
        if bird.id == quizManager.currentQuestion?.correctBird.id { return .correct }
        if bird.id == selected.id { return .wrong }
        return .disabled
    }
    
    func startQuiz() {
        let filtered = store.birds.filter { bird in
            (selectedHabitat == "Alla" || bird.habitats.contains(selectedHabitat)) &&
            (selectedCategory == "Alla" || bird.broadCategory == selectedCategory)
        }
        quizManager.setBirds(filtered)
        quizManager.startQuiz()
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
        let streak = QuizPersistence.shared.getStreak(for: bird.id)
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
