//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI

struct Etiquette: View {
    
    var libellé:String
    var valeur:String
    var neutre:Bool = false
    
    init (_ libellé:String, valeur:String) {
        self.libellé = libellé
        self.valeur = valeur
        }
    
    init (_ libellé:String, valeur:String?) {
        self.libellé = libellé
        self.valeur = valeur ?? "␀"
        }
    
    init (_ libellé:String, valeur:Bool) {
        self.libellé = libellé
        self.valeur = valeur ? "✔︎" : "✖️"
        }
    
    init (_ libellé:String, valeur:Int) {
        self.libellé = libellé
        self.valeur = String(valeur)
        }
    
    var body: some View {
        HStack {
            Text(" \(libellé) : ")
                .foregroundColor(.secondary)
            Text(valeur)
                .foregroundColor( neutre ? .secondary : .accentColor)
                .padding(.horizontal)
                
        } .clipShape(Capsule() )
            .overlay( Capsule()
                .strokeBorder(.primary, lineWidth: 0.1)
                )
        }
}


