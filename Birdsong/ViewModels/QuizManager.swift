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
        generateNextQuestion()
    }
    
    private func generateNextQuestion() {
        // Filtrera bort fåglar som saknar ljud/bild beroende på mode?
        // (Detta görs dock bäst i Vyn innan de skickas hit, men vi kollar streaks här)
        
        let playableBirds = allBirds
        guard !playableBirds.isEmpty else {
            finishGame(message: "Inga fåglar i listan.")
            return
        }
        
        // NYTT: Kolla streak för specifikt mode
        let birdsToLearn = playableBirds.filter { !QuizPersistence.shared.isLearned(birdId: $0.id, mode: self.mode) }
        
        guard !birdsToLearn.isEmpty else {
            finishGame(message: "Grattis! Du har klarat alla fåglar i denna kategori.")
            return
        }
        
        guard let correctBird = birdsToLearn.randomElement() else { return }
        
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
