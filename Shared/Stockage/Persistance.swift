//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2022 pour Item Seul
//

import CoreData
import CloudKit

//import Combine
import os.log



/// Fourni :
/// - un conteneur qui encapsule la pile Core Data et qui met en miroir les magasins persistants sélectionnés dans une base de données privée CloudKit.
/// - ainsi qu'une gestion de l'historique des transactions.
open class ControleurPersistance : ObservableObject {
    @Published var appError: ErrorType? = nil
    // Singleton (mais est-ce utile si on utilise comme ici un ObservableObject ?? )
    static let shared = ControleurPersistance()


     public let conteneur: NSPersistentCloudKitContainer
    
    
//     var abonnements: Set<AnyCancellable> = []
    
//    private lazy var historyRequestQueue = DispatchQueue(label: "historique")
//    private var lastHistoryToken: NSPersistentHistoryToken?
    
//    private lazy var tokenFileURL: URL = {
//      let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("FireballWatch", isDirectory: true)
//      do {
//        try FileManager.default
//          .createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//      } catch {
//        let nsError = error as NSError
//        os_log(
//          .error,
//          log: .default,
//          "Failed to create history token directory: %@",
//          nsError)
//      }
//      return url.appendingPathComponent("token.data", isDirectory: false)
//    }()

    let historien : Historien
    
    // Par défaut, le nom est utilisé pour
    // ° nommer le magasin persistant ... 🌚
    // ° retrouver le nom du model NSManagedObjectModel à utiliser avec le conteneur NSPersistentContainer.
    let nomConteneur = "ConteneurCloudKit"
    
    static let auteurTransactions = UserDefaults.standard.string(forKey: "UID") //"JTK"
    static let nomContexte        = "Enterprise"

    let  l = Logger.persistance //subsystem: Identificateur du bundle, category: "persistance"

    var sharedPersistentStore: NSPersistentStore {
      guard let sharedStore = _sharedPersistentStore else {
        fatalError("Magasin partagé non configuré")
        }
      return sharedStore
      }
    
    var privatePersistentStore: NSPersistentStore {
      guard let privateStore = _privatePersistentStore else {
        fatalError("Magasin privé non configuré")
        }
      return privateStore
      }
    
