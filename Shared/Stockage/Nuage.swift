//Arachante
// michel  le 11/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import Foundation
import CloudKit
import CoreData


class Nuage : ObservableObject {


    public  var leStatut:String=""
    public  var statut:String=""

    public static let identifiantConteneur = "iCloud.Arachante.Espoir"
    /// Conteneur CloudKit (ne pas confondre avec un conteneur CoreData    (NSPersistentContainer) )
    public static var conteneur = CKContainer.init(identifier: identifiantConteneur)
    /// Options de construction d'u conteneur CoreData
    public static var options   = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneur)

    public  var enregistrement=""
    public  var zone=""
    public  var portée=""
    public  var abonnement=""
    public  var permissions=""
    public  var proprietaire=""
    public  var prenom=""
    public  var nom=""
    public  var aUnCompte=false
    
    var lesObjets : [NSManagedObjectID]


    
init (_ lesObjets : [NSManagedObjectID] = []) {
    print("🌀🌀 INIT NUAGE")
//    let idG = Groupe().objectID
//    let idI = Item().objectID
    self.lesObjets = lesObjets

    print("🌀 idG&T", lesObjets.debugDescription ) //idG.debugDescription, idI.debugDescription, "?")
    
    Nuage.conteneur.accountStatus { [self] (accountStatus, error) in
        switch accountStatus {
            case .available:         leStatut = "iCloud est disponible"
            case .noAccount:         leStatut = "Pas de compte iCloud"
            case .restricted:        leStatut = "Accés iCloud restreints"
            case .couldNotDetermine: leStatut = "Status iCloud indeterminé"
            default:                 leStatut = "iCloud est indisponible"
            }
        }
    
    Nuage.conteneur.fetchUserRecordID { [self] (recordId, error) in
        guard let idRecord = recordId, error == nil else {
            print("🌀 ERREUR", error ?? "!")
            return
            }
        enregistrement  = idRecord.recordName // Item, Groupe
        zone            = idRecord.zoneID.zoneName
        proprietaire    = idRecord.zoneID.ownerName
        
        
        Nuage.conteneur.discoverUserIdentity(withUserRecordID: idRecord) { [self] (userID, error) in
            print("🌀=== contacts", userID?.contactIdentifiers.count ?? 0) //     ?? "...")
                aUnCompte = userID?.hasiCloudAccount ?? false
            print("🌀=== tél", userID?.lookupInfo?.phoneNumber     ?? "...")
            print("🌀=== @ mail", userID?.lookupInfo?.emailAddress  ?? "...")
                prenom = userID?.nameComponents?.givenName  ?? "..."
                nom    = userID?.nameComponents?.familyName ?? "..."
            }

        }
    
    

    
    
    Nuage.conteneur.requestApplicationPermission(.userDiscoverability) { [self] (status, error) in
        guard error == nil else {
            print("🌀 ERREUR", error ?? "!")
            return
            }
        switch status {
            case .initialState:    permissions = "La permission n'est pas encore demandé."
            case .couldNotComplete:permissions = "Erreur lors du traitement de la demande d'autorisation."
            case .denied:          permissions = "L'utilisateur refuse l'autorisation."
            case .granted:         permissions = "L'utilisateur accorde l'autorisation."
            @unknown default:     print("🌀 ERREUR")
            }
        }
    
    Nuage.conteneur.privateCloudDatabase.fetchAllRecordZones() { [self] (zone, erreur) in
        self.zone = "\(zone?.last?.zoneID.zoneName ?? "...")   \(zone?.count ?? 0)éme"
        }

    Nuage.conteneur.privateCloudDatabase.fetchAllSubscriptions() { [self] (abonnements, erreur) in
        guard let abonnements = abonnements, erreur == nil else {
            print("🌀 ERREUR", erreur ?? "!")
            return
            }
        abonnements.forEach { abonnement_ in
            let id = abonnement_.subscriptionID
            switch abonnement_.subscriptionType {
                case .database:   abonnement = "Base de données (\(id))"
                case .query:      abonnement = "Requête (\(id))"
                case .recordZone: abonnement = "Zone (\(id))"
                @unknown default: abonnement = "ERREUR (\(id))"
                }
            }
        }
    
    Nuage.conteneur.accountStatus { [self] (accountStatus, error) in
        switch accountStatus {
            case .available:              statut = "🌀 iCloud Disponible"
            case .noAccount:              statut = "🌀 Pas de compte iCloud"
            case .restricted:             statut = "🌀 iCloud resteint"
            case .couldNotDetermine:      statut = "🌀 Impossible de determiné le status d'iCloud"
            case .temporarilyUnavailable: statut = "🌀 iCloud temporairement indisponible"
            @unknown default:             statut = "🌀 iCloud nuageux"
        }
    }

    let P1 = Nuage.conteneur.publicCloudDatabase.databaseScope.rawValue
    let P2 = Nuage.conteneur.privateCloudDatabase.databaseScope.rawValue
    let P3 = Nuage.conteneur.sharedCloudDatabase.databaseScope.rawValue
    print("🌀 1,2,3  : ", P1, P2, P3)
    
    switch (Nuage.options.databaseScope) {
        case .public:     portée = "Publique"
        case .private:    portée = "Privée"
        case .shared:     portée = "Partagée"
        @unknown default: portée = "ERREUR"
        }
    
    } // init

    
    
    }
