//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import SwiftUI

struct Indicateur: View {
    
    var libellé:String?
    var valeur:String
    var neutre:Bool = false
    
    init (_ libellé:String?, valeur:Statut) {
        self.libellé = libellé
        self.valeur = valeur.LibelléStatut.abbreviation ?? "␀"
        }
    
    init (_ libellé:String?, valeur:String) {
        self.libellé = libellé
        self.valeur = valeur
        }
    
    init (_ libellé:String?, valeur:String?) {
        self.libellé = libellé
        self.valeur = valeur ?? "␀"
        }
    
    init (_ libellé:String?, valeur:Bool) {
        self.libellé = libellé
        self.valeur = valeur ? "✔︎" : "❌"
        }
    
    init (_ libellé:String?, valeur:Int) {
        self.libellé = libellé
        self.valeur = String(valeur)
        }
    
    var body: some View {
        HStack {
//            Text(" \(libellé ?? "")")
//                .foregroundColor(.secondary)
//                .lineLimit(1)
//                .truncationMode(.tail)
            Text(valeur)
                .foregroundColor( neutre ? .secondary : .accentColor)
                .padding(.horizontal)
                .frame( alignment: .center)
                .lineLimit(1)
                .truncationMode(.middle)
                
        } .clipShape(Circle() )
            .overlay( Circle()
                .strokeBorder(.primary, lineWidth: 0.1)
                )
        }
    
    
    
    
    struct Indicateur_Previews: PreviewProvider {
        static var previews: some View {
            Indicateur("", valeur: .supprimable)
        }
    }
}


