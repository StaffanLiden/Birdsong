import SwiftUI
import Combine
import AVFoundation

struct QuizView: View {
    @EnvironmentObject var store: BirdStore
    @StateObject private var quizManager = QuizManager(birds: [])
    
    // Audio Player State
    @State private var player: AVAudioPlayer?
    
    @State private var selectedHabitat: String = "Alla"
    let habitats = ["Alla", "Skog", "Hav & Kust", "Äng & Åker", "Fjäll", "Trädgård", "Stad"]
    
    // ÄNDRING 1: Vi använder nu de breda kategorierna istället för smågrupperna
    @State private var selectedCategory: String = "Alla"
    let categories = [
        "Alla",
        "Sångfåglar",
        "Vattenfåglar",
        "Rovfåglar & Ugglor",
        "Hackspettar",
        "Övriga Landfåglar",
        "Övriga"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if quizManager.isGameOver {
                    gameOverView
                } else if quizManager.currentQuestion == nil {
                    startView
                } else {
                    activeGameView
                }
            }
            .toolbar {
                // Visa bara Avsluta-knappen om spelet är igång
                if quizManager.currentQuestion != nil && !quizManager.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Avsluta") {
                            quizManager.quitSession()
                        }
                    }
                }
            }
        }
        .onAppear {
            player?.stop()
        }
        .onChange(of: quizManager.isGameOver) { oldValue, newValue in
            if newValue == true { player?.stop() }
        }
    }
    
    // SCREEN 1: Start Screen
        var startView: some View {
            VStack(spacing: 25) {
                Image(systemName: "infinity.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
               
                Text("Evighetsquiz")
                    .font(.largeTitle)
                    .bold()
               
                // --- FILTER MENYER ---
                HStack(spacing: 15) {
                    // MILJÖ
                    Menu {
                        Picker("Välj miljö", selection: $selectedHabitat) {
                            ForEach(habitats, id: \.self) { habitat in
                                Text(habitat).tag(habitat)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("MILJÖ")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(selectedHabitat)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    // KATEGORI (Tidigare GRUPP)
                    Menu {
                        Picker("Välj kategori", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("KATEGORI") // Uppdaterad rubrik
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(selectedCategory)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                // ---------------------
               
                Text("Lär dig fåglarna!\nFåglar du svarar rätt på 3 gånger i rad plockas bort ur leken.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
               
                Button("Starta") {
                    // --- FILTRERINGS LOGIK (UPPDATERAD) ---
                    let filteredBirds = store.birds.filter { bird in
                        let habitatMatch = (selectedHabitat == "Alla") || bird.habitats.contains(selectedHabitat)
                        
                        // ÄNDRING 2: Vi matchar mot broadCategory istället för group
                        let categoryMatch = (selectedCategory == "Alla") || (bird.broadCategory == selectedCategory)
                        
                        return habitatMatch && categoryMatch
                    }
                    
                    // Starta spelet med urvalet
                    quizManager.setBirds(filteredBirds)
                    quizManager.startQuiz()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 10)
               
                // Debug Reset
                Button("Nollställ mina framsteg") {
                    QuizPersistence.shared.resetAllProgress(allBirds: store.birds)
                }
                .font(.caption)
                .foregroundStyle(.red)
                .padding(.top, 20)
            }
        }
    
    // SCREEN 2: Active Question
    var activeGameView: some View {
        VStack(spacing: 20) {
           
            // Info Header
            HStack {
                Text("Score: \(quizManager.sessionScore)")
                    .font(.headline)
                Spacer()
                if let bird = quizManager.currentQuestion?.correctBird {
                    // Visa hur "lärd" denna fågel är
                    let streak = QuizPersistence.shared.getStreak(for: bird.id)
                    HStack(spacing: 4) {
                        Text("Streak:")
                            .font(.caption)
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(i < streak ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
           
            Spacer()
           
            // "Audio Player" Visual
            Button {
                playCurrentQuestionAudio()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            Text("Tryck för att lyssna igen")
                .font(.caption)
                .foregroundStyle(.secondary)
           
            Spacer()
           
            // Answer Buttons
            if let question = quizManager.currentQuestion {
                VStack(spacing: 12) {
                    ForEach(question.options) { bird in
                        Button {
                            quizManager.submitAnswer(bird)
                        } label: {
                            Text(bird.swedishName)
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(backgroundColor(for: bird, in: question))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        .disabled(quizManager.selectedBird != nil)
                    }
                }
                .padding()
            }
        }
        .onChange(of: quizManager.currentQuestion?.id) { oldValue, newValue in
            if newValue != nil {
                playCurrentQuestionAudio()
            }
        }
    }
    
    // SCREEN 3: Game Over / Session Summary
        var gameOverView: some View {
            VStack(spacing: 20) {
                Text("Omgång avslutad")
                    .font(.largeTitle)
                    .bold()
               
                Text(quizManager.gameFinishedMessage)
                    .multilineTextAlignment(.center)
                    .padding()
               
                Text("Resultat denna gång:")
                    .font(.headline)
                Text("\(quizManager.sessionScore) av \(quizManager.questionsAnswered)")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.blue)
               
                // Knapp 1: Starta om direkt (med samma filter)
                Button("Fortsätt träna") {
                    quizManager.startQuiz()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 20)
               
                // Knapp 2: Gå tillbaka till filtren
                Button("Avsluta till huvudmenyn") {
                    quizManager.isGameOver = false
                }
                .buttonStyle(.bordered)
            }
        }
    
    // MARK: - Audio Logic (Samma som förut)
    func playCurrentQuestionAudio() {
        player?.stop()
        guard let question = quizManager.currentQuestion else { return }
        guard let clip = question.correctBird.audioClips.first else { return }
        
        let fileName = clip.fileName
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
    
    // MARK: - Helper Colors
    func backgroundColor(for bird: Bird, in question: QuizQuestion) -> Color {
        guard let selected = quizManager.selectedBird else {
            return Color(.systemGray6)
        }
        
        if bird.id == question.correctBird.id {
            return Color.green.opacity(0.6)
        } else if bird.id == selected.id {
            return Color.red.opacity(0.6)
        } else {
            return Color(.systemGray6)
        }
    }
}