    var ckContainer: CKContainer {
      let storeDescription = conteneur.persistentStoreDescriptions.first
      guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
        fatalError("❗️Impossible d'obtenir l'identifiant du conteneur CloudKit") //Unable to get container identifier")
      }
      print("〽️ make ckContainer", identifier)
      return CKContainer(identifier: identifier)
    }

    var contexte: NSManagedObjectContext { conteneur.viewContext }
    
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    
    
    
    public init(inMemory: Bool = false) {
        l.debug("En mémoire \(inMemory.voyant)")
//        if inMemory { l.debug("OOO UUU") }
        l.error("\nInitialisation (ControleurPersistance) d'un conteneur.\n")
        conteneur = NSPersistentCloudKitContainer(name: nomConteneur)
        //            managedObjectModel:model)
        
        //MARK: - Description -
        if inMemory {
            // utilisé par les previsualisations SwiftUI (et les tests ?)
            conteneur.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        
        // Autoriser le suivi de l'historique
        historien = Historien(conteneur: conteneur)
        
        // Rq à dépacer ou supprimer
        // (permet à un conteneur NSPersistentCloudKitContainer d'etre chargé en tant que NSPersistentContainer)
        // (donc inutile si on utilise uniquement un NSPersistentCloudKitContainer ??)
        
        
        guard let descriptionMagasinPrivé = conteneur.persistentStoreDescriptions.first else {
            appError = ErrorType( .erreurInterne)
            fatalError("PAS TROUVÉ DE DESCRIPTION")
            }
        
        
        // 🟣 Demander une notification pour chaque écriture dans le magasin (y compris celles d'autres processus)
        descriptionMagasinPrivé.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // 🔴 Demander les notifications de modifications distantes (en double avec au-dessus)
//        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
//      description.setOption(true as NSNumber, forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey")
        
        // Activer le suivi de l'historique persistant.
        // Conserver l'historique des transactions avec le magasin
        descriptionMagasinPrivé.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        
        //MARK: Ajouter un magasin partagé
        // au conteneur, avec les mêmes options que le magasin privé (sauf la portée)
        let urlsMagasins = descriptionMagasinPrivé.url!.deletingLastPathComponent()
        let urlMagasinPartagé = urlsMagasins.appendingPathComponent("partage.sqlite")
        let descriptionMagasinPartagé = descriptionMagasinPrivé.copy() as! NSPersistentStoreDescription
        descriptionMagasinPartagé.url = urlMagasinPartagé
        //            descriptionMagasinPartagé.configuration = "partagée"

        let identifiantConteneurPartagé = descriptionMagasinPartagé.cloudKitContainerOptions!.containerIdentifier
        let optionsMagasinPartagé = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneurPartagé)
        optionsMagasinPartagé.databaseScope = .shared
        descriptionMagasinPartagé.cloudKitContainerOptions = optionsMagasinPartagé
        conteneur.persistentStoreDescriptions.append(descriptionMagasinPartagé)

        
        //MARK: - Stokage persistant mémoriser les réferences à chaque magasins -
        // Demander au conteneur de charger le(s) magasin(s) persistant(s)
        // (et de terminer la création de la pile CoreData)
        
        conteneur.loadPersistentStores { descriptionDuMagasin, erreur in
            // Une fois pour chacun des magasins
            if let error = erreur as NSError? {
                //TODO: Gérer l'erreur pour une utilisation en production
                // fatalError() force l'application à planter

                /*
                 Raisons possibles d'une erreur :
                 * Le répertoire parent n'existe pas, ne peut pas être créé ou interdit l'écriture.
                 * Le magasin persistant n'est pas accessible, en raison des autorisations ou de la protection des données lorsque l'appareil est verrouillé.
                 * L'appareil manque d'espace.
                 * Le magasin n'a pas pu être migré vers la version actuelle du modèle.
                 
                 Vérifier le message d'erreur pour déterminer quel était le problème réel.
                */
                self.appError = ErrorType( .trucQuiVaPas(num: 666))
                fatalError("ERREUR AU CHARGEMENT DU MAGASIN \(error), \(error.userInfo)")
                } // erreur
            
            let identifiantConteneur = descriptionDuMagasin.cloudKitContainerOptions!.containerIdentifier
            self.l.info("Identifiant du conteneur \(identifiantConteneur)")
            let optionsConteneurCloudKit   = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneur)
// CF https://www.raywenderlich.com/29934862-sharing-core-data-with-cloudkit-in-swiftui
            if let optionsConteneurCloudKit_2 = descriptionDuMagasin.cloudKitContainerOptions {

                guard let urlMagasinChargé = descriptionDuMagasin.url else { return }
                    //         let urlsMagasins = descriptionMagasinPrivé.url!.deletingLastPathComponent()

                self.l.info("Identifiant du conteneur PORTEE \(optionsConteneurCloudKit_2.databaseScope.rawValue)")
                if optionsConteneurCloudKit_2.databaseScope == .private {
                    let magasinPrivé = self.conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinChargé)
                  //self.
                    descriptionMagasinPrivé.configuration = "privée"
                    self._privatePersistentStore = magasinPrivé
                  }
                else if optionsConteneurCloudKit_2.databaseScope == .shared {
                    let magasinPartagé = self.conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinChargé)
        ////////////////          self.
                    descriptionMagasinPartagé.configuration = "partagée"
                    self._sharedPersistentStore = magasinPartagé
                    print("〽️ make", descriptionMagasinPartagé.configuration)
                  }
                self.l.info("Identifiant du conteneur URL \(urlMagasinChargé)")
                } // options conteneur CloudKit

            //MARK: Base de données partagée, publique ou privée
