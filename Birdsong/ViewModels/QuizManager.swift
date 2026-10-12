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
    
    // CHANGED: 'var' so we can switch mode dynamically
    var mode: QuizMode
    
    // Flags to control behavior
    var isFreePlay: Bool = false
    var useSimilarSpecies: Bool = false
    var useImages: Bool {
        get { mode == .image }
        set { mode = newValue ? .image : .audio }
    }
    
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
        
        if isFreePlay {
            // In Free Play, we include ALL birds, even mastered ones.
            candidates = playableBirds
        } else {
            // In Level Mode, we filter out birds we have already learned
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
        
        // Pick Random
        guard let correctBird = finalCandidates.randomElement() else { return }
        lastBirdId = correctBird.id
        
        // Create Distractors (from the full list)
        let potentialDistractors = playableBirds.filter { $0.id != correctBird.id }
        let distractors: [Bird]
        if useSimilarSpecies {
            // 1. Try same specific group (e.g. Mesar, Trastar)
            let sameGroup = potentialDistractors.filter { $0.group == correctBird.group }.shuffled()
            var selectedDistractors = Array(sameGroup.prefix(3))
            
            // 2. If fewer than 3, try same broad category
            if selectedDistractors.count < 3 {
                let remainingNeeded = 3 - selectedDistractors.count
                let selectedIds = Set(selectedDistractors.map { $0.id })
                let sameBroad = potentialDistractors.filter {
                    !selectedIds.contains($0.id) && $0.broadCategory == correctBird.broadCategory
                }.shuffled()
                selectedDistractors.append(contentsOf: sameBroad.prefix(remainingNeeded))
            }
            
            // 3. Fallback to any remaining birds
            if selectedDistractors.count < 3 {
                let remainingNeeded = 3 - selectedDistractors.count
                let selectedIds = Set(selectedDistractors.map { $0.id })
                let others = potentialDistractors.filter { !selectedIds.contains($0.id) }.shuffled()
                selectedDistractors.append(contentsOf: others.prefix(remainingNeeded))
            }
            distractors = selectedDistractors
        } else {
            distractors = Array(potentialDistractors.shuffled().prefix(3))
        }
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
            
            // Only update Persistence (Map Progress) if NOT Free Play
            if !isFreePlay {
                QuizPersistence.shared.incrementStreak(for: bird.id, mode: self.mode)
            }
            
            generator.notificationOccurred(.success)
        } else {
            // Only update Persistence if NOT Free Play
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
