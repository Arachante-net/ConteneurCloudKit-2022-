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
        
        case itemSansPrincipal(item:String)
        case itemSansTitre
        case itemSansID
        
        case groupeSansPrincipal
        case groupeSansNom
        case groupeSansID
        case groupeInvalide
        
        case incoherenceDesPrincipaux
        
        case erreurAPreciser
        
        var errorDescription: String? {
            switch self {
                case .caractereInvalide:          return NSLocalizedString("C'est quoi ce caractere ?"            , comment: "")
                case .erreurInterne:              return NSLocalizedString("Erreur interne, reinstallez l'appli !", comment: "")
                case .trucQuiVaPas(num: let num): return NSLocalizedString("Y-a le truc \(num) qui cloche ..."    , comment: "")
                
                case .itemSansPrincipal(item: let item):          return NSLocalizedString("Item \(item) sans Groupe referent (Principal)", comment: "Pourquoi pas")
                case .itemSansTitre:              return NSLocalizedString("Item sans Titre"                      , comment: "")
                case .itemSansID:                 return NSLocalizedString("Item sans Identifiant"                         , comment: "")

                case .groupeSansPrincipal:        return NSLocalizedString("Groupe sans Item délégué (Principal)"          , comment: "C'est grave")
                case .groupeSansNom:              return NSLocalizedString("Groupe sans Nom"                      , comment: "")
                case .groupeSansID:               return NSLocalizedString("Groupe sans ID"                       , comment: "")
                case .groupeInvalide:             return NSLocalizedString("Groupe Invalide"                      , comment: "")
                case .incoherenceDesPrincipaux:   return NSLocalizedString("Le lien entre les principaux n'est pas symetrique", comment: "")
                case .erreurAPreciser:            return NSLocalizedString("", comment:"")
            }
        }
        }

struct ErrorType: Identifiable {
    let id = UUID()
    let error : Nimbus
    
    init(_ erreur: Nimbus) { error = erreur }
    
    }

    enum Stratus: Error {
        case overflow
        case invalide(Character)
        }

    


// throw Nimbus.trucQuiVaPas(num: 5)