//             // Seulement moi
//            lesOptions.databaseScope = .private
//            storeDescription.configuration = "privée"
//           // Eventuellement creer une/des zone(s)
//
//            //  Tous les utilisateurs de l'application
//            lesOptions.databaseScope = .public
//            storeDescription.configuration = "publique"
//
//            lesOptions.databaseScope = .shared
//            storeDescription.configuration = "partagée"
            
            self.l.info("\nOptions: \(descriptionDuMagasin.configuration ?? "...") \(optionsConteneurCloudKit.databaseScope.rawValue)") //\(lesOptions.debugDescription)")

            
            // cloudKitContainerOptions   databaseScope .private .public .shared
            // shareDescOption.databaseScope = .shared
            // par défaut : privée
//            storeDescription.cloudKitContainerOptions?.databaseScope = .public

//            let scope:CKDatabase.Scope = .shared
//            lesOptions.databaseScope = .shared
//
//
//            storeDescription.configuration = lesOptions
////            sharedStoreDescription.cloudKitContainerOptions = lesOptions
///
///
///
/*
 let dbURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  
         let privateDesc = NSPersistentStoreDescription(url: dbURL.appendingPathComponent("model.sqlite"))
         privateDesc.configuration = "Private"
         privateDesc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: ckContainerID)
         privateDesc.cloudKitContainerOptions?.databaseScope = .private
  
         guard let shareDesc = privateDesc.copy() as? NSPersistentStoreDescription else {
             fatalError("Create shareDesc error")
            }
  
 shareDesc.url = dbURL.appendingPathComponent("share.sqlite")
  
         let shareDescOption = NSPersistentCloudKitContainerOptions(containerIdentifier: ckContainerID)
         shareDescOption.databaseScope = .shared
         shareDesc.cloudKitContainerOptions = shareDescOption
 */
            
        } //)
        // Fin du loadPersistentStores

        
        
        
        //MARK: - Contexte -
        // Suggeré dans les forums et autres discussions du WWW
                
        // Épingler le viewContext au jeton de génération actuelle
        // et le configurer pour qu'il se rafraichisse avec les modifications locales.
        conteneur.viewContext.automaticallyMergesChangesFromParent = true
        
//        // Pour plus de "stabilité" ?
//        do {
//            // Indiquer quelle génération du magasin persistant est accessible.
//            // Lorsqu'un contexte d'objet géré est épinglé à une génération spécifique des données de l'application,
//            // un jeton de génération de requête sera associé à ce contexte.
//            // le contexte doit utiliser la génération courante
//            try conteneur.viewContext.setQueryGenerationFrom(.current)
//        } catch {
//            fatalError("###\(#function): IMPOSSIBLE D'EPINGLER LE viewContext A LA GENERATION current :\(error)")
//        }
        
        // Pour plus de "stabilité" ?
        if !inMemory {
          do {
              // Indiquer quelle génération du magasin persistant est accessible.
              // Lorsqu'un contexte d'objet géré est épinglé à une génération spécifique des données de l'application,
              // un jeton de génération de requête sera associé à ce contexte.
              // le contexte doit utiliser la génération courante
            try conteneur.viewContext.setQueryGenerationFrom(.current)
          } catch {
            let nsError = error as NSError
              l.error("IMPOSSIBLE D'EPINGLER LE viewContext A LA GENERATION current : \(nsError)")
          }
        }
        
        // Fusionner, lors d'un enregistrement, les conflits des propriétés individuelles, entre
        // la version de l'objet du magasin persistant
        // et celle-S actuellement en mémoire.
        // ICI : Les modifications externes l'emportant sur les modifications en mémoire.
        //RQ: les conflits peuvent apparaitrent a deux endroits :
        //Entre le contexte d'objet géré
        //   et le cache du coordinateur de magasin persistant.
        //Entre le cache du coordinateur de magasin persistant
        //   et le magasin externe (fichier, base de données, etc.).
        conteneur.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        //TODO: different de ?
//        conteneur.viewContext.mergePolicy = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType


        // Fusionner les modifications dans le `viewContext`,
        // permettant ainsi la MàJ automatique de l'interface utilisateur.
        conteneur.viewContext.automaticallyMergesChangesFromParent = true
        
        conteneur.viewContext.transactionAuthor = ControleurPersistance.auteurTransactions
        conteneur.viewContext.name = ControleurPersistance.nomContexte

        
        //MARK: - Ajouter la description d'un magasin partagé au conteneur
        // 17 avril  le 28 : NON
        // Par defaut la portée d'un magasin est privée
        // Ajouter un magasin partagé au conteneur, avec les mêmes options que le magasin privé (sauf la portée)
