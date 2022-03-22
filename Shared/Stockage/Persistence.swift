//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2022 pour Item Seul
//

import CoreData
//import Combine
import os.log



//struct ControleurPersistance  {

/// Fourni :
/// - un conteneur qui encapsule la pile Core Data et qui met en miroir les magasins persistants sélectionnés dans une base de données privée CloudKit.
/// - ainsi qu'une gestion de l'historique des transactions.
class ControleurPersistance : ObservableObject {
    @Published var appError: ErrorType? = nil
    // Singleton
    static let shared = ControleurPersistance()


     let conteneur: NSPersistentCloudKitContainer
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

    init(inMemory: Bool = false) {
//        print("\nInitialisation (ControleurPersistance) d'un conteneur.\n")
        l.error("\nInitialisation (ControleurPersistance) d'un conteneur.\n")
        conteneur = NSPersistentCloudKitContainer(name: nomConteneur)
        //            managedObjectModel:model)
        
        //MARK: - Description -
        if inMemory {
            // utilisé par les previsualisations SwiftUI
            conteneur.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        
        historien = Historien(conteneur: conteneur)
        
        // Autoriser le suivi de l'historique
        // (permet à un NSPersistentCloudKitContainer d'etre chargé en tant que NSPersistentContainer)
        // (donc inutile si on utilise uniquement un NSPersistentCloudKitContainer ??)
        guard let description = conteneur.persistentStoreDescriptions.first else {
            appError = ErrorType( .erreurInterne)
            fatalError("PAS TROUVÉ DE DESCRIPTION")
            }
        
        // 🟣 Demander une notification pour chaque écriture dans le magasin (y compris celles d'autres processus)
        description.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // 🔴 Demander les notifications de modifications distantes (en double avec au-dessus)
//        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
//      description.setOption(true as NSNumber, forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey")
        
        // Activer le suivi de l'historique persistant.
        // Conserver l'historique des transactions avec le magasin
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        

        
        
//        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.Arachante.Espoir")
//        options.databaseScope = .public
//        description.configuration = "Public"
        

        
        //MARK: - stokage persistant -
        // Demander au conteneur de charger le(s) magasin(s) persistant(s)
        // (et de terminer la création de la pile CoreData)
        conteneur.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
            }
            
            let identifiantConteneur = storeDescription.cloudKitContainerOptions!.containerIdentifier
            self.l.info("Identifiant du conteneur \(identifiantConteneur)")
            let lesOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifiantConteneur)
            self.l.info("Options \(lesOptions.debugDescription)")
//            storeDescription.cloudKitContainerOptions?.databaseScope = .public

//            let scope:CKDatabase.Scope = .shared
//            lesOptions.databaseScope = .shared
//
//
//            storeDescription.configuration = lesOptions
////            sharedStoreDescription.cloudKitContainerOptions = lesOptions
            
        })
        

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

        //MARK: - Une fois seulement
//        publierSchema()
        
        
        //MARK: -
        demanderNotifications_NSPersistentStoreRemoteChange()
        
//         chargerHistorique()
        historien.consulterMaPositionDansHistorique()
        
//        return conteneur
        
    } // init ControleurPersistance conteneur ?

        
        
        
    /// Publication du schéma du conteneur vers CloudKit.
    func publierSchema() {
        //FIXME: A FAIRE SEULEMENT UNE FOIS ?
        do {
            print("\n\n")
            // Crée le schéma CloudKit pour les magasins du conteneur qui gèrent une base de données CloudKit.
            try conteneur.initializeCloudKitSchema(options: [NSPersistentCloudKitContainerSchemaInitializationOptions.printSchema])
            // existe aussi .dryRun :  Valider le modèle et génèrer les enregistrements, SANS les télécharger vers CloudKit.
            l.log("\nPUBLICATION DU SCHEMA\n\n")
            }
//        appError = ErrorType(error: .trucQuiVaPas(num: 666))
        catch {l.error("\nERREUR À LA PUBLICATION DU SCHEMA\n")}
        }
    
    /// recevoir (GET) des notifications
    //FIXME: à mettre dans historien
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
          //FIXME: Peut mieux faire (cf. modele Apple)
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
    
    
    } // Controleur Persistance

