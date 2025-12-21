import Foundation

enum QuizMode {
    case audio
    case image
}

class QuizPersistence {
    static let shared = QuizPersistence()
    private let defaults = UserDefaults.standard
    
    // NYTT: Nyckel för att spara kart-framsteg
        private let kHighestUnlockedLevel = "highestUnlockedLevel"
        
        private init() {}
        
        // --- NYA FUNKTIONER FÖR KARTAN ---
        
        // Hämta aktuell nivå (Startar på 1 om inget är sparat)
        var highestUnlockedLevel: Int {
            let level = defaults.integer(forKey: kHighestUnlockedLevel)
            return level == 0 ? 1 : level
        }
        
        // Lås upp nästa nivå
        func unlockNextLevel(currentLevel: Int) {
            if currentLevel >= highestUnlockedLevel {
                defaults.set(currentLevel + 1, forKey: kHighestUnlockedLevel)
            }
        }
    
    // Återställ (bra för testning)
        func resetProgress() {
            defaults.set(1, forKey: kHighestUnlockedLevel)
        }
    
    
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