//        let urlsMagasins = descriptionMagasinPrivé.url!.deletingLastPathComponent()
//        let urlMagasinPartagé = urlsMagasins.appendingPathComponent("partage.sqlite")
//        let descriptionMagasinPartagé = descriptionMagasinPrivé.copy() as! NSPersistentStoreDescription
//        descriptionMagasinPartagé.url = urlMagasinPartagé
//        let identifiantConteneurPartagé = descriptionMagasinPartagé.cloudKitContainerOptions!.containerIdentifier
//        let optionsMagasinPartagé = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneurPartagé)
//        optionsMagasinPartagé.databaseScope = .shared
//        descriptionMagasinPartagé.cloudKitContainerOptions = optionsMagasinPartagé
//        conteneur.persistentStoreDescriptions.append(descriptionMagasinPartagé)

        let magasinPartagé = conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinPartagé)

        //MARK: - ICI le loadPersistenStores ?
        
        //MARK: - publier le Schema Une fois seulement
//        publierSchema()
        
        
        
        
        
        
        
        
        
        //MARK: -
        demanderNotifications_NSPersistentStoreRemoteChange()
        
        //  chargerHistorique()
        historien.consulterMaPositionDansHistorique()
        
        
        //MARK: - Les configurations du modèle
        conteneur.managedObjectModel.configurations.forEach() {configuration in
            print("CONF Configuration :", configuration)
            }
        
        let ent = conteneur.managedObjectModel.entities(forConfigurationName: "TestConfig")
        
        print("CONF Première entité de la configuration TestConfig :", ent?.first?.name)
            
        let confsGroupe = Groupe.entity().managedObjectModel.configurations
        print("CONF Dernière configuration (/", confsGroupe.count , ") de Groupe :", confsGroupe.last ?? "...")


//        return conteneur
///  Decommenter  pour charger le schema vers ClouKitn
//        do {
//            try conteneur.initializeCloudKitSchema(options: NSPersistentCloudKitContainerSchemaInitializationOptions())
//        } catch {
//            print(error)
//        }
// // Ou alors :
//        publierSchema()

        
    } // Fin init ControleurPersistance conteneur ?

        
    
} // Fin Controleur Persistance






//MARK: - Historien -
extension ControleurPersistance {
    //MARK: à mettre dans historien ?
    /// recevoir (GET) des notifications
    func demanderNotifications_NSPersistentStoreRemoteChange() {
        l.info("\n🟣🟣🟣 S'abonner aux notifications.\n")
        
            let rép = 42
            l.debug("Foncé Debug")
            l.info("Clair Info")
            l.notice("?? Notice")
            l.error("Jaune Erreur")
            l.fault("Rouge La réponse est \(rép)")
        
        l.info("Auteur \(ControleurPersistance.auteurTransactions ?? "")")   // Redacted!
        l.info("Conteneur \(self.nomConteneur, privacy: .private)")  // masqué
        
        // n'utiliser qu'une seule des deux méthodes
        
        // --- Methode "selector" ---
        // param _ observateur : l'objet à notifier.
        // objet : l'expéditeur des notifications à l'observateur.
        // param object à nil ==> on recoit les notifs de tous, sinon seulement celles de l'expéditeur spécifié.
        // param selector: #selector(self.recevoirNotification(notification:))
        // Un 'sélecteur' qui spécifie le message que le destinataire doit envoyer à l'observateur pour le notifier.
        // La méthode spécifiée par selector doit avoir un seul et unique argument (une instance de NSNotification).
        
        
//        // 🔹
//        NotificationCenter.default
//            .addObserver(
//                historien,
//                selector: #selector(historien.traiterLesEvolutionsDuStockageDistant),
//                name: .NSPersistentStoreRemoteChange,
//                object: conteneur.persistentStoreCoordinator
//                )
        
        // 🔴 https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
//        NotificationCenter.default
//            .addObserver(
//                historien,
//                selector: #selector(historien.traiterLesEvolutionsDuStockageDistant_DEBUG),
//                name: NSNotification.Name( rawValue: "NSPersistentStoreRemoteChangeNotification"),
//                object: conteneur.persistentStoreCoordinator
//                )
        
        
        // 🟣 --- Methode "combine" ---
        NotificationCenter.default
          // diffuseur des notifications.
          .publisher(for: .NSPersistentStoreRemoteChange)
          // recepteur des notifications
          .sink { self.historien.traiterLesDernieresEvolutionsDuStockageDistant($0) } // self
          // Inclure ce recepteur aux abonnements de l'historien
          .store(in: &historien.abonnements)
        
        }
    
