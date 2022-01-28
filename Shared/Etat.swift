//Arachante
// michel  le 08/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import Foundation
import SwiftUI
import Combine

// Pas utilisé ici (pour l'instant)

/// Pour une navigation basée sur l'Etat de l'appli
class Etat: ObservableObject {
    @Published var selection:Int = 2
    @Published var detailler:Bool = false
    @Published var itemCourant: String? = nil

var subscription = Set<AnyCancellable>()
    
init () {
    $detailler
        .filter({ !$0 })
        .removeDuplicates()
        .sink { [unowned self] value in
            self.itemCourant = nil
        }.store(in: &subscription)
}

    
    }

// Un exemple d'utilisation ici :
// https://www.youtube.com/watch?v=vL0w3kvng0o
//@EnvironmentObject var état:Etat
//état.itemCourant = ...
//    .EnvironmentObject(Etat())
