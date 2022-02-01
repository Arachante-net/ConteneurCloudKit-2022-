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
            LinearGradient(gradient: Gradient(colors: [.primary, .accentColor, .secondary]), startPoint: .top, endPoint: .bottom)
        VStack {
            Text("Bienvenue").font(.largeTitle)
            Text("⬅️ Choisissez un événement dans le menu de gauche.").foregroundColor(.secondary)
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
