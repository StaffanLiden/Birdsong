import Foundation

// 1. Define QuizMode globally so all Views and Managers can see it
enum QuizMode: String, Codable {
    case audio
    case image
}

class QuizPersistence {
    static let shared = QuizPersistence()
    private let defaults = UserDefaults.standard
    
    // Keys
    private let kHighestUnlockedLevel = "highestUnlockedLevel"
    private let requiredStreak = 3 // How many correct in a row to count as "Mastered"
    
    private init() {}
        
    // --- LEVEL PROGRESSION ---
        
    var highestUnlockedLevel: Int {
        let level = defaults.integer(forKey: kHighestUnlockedLevel)
        return level == 0 ? 1 : level
    }
        
    func unlockNextLevel(currentLevel: Int) {
        if currentLevel >= highestUnlockedLevel {
            defaults.set(currentLevel + 1, forKey: kHighestUnlockedLevel)
        }
    }
    
    // --- MASTERY LOGIC (Silver/Gold) ---
    
    // Silver = Visual Mastery (Image Mode) of 7+ birds
    func hasSilver(birdIds: [String]) -> Bool {
        return countMastered(birdIds: birdIds, mode: .image) >= 7
    }
    
    // Gold = Audio Mastery (Audio Mode) of 7+ birds
    func hasGold(birdIds: [String]) -> Bool {
        return countMastered(birdIds: birdIds, mode: .audio) >= 7
    }
    
    // Helper to count how many birds in a list are mastered
    func countMastered(birdIds: [String], mode: QuizMode) -> Int {
        return birdIds.filter { getStreak(for: $0, mode: mode) >= requiredStreak }.count
    }
    
    // --- STREAK MANAGEMENT ---
    
    private func key(for birdId: String, mode: QuizMode) -> String {
        switch mode {
        case .audio: return "bird_streak_" + birdId
        case .image: return "bird_streak_img_" + birdId
        }
    }
    
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
    
    // --- RESET ---
    
    func resetAllData() {
        defaults.set(1, forKey: kHighestUnlockedLevel)
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
            defaults.synchronize()
        }
    }
}
