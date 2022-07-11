//Arachante
// michel  le 02/07/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import SwiftUI

struct BarreStatut: View {

    @State  var coherent: Bool
    @State  var statut: Statut
    @State  var valide: Bool
    


    
    var body: some View {
        HStack {
            Indicateur("S", valeur: statut)
            Indicateur("V", valeur: valide)
            Indicateur("B", valeur: true)
            }
}

struct BarreStatut_Previews: PreviewProvider {
    static var previews: some View {
        BarreStatut(coherent: true, statut: .abdicationNotifiée, valide: false)
    }
}
}
