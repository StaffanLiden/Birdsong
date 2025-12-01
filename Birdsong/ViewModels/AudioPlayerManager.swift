//
//  AudioPlayerManager.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-01.
//


import AVFoundation
import Combine
import SwiftUI

class AudioPlayerManager: ObservableObject {
    // Singleton för att enkelt nås överallt (valfritt, men smidigt här)
    static let shared = AudioPlayerManager()
    
    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingURL: URL? = nil
    
    private var audioPlayer: AVAudioPlayer?
    
    func play(fileName: String) {
        // Om vi redan spelar just denna fil -> Pausa
        if let current = currentlyPlayingURL, current.lastPathComponent == fileName, isPlaying {
            pause()
            return
        }
        
        // Annars, starta ny fil
        let name = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Kunde inte hitta filen: \(fileName)")
            return
        }
        
        do {
            // Se till att ljudet hörs även om mobilen är i tyst läge
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            currentlyPlayingURL = url
            isPlaying = true
            
        } catch {
            print("Kunde inte spela filen: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentlyPlayingURL = nil
    }
    
    // Hjälpfunktion för UI: Är just denna fil igång?
    func isFilePlaying(fileName: String) -> Bool {
        guard let current = currentlyPlayingURL else { return false }
        return current.lastPathComponent == fileName && isPlaying
    }
}
