import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Bakgrund
            Color(red: 0.87, green: 0.81, blue: 0.68)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Rubrik
                Text("Så funkar spelet")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.vintageInk)
                    .padding(.top, 20)
                
                Divider()
                    .background(Color.vintageInk.opacity(0.3))
                    .padding(.horizontal, 40)
                
                // Instruktioner
                VStack(alignment: .leading, spacing: 20) {
                    instructionRow(icon: "music.mic.circle.fill", text: "Lyssna på fågelns läte eller titta på bilden.")
                    instructionRow(icon: "checkmark.circle.fill", text: "Gissa rätt för att samla poäng.")
                    
                    // Förklaring av streak
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 4) {
                            Circle().fill(Color.vintageAccent).frame(width: 12, height: 12)
                            Circle().fill(Color.vintageAccent).frame(width: 12, height: 12)
                            Circle().fill(Color.vintageAccent).frame(width: 12, height: 12)
                        }
                        .padding(.top, 4)
                        
                        Text("Svara rätt 3 gånger i rad på samma fågel för att bemästra den. En miss tar bort din streak!")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(.vintageInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    instructionRow(icon: "book.closed.fill", text: "Kolla dina framsteg i Loggboken.")
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Stäng-knapp
                Button(action: { dismiss() }) {
                    Text("Jag förstår")
                        .font(.system(.title3, design: .serif))
                        .bold()
                        .foregroundColor(.vintagePaper)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(Color.vintageLeather)
                        .cornerRadius(25)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // Hjälpfunktion för rader
    func instructionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.vintageLeather)
                .frame(width: 30)
            
            Text(text)
                .font(.system(.body, design: .serif))
                .foregroundColor(.vintageInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    HelpView()
}