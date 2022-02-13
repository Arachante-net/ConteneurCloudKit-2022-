//Arachante
// michel  le 05/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import SwiftUI

struct VueValeurItemPrincipal_2: View {
    
@EnvironmentObject private var persistance : ControleurPersistance

//@Binding var item: Item
@ObservedObject var groupe: Groupe
//    @Binding  var groupe_2: Groupe


 
    func incrementer() {
        groupe.principal?.valeur += 1
//         if value >= colors.count { value = 0 }
//        persistance.sauverContexte("Item")
     }

     func decrementer() {
         groupe.principal?.valeur -= 1
//         if value < 0 { value = colors.count - 1 }
//         persistance.sauverContexte("Item")
     }
    
    var body: some View {
        Stepper { Text("Valeur principale : ")
            + Text(" \(groupe.principal?.valeur ?? 0)")
                .bold()
                .font(.title)
                .foregroundColor(Color.accentColor)
            }
            onIncrement: { incrementer() }
            onDecrement: { decrementer() }
            .padding(.leading)
            .onChange(of: groupe.principal?.valeur) { val in
                print("☑️ ----\(val ?? 0)----")
                //FIXME : !! Y-a vraiment besoin de cette bidouille ??
                groupe.integration.toggle() //+= 1 // pour se rafraichir
                
                persistance.sauverContexte("Item")
                }
    }
}


