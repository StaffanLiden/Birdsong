import SwiftUI

struct ImageQuizView: View {
    @EnvironmentObject var store: BirdStore
    @StateObject private var quizManager = QuizManager(birds: [])
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.vintagePaper.ignoresSafeArea()
                
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
            // En liten hög med bilder som ikon
            ZStack {
                VintagePhotoFrame(image: Image(systemName: "bird.fill"))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-10))
                VintagePhotoFrame(image: Image(systemName: "leaf.fill"))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(5))
            }
            
            VStack(spacing: 8) {
                Text("Bildquiz")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.vintageInk)
                Text("Känner du igen arten?")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.vintageInk.opacity(0.7))
            }
            
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
            Text("Poäng: \(quizManager.sessionScore)")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(Color.vintageInk)
                .padding(.top)
            
            Spacer()
            
            // BILDEN (I den snygga ramen)
            if let bird = quizManager.currentQuestion?.correctBird {
                VintagePhotoFrame(image: safeImage(for: bird))
                    .frame(height: 250) // Anpassa storleken
                    .padding(.horizontal, 40)
                    .rotationEffect(.degrees(2)) // Lite lekfull lutning
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
        let birdsWithImages = store.birds.filter { $0.imageName != nil }
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
}
