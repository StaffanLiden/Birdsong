import SwiftUI

@main
struct BirdsongApp: App {
    @StateObject private var store = BirdStore()

    init() {
        setupVintageAppearance()
    }
    
    func setupVintageAppearance() {
        // --- 1. TAB BAR (Menyn längst ner) ---
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.vintageLeather
        
        let tabUnselected = UIColor.vintagePaper.withAlphaComponent(0.6)
        let tabSelected = UIColor.vintagePaper
        
        tabAppearance.stackedLayoutAppearance.normal.iconColor = tabUnselected
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tabUnselected]
        
        tabAppearance.stackedLayoutAppearance.selected.iconColor = tabSelected
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: tabSelected]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // --- 2. NAVIGATION BAR (Rubriken högst upp) ---
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        
        // Sätt bakgrundsfärgen till pappersfärg
        navAppearance.backgroundColor = UIColor.vintagePaper
        
        // Ta bort den tunna grå linjen (Shadow)
        navAppearance.shadowColor = .clear
        navAppearance.shadowImage = UIImage()
        
        // --- TYPSNITT (FONTS) ---
        // Vi försöker hämta systemets Serif-font (New York), annars tar vi Georgia (som ser snarlik ut)
        let largeFont: UIFont
        let smallFont: UIFont
        
        if let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif) {
            largeFont = UIFont(descriptor: descriptor, size: 34)
            smallFont = UIFont(descriptor: descriptor, size: 17)
        } else {
            largeFont = UIFont(name: "Georgia-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)
            smallFont = UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        
        // Applicera typsnitt och färg (Bläck) på rubrikerna
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: smallFont,
            .foregroundColor: UIColor.vintageInk
        ]
        
        let largeTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: largeFont,
            .foregroundColor: UIColor.vintageInk
        ]
        
        navAppearance.titleTextAttributes = titleAttrs
        navAppearance.largeTitleTextAttributes = largeTitleAttrs
        
        // Applicera på ALLA lägen för att vara säker
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Detta gör att "tillbaka"-knappen också får rätt färg (Bläck)
        UINavigationBar.appearance().tintColor = UIColor.vintageInk
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
