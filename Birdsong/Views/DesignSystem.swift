//
//  DesignSystem.swift
//  Birdsong
//
//  Created by Staffan Liden on 2025-12-02.
//


import SwiftUI
import UIKit

// 1. SwiftUI-färgerna (Dessa använder vi i vyerna)
extension Color {
    static let vintagePaper = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let vintageInk = Color(red: 0.25, green: 0.20, blue: 0.15)
    static let vintageAccent = Color(red: 0.55, green: 0.65, blue: 0.55)
    static let vintageLeather = Color(red: 0.35, green: 0.20, blue: 0.10)
}

// 2. UIKit-färgerna (Dessa använder vi BARA för meny-inställningarna i BirdsongApp)
extension UIColor {
    static let vintagePaper = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
    static let vintageInk = UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)
    static let vintageLeather = UIColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1.0)
    //static let vintageInk = Color(red: 0.25, green: 0.20, blue: 0.15)
}
