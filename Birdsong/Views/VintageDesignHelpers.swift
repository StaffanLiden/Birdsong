//
//  VintageOptionButton.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-02.
//


import SwiftUI

// En snygg svarsknapp som ser ut som en papperslapp
struct VintageOptionButton: View {
    let text: String
    var state: ButtonState = .neutral
    let action: () -> Void
    
    enum ButtonState {
        case neutral, correct, wrong, disabled
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(.title3, design: .serif)) // Serif för bokkänslan
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(4) // Lite kantiga hörn, som klippt papper
                .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1) // Liten skugga
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .disabled(state != .neutral)
    }
    
    // Logik för färger beroende på rätt/fel svar
    private var backgroundColor: Color {
        switch state {
        case .neutral: return Color.white.opacity(0.6)
        case .correct: return Color.green.opacity(0.2) // Dämpad grön
        case .wrong: return Color.red.opacity(0.2)     // Dämpad röd
        case .disabled: return Color.white.opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .neutral: return .vintageInk.opacity(0.1)
        case .correct: return .green.opacity(0.5)
        case .wrong: return .red.opacity(0.5)
        case .disabled: return .vintageInk.opacity(0.05)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .neutral, .disabled: return .vintageInk
        case .correct: return Color(red: 0.1, green: 0.4, blue: 0.1) // Mörkgrön text
        case .wrong: return Color(red: 0.6, green: 0.2, blue: 0.2)   // Mörkröd text
        }
    }
}