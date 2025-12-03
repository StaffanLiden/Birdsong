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
}

extension UIColor {
    static let vintagePaper = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
    static let vintageInk = UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)
    static let vintageLeather = UIColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1.0)
}

// 2. TEMA-LOGIK
struct VintageTheme {
    
    static func apply() {
        print("🎨 Applicerar Vintage Design...")
        
        // --- 1. TAB BAR (Menyn i botten) ---
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        
        // Mörk bakgrund (Läder)
        tabAppearance.backgroundColor = UIColor.vintageLeather
        
        // EJ vald ikon: Lite genomskinligt papper
        let tabUnselected = UIColor.vintagePaper.withAlphaComponent(0.5)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = tabUnselected
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabUnselected]
        
        // VALD ikon: Helt vitt papper
        let tabSelected = UIColor.vintagePaper
        tabAppearance.stackedLayoutAppearance.selected.iconColor = tabSelected
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabSelected]
        
        // Applicera på alla varianter
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // --- 2. NAVIGATION BAR (Rubriken) ---
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        
        // Ljus bakgrund (Papper)
        navAppearance.backgroundColor = UIColor.vintagePaper
        navAppearance.shadowColor = .clear // Ingen linje
        
        // Hårdkoda typsnittet till Georgia-Bold för att vara säker
        // Om Georgia inte hittas (osannolikt), tar vi systemfonten.
        let serifFontLarge = UIFont(name: "Georgia-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        let serifFontSmall = UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        
        // Applicera typsnitt och färg
        let largeAttrs: [NSAttributedString.Key: Any] = [
            .font: serifFontLarge,
            .foregroundColor: UIColor.vintageInk
        ]
        
        let smallAttrs: [NSAttributedString.Key: Any] = [
            .font: serifFontSmall,
            .foregroundColor: UIColor.vintageInk
        ]
        
        navAppearance.largeTitleTextAttributes = largeAttrs
        navAppearance.titleTextAttributes = smallAttrs
        
        // Applicera på alla varianter
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Färga "Back"-knappar och länkar mörka
        UINavigationBar.appearance().tintColor = UIColor.vintageInk
    }
}
