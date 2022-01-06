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

@ObservedObject var item: Item
@ObservedObject var groupe: Groupe

 
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
    
    var body: some View {
        Stepper { Text("Valeur : \(item.valeur) ") }
            onIncrement: { incrementer() }
            onDecrement: { decrementer() }
            .padding(.leading)
            .onChange(of: item.valeur) { val in
                print("☑️ ----\(val)----")
                groupe.integration.toggle() //+= 1 // pour se rafraichir
                persistance.sauverContexte("Item")
//                ListeGroupe.rafraichir.toggle()
                }
    }
}


