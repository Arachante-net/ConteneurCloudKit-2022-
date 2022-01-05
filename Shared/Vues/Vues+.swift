//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import Foundation
import SwiftUI

extension View {
    
    /// Masquer ou afficher une vue en fonction d'un booléen
    ///
    /// Exemples :
    ///
    ///     Text("Bonjour")
    ///         .isHidden(true)
    ///
    ///     Text("Re Bonjour !")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden:  `false` pour garder la Vue visible. `true` pour cacher la Vue.
    ///   - remove: Booléen indiquant s'il faut ou non supprimer la vue.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden { if !remove { self.hidden() } }
        else { self }
        }
}
