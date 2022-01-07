//Arachante
// michel  le 30/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

//import Foundation
import CloudKit
import UIKit

class Utilisateur : ObservableObject {
    
    init() {
//        let TT = UIDevice.current.identifierForVendor?.uuidString
    UserDefaults.standard.set(UIDevice.current.identifierForVendor?.uuidString, forKey: "UID")
    statuer()
    }
    
    
    
    
    func obtenirID() -> String  {
        
        //throw Nimbus.trucQuiVaPas(num: 5)

        let nom         = NSUserName()
        let nomComplet  = NSFullUserName()
        let _           = UIDevice.current.systemName
        let nomAppareil = UIDevice.current.name
        let idAppareil  = UIDevice.current.identifierForVendor
        return idAppareil?.uuidString ?? ""
        }

    var leStatut:String=""
    
    func statuer(_ Statut :CKAccountStatus) -> String {
        switch Statut {
            case .available:
                return "iCloud est disponible"
            case .noAccount:
                return "Pas de compte iCloud"
            case .restricted:
                return "Accés iCloud restreints"
            case .couldNotDetermine:
                return "Status iCloud indeterminé"
            default:
                return "iCloud est indisponible !"
            }
        }
    
    func statuer() {
        
        CKContainer.init(identifier: "iCloud.Arachante.Espoir").accountStatus { [self] (accountStatus, error) in
            leStatut = self.statuer(accountStatus)
            }
    }
    
    func isICloudContainerAvailable()->Bool {
        
//        let conteneur = CKContainer.default() // Bad Container" (1014)
//        let conteneur = CKContainer.init(identifier: "net.arachante.ConteneurCloudKit") // Bad Container" (1014)
          let conteneur = CKContainer.init(identifier: "iCloud.Arachante.Espoir")

            conteneur.accountStatus { (accountStatus, error) in
                switch accountStatus {
                    case .available:
                        print("=== iCloud est disponible")
                    case .noAccount:
                        print("=== Pas de compte iCloud")
                    case .restricted:
                        print("=== Accés iCloud restreints")
                    case .couldNotDetermine:
                        print("=== Status iCloud indeterminé")
                    default:
                        print("=== iCloud est indisponible !")
                    }
                }
         
            conteneur.fetchUserRecordID { (recordId, error) in
                if error != nil {
                    print("===  iCloud Erreur conteneur CloudKit !!! ", error ?? "")
                    }
                else {
                    print("=== iCloud ID :", recordId ?? "...",
                          "Nom :"  , recordId?.recordName ?? "...",
                          "id Zone :" , recordId?.zoneID     ?? "...")

                    // userDiscoverability
                    conteneur.requestApplicationPermission(.userDiscoverability) { (status, error) in
                        print("=== Status", status)
                        print("=== Erreur", error?.localizedDescription ?? "...")

                        conteneur.discoverUserIdentity(withUserRecordID: recordId!, completionHandler: { (userID, error) in
                          print("=== Erreur", error ?? "")
                          print("=== contacts", userID?.contactIdentifiers     ?? "...")
                          print("=== compte iCloud", userID?.hasiCloudAccount  ?? "...")
                          print("=== tél", userID?.lookupInfo?.phoneNumber     ?? "...")
                          print("=== @ mal", userID?.lookupInfo?.emailAddress  ?? "...")
                          print("=== Nom", (userID?.nameComponents?.givenName  ?? "..." )  + " " + (userID?.nameComponents?.familyName ?? "...") )
                          })
                        }
                    
                    
                    
                    }
                }
     
        
        
        
        
            if FileManager.default.ubiquityIdentityToken != nil {
                print("=== Utilisateur iCloud connecté")
                return true
                }
            else {
                print("=== Utilisateur iCloud déconnecté")
                return false
                }
        
    
    }
    
    
        
        
    
}
