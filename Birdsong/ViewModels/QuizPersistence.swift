//
//  QuizPersistence.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-01.
//

import Foundation

class QuizPersistence {
    static let shared = QuizPersistence()
    private let defaults = UserDefaults.standard
    private let streakKeyPrefix = "bird_streak_"
    
    // Hur många rätt i rad krävs för att den ska räknas som "lärd"?
    private let requiredStreak = 3
    
    // Hämta nuvarande streak för en fågel
    func getStreak(for birdId: String) -> Int {
        return defaults.integer(forKey: streakKeyPrefix + birdId)
    }
    
    // Öka streak (vid rätt svar)
    func incrementStreak(for birdId: String) {
        let current = getStreak(for: birdId)
        defaults.set(current + 1, forKey: streakKeyPrefix + birdId)
    }
    
    // NY FUNKTION: Sänk streak (vid felaktig gissning på denna fågel)
    // Vi sänker med 1, men går aldrig under 0.
    func decreaseStreak(for birdId: String) {
        let current = getStreak(for: birdId)
        if current > 0 {
            defaults.set(current - 1, forKey: streakKeyPrefix + birdId)
        }
    }
    
    // Nollställ streak (när man misslyckas med att identifiera denna fågel)
    func resetStreak(for birdId: String) {
        defaults.set(0, forKey: streakKeyPrefix + birdId)
    }
    
    // Är fågeln "lärd"? (dvs streak >= 3)
    func isLearned(birdId: String) -> Bool {
        return getStreak(for: birdId) >= requiredStreak
    }
    
    // Hämta en lista på alla IDn som är "lärda"
    func getAllLearnedIds(allBirds: [Bird]) -> Set<String> {
        let learned = allBirds.filter { isLearned(birdId: $0.id) }
        return Set(learned.map { $0.id })
    }
    
    // Debug: Rensa all data (bra för testning)
    func resetAllProgress(allBirds: [Bird]) {
        for bird in allBirds {
            defaults.removeObject(forKey: streakKeyPrefix + bird.id)
        }
    }
    
    // Hämta statistik
    func getStats(allBirds: [Bird]) -> [Int: Int] {
        var stats = [0: 0, 1: 0, 2: 0, 3: 0]
        
        for bird in allBirds {
            let streak = getStreak(for: bird.id)
            let level = min(streak, requiredStreak)
            stats[level, default: 0] += 1
        }
        
        return stats
    }
}
