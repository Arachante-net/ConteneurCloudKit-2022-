
import CloudKit
import CoreData
import SwiftUI


final class DéléguéApplication: NSObject, UIApplicationDelegate {
    
  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    print("〽️〽️⚜️ Délégué de l'application")
    let    configurationScene = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
           configurationScene.delegateClass = DéléguéScene.self
    return configurationScene
    }
    
  }



final class DéléguéScene: NSObject, UIWindowSceneDelegate {
    // hérité de UIWindowSceneDelegate.windowScene(_:userDidAcceptCloudKitShareWith:).
    
//    @FetchRequest(
//        sortDescriptors: [],
//        predicate: nil,
//        animation: .default)
//    var itemsRecuperes: FetchedResults<Item>
    
    /// Indique au délégué l'accès aux informations de partage CloudKit.
    /// repondre à une invitation  de partage CK
    func windowScene(_ windowScene: UIWindowScene,
                   userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        @Environment(\.managedObjectContext) var viewContext  // Utile ??

      let id = cloudKitShareMetadata.share.recordID
      print("〽️⚜️ Délégué de Scene, fenêtre accepter les invitations de partage de" , cloudKitShareMetadata.share.owner.userIdentity.nameComponents?.givenName ?? "...") // PHILIPPE
      print("〽️⚜️ type :" , cloudKitShareMetadata.share.recordType ) // cloudkit.share
      print("〽️⚜️ nom zone :" , cloudKitShareMetadata.share.recordID.zoneID.zoneName )
      print("〽️⚜️ proprio  :" , cloudKitShareMetadata.share.recordID.zoneID.ownerName )


        /*
         CoreData+CloudKit:
           -[NSCloudKitMirroringDelegate managedObjectContextSaved:](2635):
         <NSCloudKitMirroringDelegate: 0x2804440d0>: Observed context save:
         <NSPersistentStoreCoordinator: 0x28144c7e0>
         - <NSManagedObjectContext: 0x28045c4e0>
         */
      print("〽️⚜️ enregistrement :" , cloudKitShareMetadata.share.recordID.recordName ) // cloudkit.zoneshare
      print("〽️⚜️ type           :" , cloudKitShareMetadata.share[CKShare.SystemFieldKey.shareType] ?? "..."  ) // com.arachante.nimbus.item.fournir .obtenir .creer
      let portée = (cloudKitShareMetadata.share.recordID.recordName == CKRecordNameZoneWideShare)
        print("〽️⚜️ portée         :", portée ? "zone d'enregistrement partagée" : "hiérarchie d'enregistrements partagés")

      print("〽️⚜️ clefs      :" , cloudKitShareMetadata.share.allKeys() ) // ["cloudkit.title", ...]
      print("〽️⚜️  ° titre   :" , cloudKitShareMetadata.share.value(forKey: "cloudkit.title"        ) ?? "...")
      print("〽️⚜️  ° origine :" , cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_ORIGINE") ?? "...") // nimbus.fournir .creer .obtenir
      print("〽️⚜️  ° id item :" , cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_ITEM_ID"        ) ?? "...") //
        
        
        
      print("〽️⚜️ nom     :" , cloudKitShareMetadata.ownerIdentity.nameComponents?.givenName ?? "..." ) // PHILIPPE
      print("〽️⚜️ ID      :" , cloudKitShareMetadata.hierarchicalRootRecordID as Any ) // nil
        
        
//        let appDelegate = UIApplication.shared.   delegate //as! AppDelegate
//        let managedContext = appDelegate.   .managedObjectContext
//        let contexte:NSManagedObjectContext
//
//        let entité = NSEntityDescription.entity(forEntityName: "Item", in:contexte) //managedContext)
//        let objet = NSManagedObject(entity: entité!, insertInto: contexte)
//        print("〽️⚜️ objet      :" , objet.description)
//        let item = objet as! Item


      let baseDeDonnéesCK = CKContainer.default().privateCloudDatabase
     //   fetch(withRecordID:completionHandler:) method of the CKDatabase class.
      baseDeDonnéesCK.fetch(withRecordID: id) { enregistrement, erreur in
          print("〽️⚜️ eeeee ", enregistrement.debugDescription)
//          print("〽️⚜️", enregistrement! as Item)

        }
//      let info = await  baseDeDonnéesCK.records(for: [id])
//      try await baseDeDonnéesCK.records(for: [id])
        // https://developer.apple.com/documentation/cloudkit/ckdatabase
        
//        let données = try recupererDonnées(with: [id])
        
//        if let données = try?  recupererDonnées(with: [id]) {
//            print("〽️⚜️ Recupere \(données.count) favorites.")
//        } else {
//            print("〽️⚜️ Erreur récuperation de dnnées")
//        }

        let controleurDePersistance = ControleurPersistance.shared
        let magasinPartagé          = controleurDePersistance.magasinPersistantPartagé
        let conteneurPersistent     = controleurDePersistance.conteneur
        let _contexte               = controleurDePersistance.contexte
          
          if viewContext != _contexte {
              print("〽️⚜️ contextes differents", viewContext.name ?? "...", viewContext.userInfo )
              print("〽️⚜️ contextes differents",   _contexte.name ?? "...",   _contexte.userInfo )
              }
        
        
      print("〽️⚜️ ID à rechercher :", cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_ITEM_ID") ?? "...")
//      let itemUUID:UUID
      if let _itemID = cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_ITEM_ID") {
//          itemUUID = _itemID  as! UUID
//          let itemEnPartage  = recupererItem(identifié:  _itemID  as! String, contexte: viewContext)
          let itemEnPartage_ = recupererItem(identifié:  _itemID  as! String, contexte: _contexte)
          print("〽️⚜️ Récupération effective de" , itemEnPartage_?.leTitre ?? "...")
          itemEnPartage_?.message = "A ADOPTER"
          }
      else {
          print("〽️⚜️ ERREUR RECUPERATION IMPOSIBLE DE L'ITEM PARTAGÉ")
          }
//      let itemID:UUID = cloudKitShareMetadata.share.value(forKey: "nimbus.item.id") as! UUID
        
        
//      let controleurDePersistance = ControleurPersistance.shared
//      let magasinPartagé          = controleurDePersistance.magasinPersistantPartagé
//      let conteneurPersistent     = controleurDePersistance.conteneur
//      let _contexte               = controleurDePersistance.contexte
//
//        if viewContext != _contexte {
//            print("〽️⚜️ contextes differents", viewContext.name ?? "...", viewContext.userInfo )
//            print("〽️⚜️ contextes differents",   _contexte.name ?? "...",   _contexte.userInfo )
//            }

      conteneurPersistent.acceptShareInvitations(from: [cloudKitShareMetadata], into: magasinPartagé) { oo, error in
          print("〽️⚜️ Délégué de Scene, conteneur persistent : accepter les invitations de partage.")
          print("〽️⚜️" ,            oo?.first?.ownerIdentity.nameComponents?.givenName ?? "..." , "|", oo?.first?.containerIdentifier ?? "...", "|", oo?.count ?? "...")
          // PHILIPPE | iCloud.Arachante.Espoir | 1
          
          if let error = error {
                print("❗️ ERREUR avec acceptShareInvitation :\(error)")
                }
          }
      }
    
    func bloup() {}
    // l'inverse de persistentContainer.record(for: object.objectID)
    
    func recupererDonnées(with ids: [CKRecord.ID]) async throws
        -> [CKRecord.ID: Result<CKRecord, Error>] {

        // Obtenir une réference à ma base privée
        let maBasDeDonnées = CKContainer.default().privateCloudDatabase

        // Créer une configuration ayant une qualité de service élevée
        let config = CKOperation.Configuration()
        config.qualityOfService = .userInitiated

        // Configurer la base et recuperer les données // try await
        return try  await maBasDeDonnées.configuredWith(configuration: config) { db in
//            bloup:[CKRecord.ID : Result<CKRecord, Error>]
            let bloup = try  await db.records(for: ids)
            return bloup
            }
        }
    
    func recupererPartage(pourLaZone zone: CKRecordZone,
                    completion: @escaping (Result<CKShare, Error>) -> Void) {
        let database = CKContainer.default().privateCloudDatabase
            
        // Use the 'CKRecordNameZoneWideShare' constant to create the record ID.
        let recordID = CKRecord.ID(recordName: CKRecordNameZoneWideShare,
                                   zoneID: zone.zoneID)
            
        // Fetch the share record from the specified record zone.
        database.fetch(withRecordID: recordID) { share, error in
            if let error = error {
                // If the fetch fails, inform the caller.
                completion(.failure(error))
            } else if let share = share as? CKShare {
                // Otherwise, pass the fetched share record to the
                // completion handler.
                completion(.success(share))
            } else {
                fatalError("Unable to fetch record with ID: \(recordID)")
            }
        }
    }
    
    func recupererItem(identifié idItem: String, contexte:NSManagedObjectContext) -> Item? {
        print("〽️⚜️⚜️⚜️ Récupération depuis le contexte :" , contexte.name ?? "...")

        var extractionItem: NSFetchRequest<Item> {
            let requête: NSFetchRequest<Item> = Item.fetchRequest()
                requête.sortDescriptors = []
                requête.fetchLimit = 1
             // requête.predicate = NSPredicate(format: "id == '\(idItem)'")
                requête.predicate = NSPredicate(format: "id == %@", idItem ) //as CVarArg)
            return requête
            }
        
        //FIXME: Ne fonctionne que dans une Vue ?!
        //        @FetchRequest(fetchRequest: extractionItem)
        //        var recup: FetchedResults<Item>
        //        let itemRecup = recup.first
        // --------------
        
        // Donc plutôt ceci cela :
        do {
            let item  = try contexte.fetch(extractionItem).first

            print("〽️⚜️ Récupération de l'item :" , item?.leTitre ?? "...")
            print("〽️⚜️ Orphelin :" , (item?.principal == nil).voyant    )
            return item
            }
        catch let error as NSError {
            print("〽️⚜️ ERREUR de récupération (Fetch) : \(error) description: \(error.userInfo)")
            }
        
        return nil

        } // recupererItem
    
    
    
    
  }
