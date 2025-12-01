import SwiftUI
import Combine

struct QuizQuestion: Identifiable {
    let id = UUID()
    let correctBird: Bird
    let options: [Bird]
}

class QuizManager: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var sessionScore: Int = 0    // Antal rätt denna omgång
    @Published var questionsAnswered: Int = 0 // Totalt antal frågor denna omgång
    @Published var isGameOver: Bool = false
    @Published var gameFinishedMessage: String = ""
    
    // Track selection
    @Published var selectedBird: Bird? = nil
    
    private var allBirds: [Bird] = []
    
    init(birds: [Bird]) {
        self.allBirds = birds
    }
    
    func setBirds(_ birds: [Bird]) {
        self.allBirds = birds
    }
    
    func startQuiz() {
        sessionScore = 0
        questionsAnswered = 0
        isGameOver = false
        selectedBird = nil
        generateNextQuestion()
    }
    
    private func generateNextQuestion() {
        // 1. Filtrera bort fåglar som saknar ljud
        let playableBirds = allBirds.filter { !$0.audioClips.isEmpty }
        
        guard !playableBirds.isEmpty else {
            finishGame(message: "Inga fåglar med ljud hittades.")
            return
        }
        
        // 2. Hitta fåglar som INTE är "lärda" än
        let birdsToLearn = playableBirds.filter { !QuizPersistence.shared.isLearned(birdId: $0.id) }
        
        // 3. Om alla är lärda – Grattis!
        guard !birdsToLearn.isEmpty else {
            finishGame(message: "Grattis! Du har lärt dig alla fåglar i listan (3 rätt i rad på alla).")
            return
        }
        
        // 4. Välj rätt svar (slumpa en av de vi inte kan än)
        guard let correctBird = birdsToLearn.randomElement() else { return }
        
        // 5. Välj distraktioner
        let potentialDistractors = playableBirds.filter { $0.id != correctBird.id }
        let distractors = Array(potentialDistractors.shuffled().prefix(3))
        
        // 6. Blanda alternativen
        let options = (distractors + [correctBird]).shuffled()
        
        // 7. Sätt frågan
        DispatchQueue.main.async {
            self.currentQuestion = QuizQuestion(correctBird: correctBird, options: options)
        }
    }
    
    func submitAnswer(_ bird: Bird) {
        // Förhindra dubbelklick
        guard selectedBird == nil, let currentQ = currentQuestion else { return }
        
        selectedBird = bird
        questionsAnswered += 1
        
        if bird.id == currentQ.correctBird.id {
            // RÄTT SVAR
            sessionScore += 1
            // Spara framsteg: Öka streak för den rätta fågeln
            QuizPersistence.shared.incrementStreak(for: bird.id)
        } else {
            // FEL SVAR
            
            // 1. Fågeln vi INTE kände igen (den som spelades) -> Nollställs
            QuizPersistence.shared.resetStreak(for: currentQ.correctBird.id)
            
            // 2. Fågeln vi gissade FELAKTIGT på -> Straffas (sänks ett steg)
            // Logik: Om jag tror att en Talgoxe är en Blåmes, kan jag inte Blåmesen tillräckligt bra heller.
            QuizPersistence.shared.decreaseStreak(for: bird.id)
        }
        
        // Vänta lite och kör nästa fråga
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.selectedBird = nil
            self.generateNextQuestion()
        }
    }
    
    // Manuell avslutning av spelet
    func quitSession() {
        finishGame(message: "Bra jobbat! Du fick \(sessionScore) rätt av \(questionsAnswered).")
    }
    
    private func finishGame(message: String) {
        self.gameFinishedMessage = message
        self.isGameOver = true
        self.currentQuestion = nil
    }
}
