//
//  StartView.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-12.
//


import SwiftUI

struct StartView: View {
    // En callback-funktion för att tala om för ContentView att vi är klara
    var onStart: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // 1. BAKGRUNDSBILDEN
            Image("StartImage") // Se till att bilden heter exakt så i Assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 2. INNEHÅLL (Knappen)
            VStack {
                Spacer() // Tryck ner knappen mot botten
                
                Button(action: {
                    // Animera övergången bort från startsidan
                    withAnimation(.easeIn(duration: 0.5)) {
                        onStart()
                    }
                }) {
                    Text("Start")
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.vintagePaper) // Ljus text
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(
                            Color.vintageLeather // Mörk bakgrund
                                .opacity(0.9)
                        )
                        .cornerRadius(30)
                        // En snygg dubbel ram-effekt
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.vintagePaper.opacity(0.5), lineWidth: 1)
                                .padding(4)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 60) // Justera avståndet från kanten
                .opacity(isVisible ? 1 : 0) // Fade-in på knappen
                .offset(y: isVisible ? 0 : 20) // Glid in underifrån
            }
        }
        .onAppear {
            // Starta animationen när vyn visas
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                isVisible = true
            }
        }
    }
}
