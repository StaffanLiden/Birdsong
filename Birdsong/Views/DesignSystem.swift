//
//  DesignSystem.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-02.
//

import SwiftUI
import UIKit

// 1. FÄRGER
extension Color {
    static let vintagePaper = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let vintageInk = Color(red: 0.25, green: 0.20, blue: 0.15)
    static let vintageAccent = Color(red: 0.55, green: 0.65, blue: 0.55)
    static let vintageLeather = Color(red: 0.35, green: 0.20, blue: 0.10)
    
    // En ljusare variant för 3D-effekter
    static let vintageLeatherLight = Color(red: 0.45, green: 0.28, blue: 0.15)
}

extension UIColor {
    static let vintagePaper = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
    static let vintageInk = UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)
    static let vintageLeather = UIColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1.0)
}

// 2. TEMA-LOGIK
struct VintageTheme {
    
    static func apply() {
        print("Applicerar Vintage Design...")
        
        // --- 1. TAB BAR ---
                let tabAppearance = UITabBarAppearance()
                tabAppearance.configureWithOpaqueBackground()
                
                // SÄTT BAKGRUND TILL PAPPER (Istället för läder)
                // Eftersom din app verkar köra på papperstemat fullt ut, passar detta bättre.
                tabAppearance.backgroundColor = UIColor.vintagePaper
                
                // Om du vill ha en liten "kant" högst upp på tab-baren för separation:
                tabAppearance.shadowImage = UIImage() // Nollställ först
                tabAppearance.shadowColor = UIColor.vintageInk.withAlphaComponent(0.1) // Svag linje
                
                // FÄRGER FÖR IKONERNA
                
                // EJ vald ikon (Lite genomskinligt bläck)
                let tabUnselected = UIColor.vintageInk.withAlphaComponent(0.7)
                tabAppearance.stackedLayoutAppearance.normal.iconColor = tabUnselected
                tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabUnselected]
                
                // VALD ikon (Mörkt, tydligt bläck)
                let tabSelected = UIColor.vintageInk
                tabAppearance.stackedLayoutAppearance.selected.iconColor = tabSelected
                tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabSelected]
                
                // Applicera
                UITabBar.appearance().standardAppearance = tabAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        
        // --- 2. NAVIGATION BAR (Rubriken) ---
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        
        // Ljus bakgrund (Papper)
        navAppearance.backgroundColor = UIColor.vintagePaper
        navAppearance.shadowColor = .clear // Ingen linje
        
        // TYPSNITT: Vi använder System Serif (New York)
        let largeFont: UIFont
        let smallFont: UIFont
        
        if let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif) {
            largeFont = UIFont(descriptor: descriptor, size: 34)
            smallFont = UIFont(descriptor: descriptor.withSize(17), size: 17)
        } else {
            largeFont = UIFont(name: "Georgia-Bold", size: 34) ?? UIFont.boldSystemFont(ofSize: 34)
            smallFont = UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        }
        
        // Applicera typsnitt och färg
        let largeAttrs: [NSAttributedString.Key: Any] = [
            .font: largeFont,
            .foregroundColor: UIColor.vintageInk
        ]
        
        let smallAttrs: [NSAttributedString.Key: Any] = [
            .font: smallFont,
            .foregroundColor: UIColor.vintageInk
        ]
        
        navAppearance.largeTitleTextAttributes = largeAttrs
        navAppearance.titleTextAttributes = smallAttrs
        
        // Applicera på alla varianter
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = navAppearance
        }
        
        // Tvinga SwiftUI att respektera bakgrundsfärgen
       // UINavigationBar.appearance().backgroundColor = UIColor.vintagePaper //- g1212
        
        // Färga "Back"-knappar
        UINavigationBar.appearance().tintColor = UIColor.vintageInk
    }
    
    // --- HJÄLPFUNKTION: Skapa Läder-effekt ---
    static func createLeatherTextureImage() -> UIImage? {
        let size = CGSize(width: 40, height: 40) // En liten "tile"
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let leatherTile = renderer.image { context in
            let ctx = context.cgContext
            
            // 1. Grundfärg (Mörkbrun)
            UIColor.vintageLeather.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            // 2. Brus/Textur (Simulera läderkorn)
            for _ in 0..<100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let noiseSize = CGFloat.random(in: 0.5...1.5)
                let alpha = CGFloat.random(in: 0.05...0.15)
                
                // Variera mellan lite ljusare och mörkare prickar
                let isLight = Bool.random()
                let noiseColor = isLight ? UIColor.white : UIColor.black
                
                noiseColor.withAlphaComponent(alpha).setFill()
                ctx.fill(CGRect(x: x, y: y, width: noiseSize, height: noiseSize))
            }
            
            // 3. Toppskugga/Highlight för 3D-kant (Endast högst upp)
            // Vi ritar en ljus linje längst upp för att det ska se ut som ljuset träffar kanten
            let topHighlightPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: size.width, height: 1))
            UIColor.white.withAlphaComponent(0.15).setFill()
            topHighlightPath.fill()
            
            // En mörk skugga precis under highlighten
            let topShadowPath = UIBezierPath(rect: CGRect(x: 0, y: 1, width: size.width, height: 1))
            UIColor.black.withAlphaComponent(0.3).setFill()
            topShadowPath.fill()
        }
        
        // Gör bilden töjbar (resizable) men behåll texturen
        return leatherTile.resizableImage(withCapInsets: .zero, resizingMode: .tile)
    }
}
