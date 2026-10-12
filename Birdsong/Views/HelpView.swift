import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    // Styr om vi visar hjälp för "Fri träning" eller "Banan"
    var isFreePlay: Bool
    
    var body: some View {
        ZStack {
            // 1. Bakgrund från DesignSystem
            Color.vintagePaper
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Rubrik
                    Text(isFreePlay ? "Fri Träning" : "Så funkar spelet")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.vintageInk) // DesignSystem
                        .padding(.top, 40)
                    
                    Divider()
                        .background(Color.vintageInk.opacity(0.3)) // DesignSystem
                        .padding(.horizontal, 40)
                    
                    if isFreePlay {
                        freePlayContent
                    } else {
                        levelModeContent
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Stäng-knapp
                    Button(action: { dismiss() }) {
                        Text("Jag förstår")
                            .font(.system(.title3, design: .serif))
                            .bold()
                            .foregroundColor(.vintagePaper) // DesignSystem
                            .padding(.vertical, 12)
                            .padding(.horizontal, 40)
                            .background(Color.vintageLeather) // DesignSystem
                            .cornerRadius(25)
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Innehåll för Banan (Level Mode)
    var levelModeContent: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            // 1. Progression (Stationer)
            helpSection(title: "Silver & Guld") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Varje station har två nivåer:")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk) // DesignSystem
                    
                    HStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.gray) // Systemfärg för "Silver"
                        Text("Silver: Du får se bild och höra ljud. Klarar du detta får du en Silverstjärna.")
                            .font(.system(.callout, design: .serif))
                            .foregroundColor(.vintageInk) // DesignSystem
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.orange) // Systemfärg för "Guld"
                        Text("Guld: Låses upp när du tagit Silver. Här hör du enbart ljudet – för de riktiga experterna!")
                            .font(.system(.callout, design: .serif))
                            .foregroundColor(.vintageInk) // DesignSystem
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // 2. Mästarstatus (3 prickar)
            helpSection(title: "Bli en mästare") {
                HStack(alignment: .top, spacing: 16) {
                    // Visualisering av 3 fyllda cirklar
                    HStack(spacing: 4) {
                        Circle().fill(Color.vintageAccent).frame(width: 14, height: 14) // DesignSystem
                        Circle().fill(Color.vintageAccent).frame(width: 14, height: 14)
                        Circle().fill(Color.vintageAccent).frame(width: 14, height: 14)
                    }
                    .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Svara rätt 3 gånger i rad på en fågel för att bemästra den.")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.vintageInk) // DesignSystem
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // 3. Straffregeln (Se upp!)
            helpSection(title: "Se upp för felgissningar!") {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.vintageLeather) // DesignSystem
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Om du gissar fel händer två saker:")
                            .font(.system(.body, design: .serif))
                            .bold()
                            .foregroundColor(.vintageInk) // DesignSystem
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. Rätt fågel nollställs helt (du tappar alla prickar).")
                            Text("2. Fågeln du gissade på tappar en prick.")
                        }
                        .font(.system(.callout, design: .serif))
                        .foregroundColor(.vintageInk.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // 4. Låsa upp nästa bana
            helpSection(title: "Komma vidare") {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "lock.open.fill")
                        .font(.title2)
                        .foregroundColor(.vintageAccent) // DesignSystem (Istället för grön)
                    
                    Text("När du bemästrat 7 av 10 fåglar får du din Silverstjärna och nästa station på kartan låses upp.")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk) // DesignSystem
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Innehåll för Fri Träning
    var freePlayContent: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            helpSection(title: "Öva utan press") {
                HStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundColor(.vintageAccent) // DesignSystem
                    Text("Här kan du träna fritt. Inga poäng sparas och du kan aldrig åka ut.")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk)
                }
            }
            
            helpSection(title: "Filtrera") {
                HStack(spacing: 16) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.vintageInk)
                    Text("Välj specifika områden eller fågelfamiljer för att öva på just det du tycker är svårt.")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk)
                }
            }
            
            helpSection(title: "Svårare läge") {
                HStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.vintageLeather)
                    Text("Slå på 'Svårare' för att få svarsalternativ från samma familj. Perfekt för att lära sig se skillnad på liknande arter!")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(.vintageInk)
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Hjälpkomponent
    func helpSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.vintageLeather) // DesignSystem
            
            content()
        }
        .padding()
        // Använder vit med transparens för att skapa en "kort"-effekt mot pappersbakgrunden
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.vintageInk.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Level Mode") {
    HelpView(isFreePlay: false)
}

#Preview("Free Play") {
    HelpView(isFreePlay: true)
}
