//
//  BirdStore.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-11-23.
//


import SwiftUI
import Combine

class BirdStore: ObservableObject {
    @Published var birds: [Bird] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        // 1. Locate the json file in the app bundle
        guard let url = Bundle.main.url(forResource: "birds", withExtension: "json") else {
            print("Error: Could not find birds.json in bundle.")
            return
        }
        
        // 2. Load the data
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // 3. Decode into our array of Birds
            let decodedBirds = try decoder.decode([Bird].self, from: data)
            
            // 4. Update the published property (must happen on main thread)
            DispatchQueue.main.async {
                self.birds = decodedBirds
            }
            print("Success: Loaded \(decodedBirds.count) birds.")
            
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}
