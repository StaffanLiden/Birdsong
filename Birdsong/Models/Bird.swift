//
//  Bird.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-11-23.
//

import Foundation

struct Bird: Identifiable, Codable {
    let id: String
    let swedishName: String
    let latinName: String
    let description: String
    let difficulty: Int
    var audioClips: [BirdAudio]
    var imageName: String?
    var habitats: [String] = []
    var imageCredit: String = ""
    var group: String = "Övriga"
}

struct BirdAudio: Identifiable, Codable {
    // Vi låter id skapas automatiskt och utesluter det från JSON-kopplingen
    let id = UUID()
    let fileName: String
    let type: String      // "song" or "call"
    let source: String    // The recordist name
    
    // CodingKeys berättar för Swift exakt vilka fält som ska hämtas från JSON.
    // Eftersom 'id' inte är med här, kommer Swift generera ett nytt UUID automatiskt.
    private enum CodingKeys: String, CodingKey {
        case fileName
        case type
        case source
    }
}

// MARK: - Extensions & Hjälpfunktioner

extension Bird {
    // En "alias" så att vi kan skriva bird.name istället för bird.swedishName i vyerna
    var name: String {
        return swedishName
    }
    
    // Den bredare gruppindelningen
    var broadCategory: String {
        // OBS: Dessa strängar måste matcha vad du har i din JSON-fil under "group".
        // Om du har "Mesar" i JSON men skriver "Mes" här, hamnar den i "Övriga".
        switch group {
        case "Mes", "Fink", "Sparv", "Trast", "Sångare", "Flugsnappare", "Svala", "Ärla", "Kråkfågel":
            return "Sångfåglar"
            
        case "And", "Gås", "Svan", "Lom", "Dopping", "Mås", "Trut", "Vadare", "Häger", "Trana", "Skarv":
            return "Vattenfåglar"
            
        case "Hök", "Vråk", "Örn", "Falk", "Uggla":
            return "Rovfåglar & Ugglor"
            
        case "Hackspett", "Nötväcka", "Trädkrypare":
            return "Hackspettar"
            
        case "Duva", "Gök", "Hönsfågel", "Seglare":
            return "Övriga Landfåglar"
            
        default:
            return "Övriga"
        }
    }
}
