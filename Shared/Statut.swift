//Arachante
// michel  le 06/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import Foundation

    enum Statut: Int32, LocalizedError {
        case ras = 0
        case isolé = 1
        case aSupprimer = 2
        case supprimable = 3
        case démissionNotifiée
        case abdicationNotifiée
        
        case autre
        
        var LibelléStatut: (abbreviation:String?, intitulé:String?) {
            switch self {
                case .ras:                return ("", NSLocalizedString("..."           , comment: ""))
                case .isolé:              return ("I", NSLocalizedString("Isolé"         , comment: ""))
                case .aSupprimer:         return ("s", NSLocalizedString("A supprimer"   , comment: ""))
                case .supprimable:        return ("S", NSLocalizedString("Supprimable"   , comment: ""))
                case .autre:              return ("I", NSLocalizedString("Indéterminé"   , comment: ""))
                case .démissionNotifiée:  return ("D", NSLocalizedString("Notification de démission reçue"   , comment: ""))
                case .abdicationNotifiée: return ("A", NSLocalizedString("Notification d'abdication reçue"   , comment: ""))
                }
            }
        
        init() {self = .autre}
        
        }



 


