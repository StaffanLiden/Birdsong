import SwiftUI
import Combine
import UIKit

struct QuizQuestion: Identifiable {
    let id = UUID()
    let correctBird: Bird
    let options: [Bird]
}

class QuizManager: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var sessionScore: Int = 0
    @Published var questionsAnswered: Int = 0
    @Published var isGameOver: Bool = false
    @Published var gameFinishedMessage: String = ""
    @Published var selectedBird: Bird? = nil
    
    private var allBirds: [Bird] = []
    
    // NYTT: Vi sparar vilket mode vi kör
    let mode: QuizMode
    
    // NYTT: För att förhindra repetition (Issue #2)
    private var lastBirdId: String? = nil
    
    // NYTT: Init tar nu emot mode
    init(birds: [Bird], mode: QuizMode) {
        self.allBirds = birds
        self.mode = mode
    }
    
    func setBirds(_ birds: [Bird]) {
        self.allBirds = birds
    }
    
    func startQuiz() {
        sessionScore = 0
        questionsAnswered = 0
        isGameOver = false
        selectedBird = nil
        lastBirdId = nil // Nollställ minnet vid ny omgång
        generateNextQuestion()
    }
    
    private func generateNextQuestion() {
        let playableBirds = allBirds
        guard !playableBirds.isEmpty else {
            finishGame(message: "Inga fåglar i listan.")
            return
        }
        
        // 1. Vilka fåglar har vi kvar att lära oss?
        let birdsToLearn = playableBirds.filter { !QuizPersistence.shared.isLearned(birdId: $0.id, mode: self.mode) }
        
        guard !birdsToLearn.isEmpty else {
            finishGame(message: "Grattis! Du har klarat alla fåglar i denna kategori.")
            return
        }
        
        // 2. Filtrera kandidater (Issue #2: Undvik samma fågel två gånger i rad)
        var candidates = birdsToLearn
        
        // Om vi har fler än en fågel kvar att välja på, ta bort den vi nyss körde
        if let lastId = lastBirdId, candidates.count > 1 {
            candidates = candidates.filter { $0.id != lastId }
        }
        
        // 3. Välj slumpmässig kandidat
        guard let correctBird = candidates.randomElement() else { return }
        
        // Uppdatera minnet för nästa gång
        lastBirdId = correctBird.id
        
        // 4. Skapa distractors (felaktiga svar)
        // Dessa tar vi från HELA listan (playableBirds), inte bara de vi inte lärt oss
        let potentialDistractors = playableBirds.filter { $0.id != correctBird.id }
        let distractors = Array(potentialDistractors.shuffled().prefix(3))
        let options = (distractors + [correctBird]).shuffled()
        
        DispatchQueue.main.async {
            self.currentQuestion = QuizQuestion(correctBird: correctBird, options: options)
        }
    }
    
    func submitAnswer(_ bird: Bird) {
        guard selectedBird == nil, let currentQ = currentQuestion else { return }
        
        selectedBird = bird
        questionsAnswered += 1
        
        let generator = UINotificationFeedbackGenerator()
                generator.prepare()
        
        if bird.id == currentQ.correctBird.id {
            sessionScore += 1
            // NYTT: Skicka med mode
            QuizPersistence.shared.incrementStreak(for: bird.id, mode: self.mode)
            
            generator.notificationOccurred(.success)
        } else {
            // NYTT: Skicka med mode
            QuizPersistence.shared.resetStreak(for: currentQ.correctBird.id, mode: self.mode)
            QuizPersistence.shared.decreaseStreak(for: bird.id, mode: self.mode)
            
            generator.notificationOccurred(.error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.selectedBird = nil
            self.generateNextQuestion()
        }
    }
    
    func quitSession() {
        finishGame(message: "Bra jobbat! Du fick \(sessionScore) rätt av \(questionsAnswered).")
    }
    
    private func finishGame(message: String) {
        self.gameFinishedMessage = message
        self.isGameOver = true
        self.currentQuestion = nil
    }
}

