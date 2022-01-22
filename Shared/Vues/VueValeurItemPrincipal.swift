//Arachante
// michel  le 05/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import SwiftUI

struct VueValeurItemPrincipal: View {
    
@EnvironmentObject private var persistance : ControleurPersistance

    //FIXME: @State ?  ou même inexistant  remplacer par groupe.principal
@ObservedObject var item: Item
/// Groupe en cours d'edition, propriété de VueDetailGroupe
@ObservedObject var groupe: Groupe

 

    
    var body: some View {
        Stepper { Text("Valeur principale : ")
                + Text(" \(item.valeur)")
                    .bold()
                    .font(.title)
                    .foregroundColor(Color.accentColor)
            }
            onIncrement: { incrementer() }
            onDecrement: { decrementer() }
            .padding(.leading)
            .onChange(of: item.valeur) { val in
                print("☑️ Nouvele valeur \(val)")
                //FIXME: !! Y-a vraiment besoin de cette bidouille ??
                // Comment avoir la valeur du Stepper affichée en direct (et sauvegardée)
                // Honte sur moi, je ne trouve pas le mecanisme élegant pour réamiser cela
                groupe.integration.toggle() 
                
                persistance.sauverContexte("Item")
                }
    }

    
    
//MARK: -
    func incrementer() {
        item.valeur += 1
//         if value >= colors.count { value = 0 }
//        persistance.sauverContexte("Item")
     }

     func decrementer() {
         item.valeur -= 1
//         if value < 0 { value = colors.count - 1 }
//         persistance.sauverContexte("Item")
     }



}


