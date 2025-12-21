//
//  LevelData.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-16.
//


import Foundation

struct GameLevel: Identifiable {
    let id: Int             // Samma som 'number' på kartan (1, 2, 3...)
    let title: String       // T.ex. "Stugan"
    let birdNames: [String] // Exakta namn på fåglarna i nivån (matchar swedishName)
    let showVisualAid: Bool // Backlog-feature: Visa bild även vid ljudfrågor?
    let requiredScore: Int  // Hur många rätt krävs för att klara nivån?
}

class LevelData {
    static let shared = LevelData()
    
    // Här definierar vi innehållet för varje station på kartan
    let levels: [GameLevel] = [
        
        // --- ZON 1: START (Hjälphjul på) ---
        
        GameLevel(id: 1, title: "Start", birdNames: [
            "Talgoxe", "Blåmes", "Koltrast", "Skata", "Bofink"
        ], showVisualAid: true, requiredScore: 3),
        
        GameLevel(id: 2, title: "Trädgården", birdNames: [
            "Pilfink", "Gråsparv", "Domherre", "Rödhake", "Nötväcka"
        ], showVisualAid: true, requiredScore: 4),
        
        GameLevel(id: 3, title: "Byn", birdNames: [
            "Kaja", "Ladusvala", "Tornseglare", "Ringduva", "Fiskmås"
        ], showVisualAid: false, requiredScore: 4), // Nu tar vi bort stödhjulen!
        
        // --- ZON 2: ÄNG & SKOG ---
        
        GameLevel(id: 4, title: "Ängen", birdNames: [
            "Sånglärka", "Stare", "Gulsparv", "Tofsvipa", "Fasan"
        ], showVisualAid: false, requiredScore: 4),
        
        GameLevel(id: 5, title: "Öppna Landskap", birdNames: [
            "Stenskvätta", "Buskskvätta", "Hämpling", "Steglits"
        ], showVisualAid: false, requiredScore: 4),
        
        GameLevel(id: 6, title: "Gläntan", birdNames: [
            "Gröngöling", "Större hackspett", "Spillkråka", "Gök"
        ], showVisualAid: false, requiredScore: 4),
        
        // ... Vi kan fylla på med resten (7-15) senare
    ]
    
    // Hjälpfunktion för att hämta nivån baserat på ID
    func getLevel(id: Int) -> GameLevel? {
        return levels.first { $0.id == id }
    }
    
    // Hjälpfunktion för att hämta faktiska Bird-objekt från din stora lista
    func getBirdsForLevel(id: Int, allBirds: [Bird]) -> [Bird] {
        guard let level = getLevel(id: id) else { return [] }
        return allBirds.filter { level.birdNames.contains($0.swedishName) }
    }
}
