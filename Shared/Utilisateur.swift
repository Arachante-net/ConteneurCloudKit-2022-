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

/// Configuration de l'application pour l'utilisateur courant
class Utilisateur : ObservableObject {
    
    
    
    init() {
//        let TT = UIDevice.current.identifierForVendor?.uuidString
    let configuration = UserDefaults.standard
    configuration.set(UIDevice.current.identifierForVendor?.uuidString, forKey: "UID")
    configuration.set(1960,                                             forKey: "Age")
    configuration.set(true,                                             forKey: "EstInteligent")
    configuration.set(CGFloat.pi,                                       forKey: "Pi")
    configuration.set(Date(),                                           forKey: "DerniereUtilisation")
// Les favoris ne sont placés que par l'utilisateur (pas par l'init de l'appli)
//    let favoris = ["Alpha", "Beta"]
//    configuration.set(favoris,                                          forKey: "Favoris")
    let Identification = ["Prenom": "Michel", "Nom": "DENOUAL", "Pays": "FR"]
    configuration.set(Identification,                                   forKey: "Identification")
    configuration.set("Fantomas",                                       forKey: "Alias")
    // Exemple d'utilisation :
    // Si "Favoris" existe et est un tableau de chaînes,
    // il est placé dans "tab".
    // S'il n'existe pas (ou si il existe mais n'est pas un tableau de chaînes),
    // alors "tab" devient un nouveau tableau de chaînes vide.
//    let tab  = configuration.object(forKey:"Favoris")         as? [String]         ?? [String]()
//    let dico = configuration.object(forKey: "Identification") as? [String: String] ?? [String: String]()

        
        
    statuer()

    }
    
    /// Represente la liste des Groupes favoris désignés par l'utilisateur
    var listeFavoris:Set<String> {
        get { Set(  UserDefaults.standard.object(forKey:"Favoris") as? [String] ?? [String]()  ) }
        set { UserDefaults.standard.set(Array(newValue),forKey: "Favoris") }
        }
    
    /// Indique si le groupe fait parti de l'ensemble des favoris désignés par l'utilisateur
    func estFavoris(_ groupe:Groupe) -> Bool {
        listeFavoris.contains( groupe.id?.uuidString ?? "" )
        }
    
    func ajouterAuxFavoris(_ groupe:Groupe) {
        var setFavoris = Set( UserDefaults.standard.object(forKey:"Favoris") as? [String] ?? [String]() )
        
        setFavoris.insert(groupe.id?.uuidString ?? "")
        listeFavoris = setFavoris
        }
    
    func enleverDesFavoris(_ groupe:Groupe) {
        var setFavoris = Set( UserDefaults.standard.object(forKey:"Favoris") as? [String] ?? [String]() )

        setFavoris.remove(groupe.id?.uuidString ?? "")
        listeFavoris = ( setFavoris ) //setFavoris

        }

    /// Enlever le groupe de la liste des favoris s'il en fait partie,  sinon l'ajouter,  et alterner l'état du booléen 'jeSuisFavoris'
    func inverserFavoris (_ groupe:Groupe , jeSuisFavoris: inout Bool) {
        
        if estFavoris(groupe) {
            enleverDesFavoris(groupe)
            }
        else          {
            ajouterAuxFavoris(groupe)
            }
        
        return  jeSuisFavoris.toggle()

        }
    
    
    func obtenirID() -> String  {
        
        //throw Nimbus.trucQuiVaPas(num: 5)

        let nom         = NSUserName()
        let nomComplet  = NSFullUserName()
        let _           = UIDevice.current.systemName
        let nomAppareil = UIDevice.current.name
        let idAppareil  = UIDevice.current.identifierForVendor
        print(nom, nomComplet, nomAppareil)
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