    // ERREUR : Vous avez enregistré un observateur de notification sur un objet qui a été libéré
    // et qui n'a pas supprimé l'observateur.
    // Ainsi, lorsqu'il essaie d'appeler le sélecteur, il plante.

    
    func désabonner() {
        // Supprimer l'observateur,
        // afin d'éviter un blocage, lorsque le sytème essaie d'appeler le recepteur
        // alors que l'objet a été libéré
        NotificationCenter.default.removeObserver(
            historien,
//            name: NSNotification.Name( rawValue: "NSPersistentStoreRemoteChangeNotification"),
            name: .NSPersistentStoreRemoteChange,
            object: conteneur.persistentStoreCoordinator)
        }
    } // fin extension Historien


//MARK: - Manipilation du contexte -
extension ControleurPersistance {
//TODO: A mettre dans une extension ?
func retourArriereContexte() {
    l.debug("💰 retour arriere contexte (\(self.conteneur.viewContext.hasChanges ? "il y avait des évolutions" : "rien a sauver")), \t \(self.conteneur.viewContext.updatedObjects.count) évolutions, \(self.conteneur.viewContext.insertedObjects.count) insertions, \(self.conteneur.viewContext.deletedObjects.count) suppressions.")
    conteneur.viewContext.rollback()
    // This method does not refetch data from the persistent store or stores.
    }
    
func sauverContexte( _ nom:String="ContexteParDefaut"  , auteur:String = UserDefaults.standard.string(forKey: "UID")  ?? "AuteurParDefaut", depuis:String="") {
  // Y-a bien eu des changements
  guard conteneur.viewContext.hasChanges else { return }

  do {
      l.debug("💰💰 Sauvegarde [\(self.conteneur.viewContext.registeredObjects.count) enregistrements], du contexte (depuis \(depuis), nom \(nom), auteur, \(auteur)) \(self.conteneur.viewContext.hasChanges ? "☑️" : "🟰"), \t \(self.conteneur.viewContext.updatedObjects.count) évolutions, \(self.conteneur.viewContext.insertedObjects.count) insertions, \(self.conteneur.viewContext.deletedObjects.count) suppressions.")
//          let lesEnregistrements = self.conteneur.viewContext.registeredObjects.compactMap(\.entity.name )
      l.info("💰- \( self.conteneur.viewContext.registeredObjects.compactMap(\.entity.name) )")

 ////////     l.info("💰▫️ \( self.conteneur.viewContext.registeredObjects.map(\.entity.name ) )")
//          self.conteneur.viewContext.registeredObjects.forEach() {
//              l.info("💰▫️ \($0.entity.name ?? "*")")
//            }

      self.conteneur.viewContext.updatedObjects.forEach() {
          switch $0.entity.name {
              case "Item" :
                  let O = $0 as! Item
                  l.debug("💰 -> [Item] : \(O.leTitre) V:\(O.valeur), M:\(O.leMessage), long:\(O.longitude) lat:\(O.latitude)")
                  /// Si Item évolue mettre à jour son horodatage
                  O.timestamp = Date()
              case "Groupe" :
                  let O = $0 as! Groupe
                  l.debug("💰 -> [Groupe] \(O.leNom) ")
              default: l.debug("💰 -> [[\($0.entity.debugDescription)]] ") //"   .entity.name)") //"break
                  }
              } // foreach
      
        conteneur.viewContext.transactionAuthor = auteur // + "Persistance"
        conteneur.viewContext.name = nom
    try conteneur.viewContext.save()
//            conteneur.viewContext.transactionAuthor = nil
    }
  catch {
      //FIXME: Peut mieux faire (cf. modèle Apple)
      //
      
      //  fatalError() causes the application to generate a crash log and terminate.
      // You should not use this function in a shipping application, although it may be useful during development.
   
    let nsError = error as NSError
    appError = ErrorType(.trucQuiVaPas(num: 666))
      l.error("Erreur lors de l'enregistrement de \(nsError)")
    }
  }



func supprimerObjets(_ objects: [NSManagedObject], mode:Suppression = .défaut) {
    if mode == .simulation {l.info ("🔘 simulation de suppression de \(objects)")}
    else {
        conteneur.viewContext.perform { [context = conteneur.viewContext] in
            objects.forEach {objet in
                self.l.info("🔘 supprimer objet \(objet.entity) \(objet.debugDescription)")
//              objet.prepareForDeletion() // automatique
                context.delete(objet)
            }
            
//            objects.forEach(context.delete)


            self.sauverContexte(depuis:#function)
            }
        }
    }

} // fin extension contexte
    

//MARK: - Fonctions de Partage CloudKit -
extension ControleurPersistance {


func estPartagé(objet: NSManagedObject) -> Bool {
    print("〽️ make estPartagé ?  \(objet) ")
    return estPartagé(idObjet: objet.objectID)
    }


/*
    Cette extension contient le code relatif au partage. La méthode vérifie le persistentStore du NSManagedObjectID qui a été transmis pour voir s'il s'agit du sharedPersistentStore.
    Si c'est le cas, alors cet objet est déjà partagé.
    Sinon, utilisez fetchShares(matching:) pour voir si vous avez des objets correspondant à l'objectID en question.
    Si une correspondance revient, cet objet est déjà partagé.
    De manière générale, vous travaillerez avec un NSManagedObject de votre point de vue.
    */
private func estPartagé(idObjet: NSManagedObjectID) -> Bool {
    print("〽️ make id estPartagé ?  \(idObjet) ")
    var _estPartagé = false
    // vérifier si le magasin persistant de l'Objet transmis est bien le magasinPersistant de l'appli
    if let magasinPersistant = idObjet.persistentStore {
        print("❗️ make le magasin persistant de l'item à partager :", magasinPersistant.description , idObjet.persistentStore?.description ?? "...")
        
        if magasinPersistant == _sharedPersistentStore {//}  magasinPartagé {
            // l'objet est déjà partagé
            print("❗️make c'est le magasinPersistant partagé", _sharedPersistentStore?.description)  ///// a creuser
            _estPartagé = true
            }
        else {
            // Sinon, utiliser fetchShares(matching:) afin de verifier si nous avons des objets partagés correspondant à l'idObjet transmis
            print("❗️make n'est pas le magasinPersistant partagé", magasinPersistant.description)  ///// a creuser
            let _conteneur = conteneur //persistentContainer  ///// DIRECT ??
            print("〽️ make conteneur CK :", _conteneur)
            do {
                let partages = try _conteneur.fetchShares(matching: [idObjet])
                print("〽️ make le conteneur a \(partages.count) partages.")
                if partages.first != nil {
                    // S'il y-a une correspondance, c'est que l'objet transmis est déjà partagé.
                    let _partage = partages.first
                    print("〽️ make le premier partage existe son proprietaire est :", _partage!.value.owner.userIdentity.nameComponents)
                    _estPartagé = true
                }
                }
            catch {
            print("❗️Impossible de trouver un partage de \(idObjet): \(error)")
            }
        }
    }
    print("〽️ make id estPartagé return \(_estPartagé.voyant) ")
    return _estPartagé
}

func getShare(_ item: Item) -> CKShare? {
    guard estPartagé(objet: item) else { return nil }
    guard let dicoDesPartages = try? conteneur.fetchShares(matching: [item.objectID]),
    let partage = dicoDesPartages[item.objectID] else {
    print("❗️make Impossible d'obtenir un partage CloudKit")
    return nil
    }
    partage[CKShare.SystemFieldKey.title] = item.titre //caption
    print("〽️ make partage CloudKit", item.titre)
    return partage
}

func canEdit(object: NSManagedObject) -> Bool {
    conteneur.canUpdateRecord(forManagedObjectWith: object.objectID)
    }

func canDelete(object: NSManagedObject) -> Bool {
    conteneur.canDeleteRecord(forManagedObjectWith: object.objectID)
    }

func isOwner(object: NSManagedObject) -> Bool {
    print("❗️make isOwner")
    guard estPartagé(objet: object) else { return false }
//        guard let partage = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
    guard let partage = try? conteneur.fetchShares(matching: [object.objectID])[object.objectID] else {
    print("❗️make Erreur obtention partage CloudKit")
    return false
    }
    if let currentUser = partage.currentUserParticipant, currentUser == partage.owner {
    return true
    }
    return false
}
} // Fin extension partage Cloud kit Controleur Persistance
   

//MARK: - Gestion du modéle de données
extension ControleurPersistance {

