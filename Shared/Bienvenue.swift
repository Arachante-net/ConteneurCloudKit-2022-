//Arachante
// michel  le 01/02/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.2
//
//  2022
//

import SwiftUI

struct Bienvenue: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .primary, .accentColor, .secondary, .black]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack {
                Text("Bienvenue")
//                    .font(.system(size: 64, weight: .bold, design: .rounded))
//                    .shadow(color: .white, radius: 2, x: 0.5, y: 0.5) //.largeTitle)
                      .font( .custom("Myst Linking Book", size: 64)    )  // "PermanentMarker-Regular" "Myst Linking Book" "Marayani Roman Light"
                      .shadow(color: .orange, radius: 2, x: 0.5, y: 0.5)

                Text("⇠ ⇠ Choisissez un événement dans le menu de gauche.")
                    .foregroundColor(.secondary)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                //  .font(.custom("Georgia", size: 24, relativeTo: .headline))

                }
            .padding()
            }
        }
    }

struct Bienvenue_Previews: PreviewProvider {
    static var previews: some View {
        Bienvenue()
    }
}
