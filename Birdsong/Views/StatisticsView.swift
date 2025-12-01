//
//  StatisticsView.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-01.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: BirdStore
    
    // Istället för bara siffror, sparar vi nu listor med fåglar för varje nivå
    @State private var birdsByLevel: [Int: [Bird]] = [:]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Rubrik
                    VStack(spacing: 10) {
                        Text("Dina Framsteg")
                            .font(.largeTitle)
                            .bold()
                        Text("Totalt \(store.birds.count) arter i databasen")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // Cirkeldiagram (Total % klarade)
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.1)
                            .foregroundColor(.blue)
                        
                        Circle()
                            .trim(from: 0.0, to: progressPercentage)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.blue)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: progressPercentage)
                        
                        VStack {
                            Text(String(format: "%.0f%%", min(progressPercentage, 1.0) * 100.0))
                                .font(.system(size: 50, weight: .bold))
                            Text("Avklarade")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .padding()
                    
                    // Detaljerad lista (Nu med utfällbara rader)
                    VStack(alignment: .leading, spacing: 0) { // Spacing 0 för att det ska se ut som en sammanhängande lista
                        HStack {
                            Text("Detaljer")
                                .font(.headline)
                            Spacer()
                            Text("Klicka för att se arter")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        // Nivå 3: Mästerlig
                        ExpandableStatRow(
                            title: "Mästerlig (Klar)",
                            birds: birdsByLevel[3] ?? [],
                            color: .yellow,
                            icon: "star.fill"
                        )
                        
                        Divider()
                        
                        // Nivå 2: På god väg
                        ExpandableStatRow(
                            title: "På god väg (2 rätt)",
                            birds: birdsByLevel[2] ?? [],
                            color: .green,
                            icon: "circle.fill"
                        )
                        
                        Divider()
                        
                        // Nivå 1: Nybörjare
                        ExpandableStatRow(
                            title: "Nybörjare (1 rätt)",
                            birds: birdsByLevel[1] ?? [],
                            color: .green.opacity(0.5),
                            icon: "circle.fill"
                        )
                        
                        Divider()
                        
                        // Nivå 0: Olärt
                        ExpandableStatRow(
                            title: "Olärt / 0 streak",
                            birds: birdsByLevel[0] ?? [],
                            color: .gray.opacity(0.3),
                            icon: "circle"
                        )
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Statistik")
            .onAppear {
                calculateStats()
            }
        }
    }
    
    // Räkna ut procent (baserat på nivå 3)
    var progressPercentage: Double {
        let learnedCount = Double(birdsByLevel[3]?.count ?? 0)
        let total = Double(store.birds.count)
        guard total > 0 else { return 0 }
        return learnedCount / total
    }
    
    // Sortera in fåglarna i rätt "låda" baserat på deras streak
    func calculateStats() {
        var newMap: [Int: [Bird]] = [0: [], 1: [], 2: [], 3: []]
        
        for bird in store.birds {
            let streak = QuizPersistence.shared.getStreak(for: bird.id)
            // Om streak är > 3 räknas den ändå till nivå 3
            let level = min(streak, 3)
            newMap[level]?.append(bird)
        }
        
        self.birdsByLevel = newMap
    }
}

// En ny sub-view för att hantera varje rad och dess "utfällda" läge
struct ExpandableStatRow: View {
    let title: String
    let birds: [Bird]
    let color: Color
    let icon: String
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Huvudraden (Klickbar)
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .frame(width: 30)
                    
                    Text(title)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(birds.count) st")
                        .bold()
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.leading, 5)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Listan som visas när man fäller ut
            if isExpanded {
                if birds.isEmpty {
                    Text("Inga fåglar här än.")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.5))
                } else {
                    // HÄR ÄR FIXEN: Vi anger "\Bird.id" explicit
                    ForEach(birds) { bird in
                        HStack {
                            // Ändrat från bird.name till bird.swedishName
                            Text(bird.swedishName)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.5))
                        
                        Divider()
                    }
                }
            }
        }
    }
}
