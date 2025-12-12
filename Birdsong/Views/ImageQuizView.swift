import SwiftUI

struct ImageQuizView: View {
    @EnvironmentObject var store: BirdStore
    @StateObject private var quizManager = QuizManager(birds: [], mode: .image)
    
    // Filter-variabler
        @State private var selectedHabitat: String = "Alla"
        let habitats = ["Alla", "Skog", "Hav & Kust", "Äng & Åker", "Fjäll", "Trädgård", "Stad"]
        
        @State private var selectedCategory: String = "Alla"
        let categories = ["Alla", "Sångfåglar", "Vattenfåglar", "Rovfåglar & Ugglor", "Hackspettar", "Övriga Landfåglar"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.87, green: 0.81, blue: 0.68)
                    .ignoresSafeArea()
                
                VStack {
                    if quizManager.isGameOver {
                        gameOverView
                    } else if quizManager.currentQuestion == nil {
                        startView
                    } else {
                        activeGameView
                    }
                }
            }
            .toolbarBackground(Color.vintagePaper, for: .navigationBar)
            .toolbar {
                if quizManager.currentQuestion != nil && !quizManager.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Avsluta") { quizManager.quitSession() }
                            .foregroundColor(.vintageInk)
                    }
                }
            }
        }
    }
    
    // --- STARTSKÄRM ---
    var startView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "photo.circle.fill") // Enhetlig ikon-stil
                .font(.system(size: 80))
                .foregroundStyle(Color.vintageAccent)
                .shadow(color: .vintageAccent.opacity(0.3), radius: 10)
            
            VStack(spacing: 8) {
                Text("Bildquiz")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                Text("Känner du igen arten?")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.7))
            }
            
            // Filter-sektion
                        VStack(spacing: 16) {
                            filterPicker(title: "Miljö", selection: $selectedHabitat, options: habitats)
                            filterPicker(title: "Kategori", selection: $selectedCategory, options: categories)
                        }
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.horizontal)
            
            Spacer()
            
            Button(action: startQuiz) {
                Text("STARTA")
                    .font(.system(.title3, design: .serif))
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.vintageLeather)
                    .cornerRadius(8)
                    .shadow(radius: 4, y: 2)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // --- SPELSKÄRM ---
        var activeGameView: some View {
            VStack(spacing: 20) {
                
                // HÄR SKAPAR VI EN HSTACK FÖR ATT FÅ SAKER BREDVID VARANDRA
                HStack {
                    Text("Poäng: \(quizManager.sessionScore)")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(Color.vintageInk)
                    
                    Spacer() // Trycker isär poängen och prickarna
                    
                    // HÄR LÄGGER VI IN PRICKARNA
                    if let bird = quizManager.currentQuestion?.correctBird {
                        streakDots(for: bird)
                    }
                }
                .padding(.horizontal) // Lite luft ut mot kanterna
                .padding(.top)
                
                Spacer()
                
                // BILDEN (I den snygga ramen)
                if let bird = quizManager.currentQuestion?.correctBird {
                    VintagePhotoFrame(image: safeImage(for: bird))
                        .frame(height: 250)
                        .padding(.horizontal, 40)
                        .rotationEffect(.degrees(2))
                }
                
                Spacer()
                
                // SVARSALTERNATIV
                if let question = quizManager.currentQuestion {
                    VStack(spacing: 12) {
                        ForEach(question.options) { bird in
                            VintageOptionButton(
                                text: bird.swedishName,
                                state: buttonState(for: bird),
                                action: { quizManager.submitAnswer(bird) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    
    // --- GAME OVER ---
    var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Bra jobbat!")
                .font(.system(.largeTitle, design: .serif))
                .bold()
                .foregroundStyle(Color.vintageInk)
            
            VStack(spacing: 5) {
                Text("Resultat")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.6))
                Text("\(quizManager.sessionScore) rätt")
                    .font(.system(size: 50, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageAccent)
            }
            
            Spacer()
            
            Button("Spela igen") { quizManager.startQuiz() }
                .buttonStyle(.borderedProminent)
                .tint(Color.vintageAccent)
            
            Button("Huvudmeny") { quizManager.isGameOver = false }
                .buttonStyle(.plain)
                .foregroundStyle(Color.vintageInk)
                .padding(.bottom, 20)
        }
    }
    
    // --- HJÄLPFUNKTIONER ---
    func startQuiz() {
            // Filtrera först baserat på dropdowns
            let filteredBirds = store.birds.filter { bird in
                (selectedHabitat == "Alla" || bird.habitats.contains(selectedHabitat)) &&
                (selectedCategory == "Alla" || bird.broadCategory == selectedCategory)
            }
            
            // Filtrera sedan bort de som saknar bilder
            let birdsWithImages = filteredBirds.filter { $0.imageName != nil }
            
            quizManager.setBirds(birdsWithImages)
            quizManager.startQuiz()
        }
    
    func buttonState(for bird: Bird) -> VintageOptionButton.ButtonState {
        guard let selected = quizManager.selectedBird else { return .neutral }
        if bird.id == quizManager.currentQuestion?.correctBird.id { return .correct }
        if bird.id == selected.id { return .wrong }
        return .disabled
    }
    
    func safeImage(for bird: Bird) -> Image {
        if let imageName = bird.imageName, let uiImage = UIImage(named: imageName) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "bird.fill")
    }
    
    func filterPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
            HStack {
                Text(title).font(.system(.caption, design: .serif)).foregroundStyle(Color.vintageInk)
                Spacer()
                Menu {
                    Picker(title, selection: selection) {
                        ForEach(options, id: \.self) { Text($0).tag($0) }
                    }
                } label: {
                    HStack {
                        Text(selection.wrappedValue).font(.system(.body, design: .serif)).bold()
                        Image(systemName: "chevron.down").font(.caption)
                    }
                    .foregroundStyle(Color.vintageLeather)
                }
            }
        }
    
    func streakDots(for bird: Bird) -> some View {
            let streak = QuizPersistence.shared.getStreak(for: bird.id, mode: .image)
            return HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(i < streak ? Color.vintageAccent : Color.vintageInk.opacity(0.1))
                        .frame(width: 8, height: 8)
                }
            }
        }
}
