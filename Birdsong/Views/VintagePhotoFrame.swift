import SwiftUI

struct VintagePhotoFrame: View {
    let image: Image
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fotot med vit kant och skugga
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(6) // Vit ram runt bilden
                .background(Color(white: 0.98))
                .shadow(color: .black.opacity(0.15), radius: 3, x: 2, y: 2)
            
            // Tejpbiten
            Rectangle()
                .fill(Color(red: 0.9, green: 0.85, blue: 0.7, opacity: 0.7)) // Halvgenomskinlig beige
                .frame(width: 35, height: 12)
                .rotationEffect(.degrees(-25))
                .offset(x: -8, y: -6)
                .overlay(
                    Rectangle().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}