    /// Les user info d'un attribut, définis dans le modèle
    func annotation(objet:NSManagedObject, attribut:String, note:String) -> Any? {
        let entité:NSEntityDescription = objet.entity
        let attribut_:NSAttributeDescription = entité.attributesByName[attribut]!;
        let val = attribut_.userInfo![note]
        return val
        }
    
    /// Publication du schéma du conteneur vers CloudKit.
    /// A éxecuter uniquement si le schéma a évolué
    func publierSchema() {
        //FIXME: A FAIRE SEULEMENT UNE FOIS ?
        do {
            print("\n\n")
            // Crée le schéma CloudKit pour les magasins du conteneur qui gèrent une base de données CloudKit.
            try conteneur.initializeCloudKitSchema(options: [NSPersistentCloudKitContainerSchemaInitializationOptions.printSchema])
            // existe aussi .dryRun :  Valider le modèle et génèrer les enregistrements, SANS les télécharger vers CloudKit.
            l.log("\nPUBLICATION DU SCHEMA\n\n")
            }
        catch {l.error("\nERREUR À LA PUBLICATION DU SCHEMA\n")}
        } // publier schéma
    
    ///  Decommenter  pour charger le schema vers ClouKit
    //        do {
    //            try container.initializeCloudKitSchema(options: NSPersistentCloudKitContainerSchemaInitializationOptions())
    //        } catch {
    //            print(error)
    //        }
    
    
    } // Fin gestion modèle de données










//func chargerLesMagasinsPersistants() {
//    //
//    // CF. :  https://www.raywenderlich.com/29934862-sharing-core-data-with-cloudkit-in-swiftui
//    // =======================
//
//
//    let conteneur = NSPersistentCloudKitContainer()
//    //MARK: - Stokage persistant mémoriser les réferences à chaque magasins -
//    // charger les magasins persistants (et ainsi terminer la création de la pile Core Data)
//    conteneur.loadPersistentStores { descriptionDuMagasin, erreur in
//        // executé une fois pour chaque magasin persistant créé.
//
//        if let err = erreur as NSError? {
//            fatalError("Erreur lors du chargement des magasins persistants : \(err)")
//            }
//
//        //             let lesOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneur)
//      // NSPersistentCloudKitContainerOptions
//      // NSPersistentCloudKitContainerOptions
//        else if let optionsConteneurCloudKit = descriptionDuMagasin.cloudKitContainerOptions {
//            guard let urlMagasinChargé = descriptionDuMagasin.url else { return }
//                //         let urlsMagasins = descriptionMagasinPrivé.url!.deletingLastPathComponent()
//
//            if optionsConteneurCloudKit.databaseScope == .private {
//              let magasinPrivé = conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinChargé)
//              _privatePersistentStore = magasinPrivé
//              }
//            else if optionsConteneurCloudKit.databaseScope == .shared {
//              let magasinPartagé = conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinChargé)
//
//              self._sharedPersistentStore = magasinPartagé
//              }
//            } // options conteneur CloudKit
//        }
//    }
