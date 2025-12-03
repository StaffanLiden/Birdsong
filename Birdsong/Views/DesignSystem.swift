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
        
        // EJ vald ikon
        let tabUnselected = UIColor.vintagePaper.withAlphaComponent(0.5)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = tabUnselected
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabUnselected]
        
        // VALD ikon
        let tabSelected = UIColor.vintagePaper
        tabAppearance.stackedLayoutAppearance.selected.iconColor = tabSelected
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabSelected]
        
        // Applicera
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // FIXEN FRÅN CHATGPT: Tvinga bakgrundsfärgen
        UITabBar.appearance().backgroundColor = UIColor.vintageLeather
        UITabBar.appearance().tintColor = UIColor.vintagePaper // För säkerhets skull
        
        
        // --- 2. NAVIGATION BAR (Rubriken) ---
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        
        // Ljus bakgrund (Papper)
        navAppearance.backgroundColor = UIColor.vintagePaper
        navAppearance.shadowColor = .clear // Ingen linje
        
        // TYPSNITT: Vi använder System Serif (New York) för att matcha Ljudquiz exakt
        // Detta är säkrare och snyggare än att hårdkoda Georgia
        let largeFont: UIFont
        let smallFont: UIFont
        
        if let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif) {
            largeFont = UIFont(descriptor: descriptor, size: 34)
            smallFont = UIFont(descriptor: descriptor.withSize(17), size: 17)
        } else {
            // Fallback till Georgia om system serif saknas
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
        
        // NYCKELN TILL LÖSNINGEN (Samma princip som för Tab Bar)
        // Tvinga SwiftUI att respektera bakgrundsfärgen även i NavigationStack
        UINavigationBar.appearance().backgroundColor = UIColor.vintagePaper
        
        // Färga "Back"-knappar
        UINavigationBar.appearance().tintColor = UIColor.vintageInk
    }
}
