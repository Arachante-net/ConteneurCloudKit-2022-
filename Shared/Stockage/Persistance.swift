//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2022 pour Item Seul
//

import CoreData
import CloudKit
import UIKit

//import Combine
import os.log



/// Fourni :
/// - un conteneur qui encapsule la pile Core Data et qui met en miroir les magasins persistants locaux sélectionnés dans une base de données distante CloudKit.
/// - ainsi qu'une gestion de l'historique des transactions.
/// - et la configuration de la couche CloudKit correspondante
///
/// - Accés au Contexte CoreData (bloc notes des operations)
/// - Coordinateur des magasins, il stocke et récupère les données depuis la base (magasin), les convertis en objet pour les passer au contexte en vérifiant la conformité au modèle.
/// - Accés au modèle (le schéma d'organisation des données) entités, attributs et relations.
///
open class ControleurPersistance : ObservableObject {
    @Published var appError: ErrorType? = nil
    // Singleton (mais est-ce utile si on utilise comme ici un ObservableObject ?? )
    static let shared = ControleurPersistance()


     public let conteneur: NSPersistentCloudKitContainer
    
    let historien : Historien
    
    // Par défaut, le nom est utilisé pour
    // ° nommer le magasin persistant ... 🌚
    // ° retrouver le nom du model NSManagedObjectModel à utiliser avec le conteneur NSPersistentContainer.
    let nomConteneur = "ConteneurCloudKit"
    
    static let auteurTransactions = UserDefaults.standard.string(forKey: "UID") //"JTK"
    static let nomContexte        = "Enterprise"

    let  l = Logger.persistance //subsystem: Identificateur du bundle, category: "persistance"

    var magasinPersistantPartagé: NSPersistentStore {
      guard let sharedStore = _magasinPersistantPartagé else {
        fatalError("Magasin partagé non configuré")
        }
      return sharedStore
      }
    
    var magasinPersistantPrivé: NSPersistentStore {
      guard let privateStore = _magasinPersistantPrivé else {
        fatalError("Magasin privé non configuré")
        }
      return privateStore
      }
    
    var conteneurCK: CKContainer {
      let storeDescription = conteneur.persistentStoreDescriptions.first
      guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
        fatalError("❗️Impossible d'obtenir l'identifiant du conteneur CloudKit") //Unable to get container identifier")
      }
      print("〽️ lecture du conteneur CK,   ID:", identifier)
      return CKContainer(identifier: identifier)
    }
    
    // Nuage : A ETUDIER
    public  var leStatut:String=""
    public  var statut:String=""
    
    public  var enregistrement=""
    public  var zone=""
    public  var portée=""
    public  var abonnement=""
    public  var permissions=""
    public  var proprietaire=""
    public  var prenom=""
    public  var nom=""
    public  var aUnCompte=false
    // Fin Nuage à voir


    var contexte: NSManagedObjectContext { conteneur.viewContext }
    
    
    private var _magasinPersistantPrivé:   NSPersistentStore?
    private var _magasinPersistantPartagé: NSPersistentStore?
    
    
    
    public init(inMemory: Bool = false) {
        l.debug("En mémoire \(inMemory.voyant)")
        l.error("\nInitialisation (ControleurPersistance) d'un conteneur.\n")
        conteneur = NSPersistentCloudKitContainer(name: nomConteneur)
        
        // Magasin entierement en mémoire
        if inMemory {
            // utilisé pour les tests et les previsualisations SwiftUI  (et peut-être d'autres cas)
            conteneur.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        
        // Autoriser le suivi de l'historique
        historien = Historien(conteneur: conteneur)
        
        
        //MARK: - Magasinier -
        //MARK:   Description

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

        
        //MARK: - Stokage persistant mémoriser chacun des magasins réferencés -
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
                    self._magasinPersistantPrivé = magasinPrivé
                  }
                else if optionsConteneurCloudKit_2.databaseScope == .shared {
                    let magasinPartagé = self.conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinChargé)
        ////////////////          self.
                    descriptionMagasinPartagé.configuration = "partagée"
                    self._magasinPersistantPartagé = magasinPartagé
                    print("〽️ descriptionMagasinPartagé", descriptionMagasinPartagé.configuration)
                  }
                self.l.info("Identifiant du conteneur URL \(urlMagasinChargé)")
                } // options conteneur CloudKit

            
            self.l.info("\nOptions: \(descriptionDuMagasin.configuration ?? "...") \(optionsConteneurCloudKit.databaseScope.rawValue)")

            
        } // Fin du loadPersistentStores

        
        
        
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
        conteneur.viewContext.name              = ControleurPersistance.nomContexte

        
