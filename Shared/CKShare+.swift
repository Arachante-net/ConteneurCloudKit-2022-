//Arachante
// michel  le 09/01/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2022
//

import Foundation
import CloudKit

extension CKShare {
    
     func afficherParticipation() -> String {
// static func afficherParticipationPartage(_ partage:CKShare) -> String {

        var retour = ""
        retour += "proprietaire : \(owner.userIdentity.nameComponents?.givenName ?? "...")"
        retour += "| participant : \(currentUserParticipant?.userIdentity.nameComponents?.givenName ?? "...")"
        retour += "| équipe : "

        participants.forEach {
            retour += $0.userIdentity.nameComponents?.givenName ?? "..." + ", "
            }
        return retour
        }
    
    }


