import Foundation
import PlaygroundSupport

// --- CONFIGURATION ---
// DOUBLE CHECK these paths match your computer!
let jsonPath = "/Users/staffanliden/Desktop/BirdData/birds.json"
let saveFolder = "/Users/staffanliden/Desktop/BirdData/audio_files/"
let outputJsonPath = "/Users/staffanliden/Desktop/BirdData/birds_with_audio.json"

// --- STRUCTS ---
struct Bird: Codable {
    let id: String
    let swedishName: String
    let latinName: String
    let description: String
    let difficulty: Int
    var audioClips: [BirdAudio]?
}

struct BirdAudio: Codable {
    let id: String
    let fileName: String
    let type: String
}

struct XCResponse: Codable {
    let recordings: [XCRecording]
}

struct XCRecording: Codable {
    let file: String
    let id: String
}

// --- SETUP ---
// Create the audio folder if it doesn't exist
try? FileManager.default.createDirectory(atPath: saveFolder, withIntermediateDirectories: true)

// Load the Birds
let url = URL(fileURLWithPath: jsonPath)
let data = try! Data(contentsOf: url)
var birds = try! JSONDecoder().decode([Bird].self, from: data)

// Semaphore to force the code to wait for downloads (Synchronous-ish)
let semaphore = DispatchSemaphore(value: 0)

// --- FUNCTION ---
func fetchAudioInfo(for bird: Bird) -> [BirdAudio]? {
    print("--> Searching for \(bird.swedishName)...")
    
    // 1. Build Query
    let queryRaw = "\(bird.latinName) cnt:\"=Sweden\" q:A"
    guard let query = queryRaw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
    
    let urlString = "https://www.xeno-canto.org/api/2/recordings?query=\(query)"
    guard let searchURL = URL(string: urlString) else { return nil }
    
    var request = URLRequest(url: searchURL)
    // Add the browser disguise just to be safe
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
    
    var resultClips: [BirdAudio]? = nil
    
    // 2. Search Xeno-Canto
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() } // Always signal when done
        
        guard let data = data,
              let xcResponse = try? JSONDecoder().decode(XCResponse.self, from: data),
              let recording = xcResponse.recordings.first else {
            print("    No recordings found.")
            return
        }
        
        // 3. Prepare Filename
        let cleanName = bird.swedishName.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "å", with: "a")
            .replacingOccurrences(of: "ä", with: "a")
            .replacingOccurrences(of: "ö", with: "o")
        let fileName = "\(cleanName).mp3"
        
        // 4. Download the MP3 File
        if let downloadURL = URL(string: recording.file),
           let audioData = try? Data(contentsOf: downloadURL) {
            
            let fileURL = URL(fileURLWithPath: saveFolder + fileName)
            try? audioData.write(to: fileURL)
            print("    Saved: \(fileName)")
            
            // Create the struct to return
            resultClips = [BirdAudio(id: UUID().uuidString, fileName: fileName, type: "song")]
        }
    }
    
    task.resume()
    semaphore.wait() // Wait here until the closure finishes
    
    return resultClips
}

// --- MAIN LOOP ---
print("--- Starting Download ---")

for i in 0..<birds.count {
    // Only fetch if empty
    if birds[i].audioClips == nil || birds[i].audioClips!.isEmpty {
        if let newClips = fetchAudioInfo(for: birds[i]) {
            birds[i].audioClips = newClips
        }
        // Sleep briefly to be polite to the server
        Thread.sleep(forTimeInterval: 1.0)
    } else {
        print("Skipping \(birds[i].swedishName) (Already has audio)")
    }
}

// --- SAVE RESULT ---
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
if let newData = try? encoder.encode(birds) {
    let outputURL = URL(fileURLWithPath: outputJsonPath)
    try? newData.write(to: outputURL)
    print("\n--- SUCCESS! ---")
    print("New JSON saved to: \(outputJsonPath)")
} else {
    print("Error saving JSON.")
}
