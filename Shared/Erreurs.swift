//Arachante
// michel  le 06/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import Foundation

    enum Nimbus: Error, LocalizedError {
        case caractereInvalide
        case trucQuiVaPas(num : Int)
        case erreurInterne
        
        var errorDescription: String? {
            switch self {
                case .caractereInvalide:          return NSLocalizedString("C'est quoi ce caractere ?", comment: "")
                case .erreurInterne:              return NSLocalizedString("Erreur interne, reinstallez l'appli !", comment: "")
                case .trucQuiVaPas(num: let num): return NSLocalizedString("Y-a le truc \(num) qui cloche ...", comment: "")
            }
        }
        }

struct ErrorType: Identifiable {
    let id = UUID()
    let error : Nimbus
    }

    enum Stratus: Error {
        case overflow
        case invalide(Character)
        }

    


// throw Nimbus.trucQuiVaPas(num: 5)
