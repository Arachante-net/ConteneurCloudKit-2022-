//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
//
//  2021
//

import SwiftUI

struct Voyant: View {
    
    var libellé:String
   
    enum Etat {
        typealias RawValue = Color
        
        case activé
        case desactivé
        case neutre
    
        var couleur:Color {
            switch self {
                case .activé:    return Color(red: 0.4627, green: 0.8392, blue: 1.0)
                case .desactivé: return Color(hue: 0.1639, saturation: 1, brightness: 1)
                case .neutre:    return Color(white: 0.4745)
                }
            }
        }
    
    var état:Etat
    
    var body: some View {
        HStack {
            Text(" \(libellé) :")
                .foregroundColor(.secondary)
                
            Circle()
                .fill(état.couleur)
                .clipShape(Circle())
                .overlay( Circle()
                    .strokeBorder(.primary, lineWidth: 0.5)
                    )
                .frame(width: 20, height: 20)
                
        } .clipShape(Capsule() )
            .overlay( Capsule()
                .strokeBorder(.primary, lineWidth: 0.1)
                )
        }
}

struct Indicateur_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
        Voyant(libellé: "oui", état: .activé)
        Voyant(libellé: "non", état: .desactivé)
        Voyant(libellé: "bof", état: .neutre)
        }
    }
}
