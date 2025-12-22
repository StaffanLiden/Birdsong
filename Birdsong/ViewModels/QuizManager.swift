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
    
    // CHANGED: 'var' allows us to switch from Silver (Image) to Gold (Audio)
    var mode: QuizMode
    
    // NEW: Flags for "Radio Dashboard" / Free Play
    var isFreePlay: Bool = false
    var useImages: Bool = true
    var useSimilarSpecies: Bool = false
    
    // To prevent immediate repetition
    private var lastBirdId: String? = nil
    
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
        lastBirdId = nil
        generateNextQuestion()
    }
    
    private func generateNextQuestion() {
        let playableBirds = allBirds
        guard !playableBirds.isEmpty else {
            finishGame(message: "Inga fåglar i listan.")
            return
        }
        
        let candidates: [Bird]
        
        // --- 1. DETERMINE CANDIDATES ---
        if isFreePlay {
            // Free Play: We practice on ALL birds, even mastered ones.
            candidates = playableBirds
        } else {
            // Level Mode: Only practice birds we haven't mastered yet for this mode.
            let birdsToLearn = playableBirds.filter { !QuizPersistence.shared.isLearned(birdId: $0.id, mode: self.mode) }
            
            guard !birdsToLearn.isEmpty else {
                finishGame(message: "Grattis! Du har klarat alla fåglar i denna kategori.")
                return
            }
            candidates = birdsToLearn
        }
        
        // Avoid repeating the immediate last bird if possible
        var finalCandidates = candidates
        if let lastId = lastBirdId, finalCandidates.count > 1 {
            finalCandidates = finalCandidates.filter { $0.id != lastId }
        }
        
        // Pick Random Correct Bird
        guard let correctBird = finalCandidates.randomElement() else { return }
        lastBirdId = correctBird.id
        
        // --- 2. GENERATE DISTRACTORS (WRONG ANSWERS) ---
        var potentialDistractors: [Bird]
        
        if useSimilarSpecies {
            // HARD MODE: Filter distractors to be in the same 'broadCategory' (Family)
            potentialDistractors = playableBirds.filter {
                $0.id != correctBird.id && $0.broadCategory == correctBird.broadCategory
            }
            
            // Fallback: If category is too small (e.g., Cuckoos), fill up with random birds
            if potentialDistractors.count < 3 {
                let others = playableBirds.filter { $0.id != correctBird.id && $0.broadCategory != correctBird.broadCategory }
                potentialDistractors.append(contentsOf: others)
            }
        } else {
            // NORMAL MODE: Distractors can be any other bird in the list
            potentialDistractors = playableBirds.filter { $0.id != correctBird.id }
        }
        
        // Shuffle and pick 3
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
            
            // Only update Persistence (Map Progress) if we are NOT in Free Play
            if !isFreePlay {
                QuizPersistence.shared.incrementStreak(for: bird.id, mode: self.mode)
            }
            
            generator.notificationOccurred(.success)
        } else {
            // Only update Persistence if NOT in Free Play
            if !isFreePlay {
                QuizPersistence.shared.resetStreak(for: currentQ.correctBird.id, mode: self.mode)
                QuizPersistence.shared.decreaseStreak(for: bird.id, mode: self.mode)
            }
            
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
