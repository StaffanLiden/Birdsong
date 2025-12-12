import Foundation

enum QuizMode {
    case audio
    case image
}

class QuizPersistence {
    static let shared = QuizPersistence()
    private let defaults = UserDefaults.standard
    
    // Vi behåller "bird_streak_" för ljud för att inte tappa din gamla data.
    // Vi lägger till "bird_streak_img_" för bild.
    private func key(for birdId: String, mode: QuizMode) -> String {
        switch mode {
        case .audio: return "bird_streak_" + birdId
        case .image: return "bird_streak_img_" + birdId
        }
    }
    
    private let requiredStreak = 3
    
    func getStreak(for birdId: String, mode: QuizMode) -> Int {
        return defaults.integer(forKey: key(for: birdId, mode: mode))
    }
    
    func incrementStreak(for birdId: String, mode: QuizMode) {
        let current = getStreak(for: birdId, mode: mode)
        defaults.set(current + 1, forKey: key(for: birdId, mode: mode))
    }
    
    func decreaseStreak(for birdId: String, mode: QuizMode) {
        let current = getStreak(for: birdId, mode: mode)
        if current > 0 {
            defaults.set(current - 1, forKey: key(for: birdId, mode: mode))
        }
    }
    
    func resetStreak(for birdId: String, mode: QuizMode) {
        defaults.set(0, forKey: key(for: birdId, mode: mode))
    }
    
    func isLearned(birdId: String, mode: QuizMode) -> Bool {
        return getStreak(for: birdId, mode: mode) >= requiredStreak
    }
}
