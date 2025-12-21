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
    let showVisualAid: Bool // Visa bild även vid ljudfrågor?
    let requiredScore: Int  // Hur många rätt krävs för att klara nivån?
}

class LevelData {
    static let shared = LevelData()
    
    // Här definierar vi innehållet för varje station på kartan
    let levels: [GameLevel] = [
        
        // --- ZON 1: START & TRÄDGÅRD (Hjälphjul på) ---
        
        GameLevel(id: 1, title: "Start", birdNames: [
            "Talgoxe", "Blåmes", "Koltrast", "Bofink", "Skata",
            "Gråsparv", "Sädesärla", "Rödhake", "Nötväcka", "Kaja"
        ], showVisualAid: true, requiredScore: 7),
        
        GameLevel(id: 2, title: "Trädgården", birdNames: [
            "Pilfink", "Domherre", "Grönfink", "Svartvit flugsnappare", "Björktrast",
            "Svarthätta", "Trädgårdssångare", "Grå flugsnappare", "Sidensvans", "Stenknäck"
        ], showVisualAid: true, requiredScore: 7),
        
        // --- ZON 2: KULTURBYGD (Hjälphjul av) ---
        
        GameLevel(id: 3, title: "Byn", birdNames: [
            "Tornseglare", "Ladusvala", "Hussvala", "Ringduva", "Fiskmås",
            "Kråka", "Råka", "Stare", "Skrattmås", "Gråhäger"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 4, title: "Ängen", birdNames: [
            "Sånglärka", "Tofsvipa", "Fasan", "Gulsparv", "Buskskvätta",
            "Ängspiplärka", "Gulärla", "Hämpling", "Steglits", "Storspov"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 5, title: "Öppna Landskap", birdNames: [
            "Törnskata", "Stenskvätta", "Rosenfink", "Ärtsångare", "Törnsångare",
            "Härmsångare", "Rödstjärt", "Orre", "Halsbandsflugsnappare"
        ], showVisualAid: false, requiredScore: 7),
        
        // --- ZON 3: SKOGAR ---
        
        GameLevel(id: 6, title: "Gläntan", birdNames: [
            "Gök", "Gröngöling", "Större hackspett", "Spillkråka", "Gråspett",
            "Mindre hackspett", "Trädpiplärka", "Nötskrika", "Dubbeltrast", "Taltrast"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 7, title: "Lövskogen", birdNames: [
            "Lövsångare", "Grönsångare", "Skogsduva", "Entita", "Stjärtmes",
            "Gärdsmyg", "Gransångare", "Trädkrypare", "Järnsparv", "Göktyta"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 8, title: "Granskogen", birdNames: [
            "Tjäder", "Järpe", "Kungsfågel", "Svartmes", "Tofsmes",
            "Talltita", "Mindre korsnäbb", "Rödvingetrast", "Grönsiska", "Skogssnäppa"
        ], showVisualAid: false, requiredScore: 7),
        
        // --- ZON 4: VATTEN & VADARE ---
        
        GameLevel(id: 9, title: "Strandängen", birdNames: [
            "Strandskata", "Drillsnäppa", "Grönbena", "Trana", "Vit stork",
            "Grågås", "Kanadagås", "Ljungpipare", "Sångsvan", "Kricka"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 10, title: "Vassen", birdNames: [
            "Rörsångare", "Sävsångare", "Kärrsångare", "Sävsparv", "Sothöna",
            "Rörhöna", "Skäggdopping", "Gräsand", "Knölsvan", "Skedand"
        ], showVisualAid: false, requiredScore: 7),
        
        // --- ZON 5: SPECIALISTER & MILJÖER ---
        
        GameLevel(id: 11, title: "Rovfåglar", birdNames: [
            "Havsörn", "Kungsörn", "Ormvråk", "Fjällvråk", "Sparvhök",
            "Fiskgjuse", "Tornfalk", "Pilgrimsfalk", "Blå kärrhök", "Röd glada"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 12, title: "Kusten", birdNames: [
            "Ejder", "Knipa", "Småskrake", "Storskrake", "Vigg",
            "Bläsand", "Gråtrut", "Havstrut", "Silvertärna", "Fisktärna"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 13, title: "Fjällen", birdNames: [
            "Fjällripa", "Dalripa", "Blåhake", "Bergfink", "Snösparv",
            "Gråsiska", "Lavskrika", "Korp", "Smålom", "Storlom"
        ], showVisualAid: false, requiredScore: 7),
        
        GameLevel(id: 14, title: "Nattens ljud", birdNames: [
            "Kattuggla", "Pärluggla", "Slaguggla", "Berguv", "Sparvuggla",
            "Hökuggla", "Morkulla", "Näktergal", "Vattenrall", "Enkelbeckasin"
        ], showVisualAid: false, requiredScore: 7),
        
        // --- SLUTZON ---
        
        GameLevel(id: 15, title: "Nästa nivå", birdNames: [], showVisualAid: false, requiredScore: 0)
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