// mardi 10 mai
//        let magasinPartagé = conteneur.persistentStoreCoordinator.persistentStore(for: urlMagasinPartagé)

        
        //MARK: - publier le Schema Une fois seulement
//        publierSchema()
        
        
        
        
        
        
        
        
        
        //MARK: Suivi de l'historique -
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
        
        //MARK: - -------
        statuerConteneurCK()


///  Decommenter  pour charger le schema vers ClouKitn
//        do {
//            try conteneur.initializeCloudKitSchema(options: NSPersistentCloudKitContainerSchemaInitializationOptions())
//        } catch {
//            print(error)
//        }
// // Ou alors :
//        publierSchema()

        
    } // Fin init ControleurPersistance

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


//MARK: - Manipulation du contexte -
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
      l.debug("💰💰⚙️ Sauvegarde [\(self.conteneur.viewContext.registeredObjects.count) enregistrements], du contexte (depuis \(depuis), nom \(nom), auteur, \(auteur)) \(self.conteneur.viewContext.hasChanges ? "☑️" : "🟰"), \t \(self.conteneur.viewContext.updatedObjects.count) évolutions, \(self.conteneur.viewContext.insertedObjects.count) insertions, \(self.conteneur.viewContext.deletedObjects.count) suppressions.")
//          let lesEnregistrements = self.conteneur.viewContext.registeredObjects.compactMap(\.entity.name )
      l.info("💰- \( self.conteneur.viewContext.registeredObjects.compactMap(\.entity.name) )")



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
    if mode == .simulation {l.info ("🔘🔘 Simulation de suppression de \(objects)")}
    else {
        conteneur.viewContext.perform { [context = conteneur.viewContext] in
            objects.forEach {objet in
                self.l.info("🔘🔘⚙️ Supprimer objet \(objet.entity) \(objet.debugDescription)")
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
//MARK: Aides au Partage : participant permission, methodes and proprietés ...
extension ControleurPersistance {
    /*
        Cette extension contient le code relatif au partage CK. La méthode vérifie le persistentStore du NSManagedObjectID qui a été transmis pour voir s'il s'agit du sharedPersistentStore.
        Si c'est le cas, alors cet objet est déjà partagé.
        Sinon, on utilise fetchShares(matching:) pour voir s'il existe des objets correspondant à l'objectID en question.
        Si on a une correspondance, alors c'est que l'objet est déjà partagé.
        */

/// l'objet est-il partagé via CloudKit ?
func estPartagéCK(objet: NSManagedObject) -> Bool {
//    \Groupe.leNom
//    \Item.leTitre désignation
//    let TG:Groupe? = objet.self as? Groupe //as Groupe
//    let TI = objet.self as? Item
//    let TT = type(of: objet)
    guard type(of: objet) == Item.self else {return false}
    print("〽️〽️🗯 L'item \( (objet as! Item).leTitre) est-il partagé ? ")
    return estPartagé(idObjet: objet.objectID)
    }

    /// l'objet est-il partagé via CloudKit ?
private func estPartagé(idObjet: NSManagedObjectID) -> Bool {
    print("〽️ 🗯 l'objet (id \(idObjet.uriRepresentation()) ) est-il partagé ?")
    var _estPartagé = false
    // Vérifier si le magasin persistant de l'Objet transmis est bien le magasinPersistant de l'appli
    if let magasinPersistant = idObjet.persistentStore {
        print("🗯 Le magasin persistant de l'item à partager :", magasinPersistant.description , "(", idObjet.persistentStore?.description ?? "..." ,")")
        
        if magasinPersistant == _magasinPersistantPartagé {//}  magasinPartagé {
            // l'objet est déjà partagé
            print("🗯 Le magasin persistant partagé déja existant :", _magasinPersistantPartagé?.description ?? "...", "est identique a celui de l'item à partager")  /// // a creuser
                                                                                                                         ///
            _estPartagé = true
            }
        else {
            // Sinon, utiliser fetchShares(matching:) afin de verifier si nous avons des objets partagés correspondant à l'id transmis
            print("🗯❗️Le magasin persistant partagé déja existant :", _magasinPersistantPartagé?.description ?? "..." , "n'est pas celui de l'item à partager" , magasinPersistant.description)  ///// a creuser
            let _conteneur = conteneur
            
            //NSPersistentCloudKitContainer(name: nomConteneur)

//            conteneur //persistentContainer  ///// DIRECT ??
            print("〽️🗯 Cherchons dans le conteneur CK :", _conteneur.name)
            do {
                // les enregistrements de partage CloudKit
                let partages = try _conteneur.fetchShares(matching: [idObjet])
                print("〽️🗯 Le conteneur", _conteneur.name, "contient \(partages.count) partages.")
                if partages.first != nil {
                    // S'il y-a une correspondance, c'est que l'objet transmis est déjà partagé.
//                    let v = idObjet.value(forKey: "coin")
//                    let _partage = partages.first
//                    let _participation = _partage!.value.participants.count
//                    print("〽️🗯 Le premier partage existe son proprietaire est :", _partage!.value.owner.userIdentity.nameComponents ?? "...", " participation de", _participation)
                    partages.forEach() {_p in
                        let _pv = _p.value // CKShare
                        let id = _pv.recordID
                        let k = _pv.allKeys()

                        print("〽️🗯 Partage , proprietaire :", _pv.owner.userIdentity.nameComponents ?? "...",
                              " participation de", _pv.participants.count,
//                              " " , cloudKitShareMetadata.share.value(forKey: "NIMBUS_PARTAGE_GROUPE_OBJECTIF") ) //
                              " id :"     , _pv.recordID ,
//                              " id_ :"    , _pv.recordID.value(forKey: "NIMBUS_PARTAGE_GROUPE_NOM") ?? "..." ,
                              " NOM_ :"   , _pv.value(forKey: "NIMBUS_PARTAGE_GROUPE_NOM") ?? "..." ,
                              " clefs_ :" , _pv.allKeys() ) // ["cloudkit.title", ...]
                        }
                    _estPartagé = true
                }
                }
            catch {
            print("❗️Impossible de trouver un partage de \(idObjet): \(error)")
            }
        }
    }
    print("〽️〽️🗯 retour de estPartagé : \(_estPartagé ? "✅" : "❌") ")
    return _estPartagé
}
    
    /// comme je n'arrive pas a faire marcher correctement la version utilisant  fetchShares
    /// l'objet est-il partagé via CloudKit ?
    func estNuageux(_ item: Item) -> Bool {
        item.nuageux
        }

    
/// Fournir les informations relatives à un partage déjà existant, sans le creer.
/// chargé lors de l'affichage de la Vue détails (onAppear) d'un Item et depuis voirDétailsCollaboration d'un Groupe
    func obtenirUnPartageCK(_ item: Item, nom:String="", objectif:String="") -> CKShare? {
    print("〽️ Obtenir un partage pour l'item :", item.leTitre)
    // Si l'objet est déja partagé
    guard estPartagéCK(objet: item) else {
        print("〽️ Pas de partage déjà existant pour :",  item.leTitre)
        return nil }
        
    guard let dicoDesPartages = try? conteneur.fetchShares(matching: [item.objectID]),
    let partage = dicoDesPartages[item.objectID] else {
        print(" 〽️ Impossible d'obtenir un partage CloudKit pour :", item.leTitre)
        return nil
        }
    
    print(" 〽️ ON GO")
    let nbParticipants = partage.participants.count
//    partage[CKShare.SystemFieldKey.title] = "\(nbParticipants) Inviter à participer à l'événement \n \"\(item.titre ?? "...")\" "
//    partage[CKShare.SystemFieldKey.shareType] = "com.arachante.nimbus.item" //.obtenir"
    partage.setValue("OBTENIR",             forKey: "NIMBUS_PARTAGE_ORIGINE")
    partage.setValue(item.id?.uuidString,   forKey: "NIMBUS_PARTAGE_ITEM_ID")
    partage.setValue(nom,                   forKey: "NIMBUS_PARTAGE_GROUPE_NOM")
    partage.setValue(objectif,              forKey: "NIMBUS_PARTAGE_GROUPE_OBJECTIF")



    let image = UIImage(named: "RejoindrePartage") //Rouge16") //RejoindrePartage")
    let donnéesImage = image?.pngData()
        // 6/10/ 22 //let test = partage[CKShare.SystemFieldKey.thumbnailImageData]//.debugDescription
        // 6/10/ 22 //print("〽️ 🌀 image déjà en cache :" , test ?? "bof", image?.imageRendererFormat, image?.size)
        // 6/10/ 22 //partage[CKShare.SystemFieldKey.thumbnailImageData] = donnéesImage! as CKRecordValue
    print("〽️...", nbParticipants , "🌀 Obtention du partage CloudKit pour", item.titre ?? "...")
    return partage
}
    
    
/// Associer et fournir un partage CloudKit relatif à l''iem (NSManagedObject) en paramêtre
/// Création du partage.
/// Depuis les boutons recruter / partager des vues détails des groupes ou items
    func associerUnPartageCK(_ item: Item, nom:String="", objectif:String="", message:String = "s'associer à un partage") async -> CKShare? {
    var _partage : CKShare?
  do {
      // Associer un item à un partage (nouveau ou préexistant)
      print("〽️ 🔱 🔆 Associer un partage CK avec <", item.leTitre, ">")
      let (_, _partageTmp, _) = try await conteneur.share([item], to: nil)
      let nbParticipants = _partageTmp.participants.count
      // 6/10/ 22 //_partageTmp[CKShare.SystemFieldKey.title] = "\(nbParticipants) \(message)" //"Participer à l'événement\n\"\(item.titre ?? "...")\"\n(Création de la collaboration)"
      let image = UIImage(named: "CreationPartage")
      let donnéesImage = image?.pngData()
      // 6/10/ 22 //_partageTmp[CKShare.SystemFieldKey.thumbnailImageData] = donnéesImage
//      _partageTmp[CKShare.SystemFieldKey.shareType] = "com.arachante.nimbus.item" //.associer"
      _partageTmp.setValue("ASSOCIER",          forKey: "NIMBUS_PARTAGE_ORIGINE")
      _partageTmp.setValue(item.id?.uuidString, forKey: "NIMBUS_PARTAGE_ITEM_ID")
      _partageTmp.setValue(nom,                 forKey: "NIMBUS_PARTAGE_GROUPE_NOM")
      _partageTmp.setValue(objectif,            forKey: "NIMBUS_PARTAGE_GROUPE_OBJECTIF")

      print("〽️ 🔱 🔆 Nb de participants au partage :" , nbParticipants, ", ID :", _partageTmp.recordID, ", Type :", _partageTmp.recordType)
    _partage = _partageTmp
    }
  catch { print("❗️Impossible de creer un partage") }
  return _partage
  }


func jePeuxEditer(objet: NSManagedObject) -> Bool {
    conteneur.canUpdateRecord(forManagedObjectWith: objet.objectID)
    }

func jePeuxSupprimer(objet: NSManagedObject) -> Bool {
    conteneur.canDeleteRecord(forManagedObjectWith: objet.objectID)
    }

func jeSuisPropriétaire(objet: NSManagedObject) -> Bool {
    print("❗️make isOwner")
    guard estPartagéCK(objet: objet) else { return false }
//        guard let partage = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
    guard let partage = try? conteneur.fetchShares(matching: [objet.objectID])[objet.objectID] else {
    print("❗️make Erreur obtention partage CloudKit")
    return false
    }
    if let currentUser = partage.currentUserParticipant, currentUser == partage.owner {
    return true
    }
    return false
}
} // Fin extension partage Cloud kit Controleur Persistance
   
// MARK: Aides au Partage : participant permission, methodes and proprietés ...
extension ControleurPersistance {
        
    func statuerConteneurCK() {
        
        conteneurCK.accountStatus { [self] (accountStatus, error) in
            switch accountStatus {
                case .available:              statut = "🌀 iCloud Disponible"
                case .noAccount:              statut = "🌀 Pas de compte iCloud"
                case .restricted:             statut = "🌀 iCloud resteint"
                case .couldNotDetermine:      statut = "🌀 Impossible de determiné le status d'iCloud"
                case .temporarilyUnavailable: statut = "🌀 iCloud temporairement indisponible"
                @unknown default:             statut = "🌀 iCloud nuageux"
            }
        }
    
        conteneurCK.fetchUserRecordID { [self] (recordId, error) in
            guard let idRecord = recordId, error == nil else {
                print("🌀 ERREUR", error ?? "!")
                return
                }
            enregistrement  = idRecord.recordName // Item, Groupe
            zone            = idRecord.zoneID.zoneName
            proprietaire    = idRecord.zoneID.ownerName
        
            conteneurCK.discoverUserIdentity(withUserRecordID: idRecord) { [self] (userID, error) in
                print("🌀=== contacts", userID?.contactIdentifiers.count ?? 0) //     ?? "...")
                    aUnCompte = userID?.hasiCloudAccount ?? false
                print("🌀=== tél", userID?.lookupInfo?.phoneNumber     ?? "...")
                print("🌀=== @ mail", userID?.lookupInfo?.emailAddress  ?? "...")
                    prenom = userID?.nameComponents?.givenName  ?? "..."
                    nom    = userID?.nameComponents?.familyName ?? "..."
                }
            } // fetchUserrecordID
        
        
        conteneurCK.requestApplicationPermission(.userDiscoverability) { [self] (status, error) in
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
        
        conteneurCK.privateCloudDatabase.fetchAllRecordZones() { [self] (zone, erreur) in
            self.zone = "\(zone?.last?.zoneID.zoneName ?? "...")   \(zone?.count ?? 0)éme"
            }

        conteneurCK.privateCloudDatabase.fetchAllSubscriptions() { [self] (abonnements, erreur) in
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
        


        let P1 = conteneurCK.publicCloudDatabase.databaseScope.rawValue
        let P2 = conteneurCK.privateCloudDatabase.databaseScope.rawValue
        let P3 = conteneurCK.sharedCloudDatabase.databaseScope.rawValue
        
        print("🌀 1,2,3  : ", P1, P2, P3)
        
        
        // PAS ICI
        let identifiantConteneurCK = "iCloud.Arachante.Espoir"
//        /// Conteneur CloudKit (ne pas confondre avec un conteneur CoreData    (NSPersistentContainer) )
//        let conteneur = CKContainer.init(identifier: identifiantConteneurCK)
        /// Options de construction d'u conteneur CoreData
        let options   = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneurCK)

        switch (options.databaseScope) {
            case .public:     portée = "Publique"
            case .private:    portée = "Privée"
            case .shared:     portée = "Partagée"
            @unknown default: portée = "ERREUR"
            }

        
        
        
        } // fin statuerConteneurCK
    
    func libellé(de permission: CKShare.ParticipantPermission) -> String {
      switch permission {
          case .unknown:
            return "Inconnu" //"Unknown"
          case .none:
            return "Sans" //"None"
          case .readOnly:
            return "Lecture seule" //"Read-Only"
          case .readWrite:
            return "Lecture/Écriture" //"Read-Write"
          @unknown default:
            fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.Permission")
          }
      }

    func libellé(de role: CKShare.ParticipantRole) -> String {
      switch role {
          case .owner:
            return "Propriétaire" //"Owner"
          case .privateUser:
            return "Utilisateur Privé" // participant ? //"Private User"
          case .publicUser:
            return "Utilisateur Publique" // "Public User"
          case .unknown:
            return "Inconnu" //Unknown"
          @unknown default:
            fatalError("Une nouvelle valeur inconnue pour  CKShare.Participant.Role")
          }
      }

    func libellé(de acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
      switch acceptanceStatus {
          case .accepted:
            return "Accepté" //"Accepted"
          case .removed:
            return "Révoqué" //Enlevé, Révoqué "Removed"
          case .pending:
            return "Invité" //"Invited"
          case .unknown:
            return "Inconnu" //"Unknown"
          @unknown default:
            fatalError("Une nouvelle valeur inconnue pour CKShare.Participant.AcceptanceStatus")
          }
      }

    

} // Fin de nuage (Aides au Partage : participant permission, methodes and proprietés ...)







//MARK: - Gestion du modéle de données
extension ControleurPersistance {

    /// Lire les user info d'un attribut, définis dans le modèle
    func annotation(objet:NSManagedObject, attribut:String, note:String) -> Any? {
        let entité:NSEntityDescription = objet.entity
        let attribut_:NSAttributeDescription = entité.attributesByName[attribut]!;
        let val = attribut_.userInfo![note]
        return val
        }
    
    /// Lire les configurations du modèle decrites dans le schéma
    func configurations() {
        conteneur.managedObjectModel.configurations.forEach() {configuration in
            print("CONF Configuration :", configuration)
            }
        
        let ent = conteneur.managedObjectModel.entities(forConfigurationName: "TestConfig")
        
        print("CONF Première entité de la configuration TestConfig :", ent?.first?.name ?? "...")
            
        let confsGroupe = Groupe.entity().managedObjectModel.configurations
        print("CONF Dernière configuration (/", confsGroupe.count , ") de Groupe :", confsGroupe.last ?? "...")
        }
    
    /// Publication du schéma du conteneur vers CloudKit.
    /// A éxecuter uniquement si le schéma a évolué
    func publierSchema() {
        do {
            print("\n\n")
            // Crée le schéma CloudKit des magasins du conteneur associés à une base de données CloudKit.
            try conteneur.initializeCloudKitSchema(options: [NSPersistentCloudKitContainerSchemaInitializationOptions.printSchema])
            // existe aussi .dryRun :  pour uniquement valider le modèle et génèrer les enregistrements, SANS les télécharger vers CloudKit.
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










//    // CF. :  https://www.raywenderlich.com/29934862-sharing-core-data-with-cloudkit-in-swiftui

