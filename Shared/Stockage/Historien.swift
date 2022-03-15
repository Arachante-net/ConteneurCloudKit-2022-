//Arachante
// michel  le 03/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import Foundation
import CoreData
import Combine
import os



public class Historien {
    
//    var persistance: ControleurPersistance
    
    var appError: ErrorType? // = nil
    let  l = Logger.historien

    var abonnements: Set<AnyCancellable> = []
//    private lazy
    var historyRequestQueue = DispatchQueue(label: "historique")
    var dernierEvenement: NSPersistentHistoryToken?

    private lazy var urlFichierDesTokens: URL = {
      let urlRepertoire = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Observation", isDirectory: true)
      do {
        try FileManager.default
          .createDirectory(at: urlRepertoire, withIntermediateDirectories: true, attributes: nil)
      } catch {
        let nsError = error as NSError
          l.error("Échec de la création du répertoire d'historique des jetons : \(nsError)")
      }
      let urlFichier = urlRepertoire.appendingPathComponent("token.plist", isDirectory: false)

        l.info("Fichier des jetons : \(urlFichier)")
      return urlFichier
    }()

    
    //FIXME: un autre moyen d'obtenir le conteneur ?
    var conteneur : NSPersistentCloudKitContainer
    

    init(conteneur : NSPersistentCloudKitContainer)
        {self.conteneur = conteneur}
  
    
    // 🔴 Integrer les évolutions du magasin distant (0)
    @objc func traiterLesEvolutionsDuStockageDistant_DEBUG(notification: NSNotification) {
        l.debug("\n🔴 \(#function)  № \t VIDE NOTIFICATION D'ÉVOLUTION DU STOCKAGE DISTANT\n")
//      let contexte = conteneur.viewContext ///    ou newBackgroundContext() ??
        }
                
    
    // 🔹 Integrer les évolutions du magasin distant (1)
    // PAS UTILISÉ (17/12/21)
    @objc func traiterLesEvolutionsDuStockageDistant(notification: NSNotification) {
        print("\n🔹", #function, " \t NOTIFICATION D'ÉVOLUTION DU STOCKAGE DISTANT\n",
              notification.userInfo?.keys ?? "",
              notification.userInfo?.values ?? "",
//                 notification.userInfo?.last?.key,
                 "\n")
        
                fileAttenteOperation.addOperation {
                    // Obtenir un contexte qui s'exécute sur une file d'attente privée.
                    let monContexte = self.conteneur.newBackgroundContext()
        
                    //TODO: DIFFERENCES ENTRE
        //            context.performAndWait                     { /* ... */ } en serie
        //            context.perform                            { /* ... */ }
        //            container.performBackgroundTask { context in /* ... */ }
                    
                        // Obtenir les articles en magasin
                        let items: [Item]
                        let groupes: [Groupe]
        
                        do {
                            let requeteItems : NSFetchRequest<Item>
                                requeteItems = Item.fetchRequest()
                                requeteItems.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

                            let requeteGroupes : NSFetchRequest<Groupe>
                                requeteGroupes = Groupe.fetchRequest()
                                requeteGroupes.sortDescriptors = [NSSortDescriptor(key: "nom", ascending: true)]

                            
                            try items   = monContexte.fetch(requeteItems) //Carte.obtenirLaListeFournieParLaRequete())
                            try groupes = monContexte.fetch(requeteGroupes)
                            }
                        catch {
                            let nserror = error as NSError
                            self.appError = ErrorType( .trucQuiVaPas(num: 666))
                            fatalError("🔹 ERREUR DE RÉCUPERATION SUITE À NOTIFICATION \(nserror), \(nserror.userInfo)")
                            }
        
                        //TODO: à écrire
                        print("\n🔹",   items.count, "ITEMS"  , items.first?.timestamp ?? "", "...", items.last?.timestamp ?? "")
                        print("\n🔹", groupes.count, "GROUPES", groupes.first?.nom ?? "")
//                      jouerAvec(cartes: items)
        
                        // Sauver si besoin
                    // persistance ...
//                    persistance.sauverContexte(nom:"GroupeItem"  , auteur:"Historien") 

                        if monContexte.hasChanges {
                            print("♻️")
//                            os_log("User %{public}@ logged in", log: OSLog.userFlow, type: .info, username)
//                            os_log("♻️", log: OSLog.default)

                            do {
                                let auteurActu =  monContexte.transactionAuthor
                                    monContexte.transactionAuthor = "Historien"
                                    monContexte.name = "GroupeItem"
                                try monContexte.save()
                                    monContexte.transactionAuthor = auteurActu
//                                try self.persistance.sauverContexte() ///////// DANGER
                            } catch {
                                let nserror = error as NSError
                                self.appError = ErrorType(.trucQuiVaPas(num: 666))
                                fatalError("🔹 ERREUR DE MÀJ SUITE À NOTIFICATION \(nserror), \(nserror.userInfo)")
                            }
                        } // contexte
                    }
//                }
        }
           
    
    // 🟣 Prendre en considération les dernières évolutions du stokage distant  (2 combine)
    func traiterLesDernieresEvolutionsDuStockageDistant(_ notification : Notification) {
        l.info("🟣🟣🟣 Début de traiterLesDernieresEvolutionsDuStockageDistant")
        // cf. processRemoteStoreChange
        l.debug("\n\n🟣 \(#function)")
//      print ("#notification", notification.userInfo?.keys ?? "") // NSStoreUUID, storeURL
        let storeID  = notification.userInfo?["NSStoreUUID"].debugDescription ?? ""
        let storeURL = notification.userInfo?["storeURL"   ].debugDescription ?? ""
        l.debug ("\n🟣 #notification  UUID \(storeID )  URL \(storeURL) ")
        if !abonnements.isEmpty {
            let nb      = abonnements.count
            let premier = abonnements.first.debugDescription
            l.debug("🟣 \(nb) abonnés, le premier est : \(premier)  ")
        }
//        print("🟣\n")



     // Exécuter le bloc de code dans la file d'attente de l'historique "historyRequestQueue"
      historyRequestQueue.async {
          self.l.info("🟣🟣🟣 Début d'éxécution de la file d'attente")
        // Obtenir un contexte dans lequel s'exécute une file d'attente privée. (pour ne pas bloquer)
        let backgroundContext = self.conteneur.newBackgroundContext()
        // Gérer chaque notification en série.
        backgroundContext.performAndWait {
//          print("🟣 1")
          // Récupérer l'historique des demandes posterieures au dernier jeton consigné (lastHistoryToken)
          let recupererHistorique = NSPersistentHistoryChangeRequest
            .fetchHistory(after: self.dernierEvenement) //self.dernierEvenement), au lieu de .distantPast pour depuis le debut des temps

          // Ne considerer que les transactions étrangeres (auteur et contexte)
          // Afin d’incorporer aux existantes uniquement les externes au contexte.
          // Identifier le contexte et l’auteur de création de cette transaction.
          if let requetteHistorique = NSPersistentHistoryTransaction.fetchRequest {
              let auteur   = ControleurPersistance.auteurTransactions ?? ""
              let contexte = ControleurPersistance.nomContexte
              self.l.info("🟣 Filtrer la requête sur \(auteur) et \(contexte)")
              //FIXME: A ECRIRE COMPLETEMENT
              
//            let predicatTout             = NSPredicate(value:true)
              
//            let predicatUnAutreAuteur_  = NSPredicate(format: "%K != %@", "author", ControleurPersistance.auteurTransactions!)
              let predicatUnAutreAuteur   = NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.author     ), ControleurPersistance.auteurTransactions ?? "") //as! CVarArg )

//            let predicatUnAutreContexte_ = NSPredicate(format: "%K != %@", "author", ControleurPersistance.nomContexte)
              let predicatUnAutreContexte  = NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.contextName), ControleurPersistance.nomContexte        )
            
              // Regarder uniquement les transactions créées par d'autres
//              requetteHistorique.predicate = predicatUnAutreAuteur
             
              // Regarder uniquement les transactions qui ne relèvent pas du contexte actuel
//              requetteHistorique.predicate = predicatUnAutreContexte
              
              // Regarder uniquement les transactions qui ne relèvent ni du contexte actuel ni de l'auteur
              var pred_NiAuteurNiContexte : [NSPredicate] = []
                  pred_NiAuteurNiContexte.append(predicatUnAutreAuteur)   // NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.author     ), ControleurPersistance.auteurTransactions ))
                  pred_NiAuteurNiContexte.append(predicatUnAutreContexte) // NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.contextName), ControleurPersistance.nomContexte        ))
              
              let predicatsNiAuteurNiContexte = NSCompoundPredicate(type: .and, subpredicates: pred_NiAuteurNiContexte)

              //MARK: Définition de la requête sur l'historique des transactions
              requetteHistorique.predicate = predicatsNiAuteurNiContexte // predicatUnAutreAuteur //predicatsNiAuteurNiContexte

              
              recupererHistorique.fetchRequest = requetteHistorique

              }


          do {
            let resultatRequeteHistorique = try backgroundContext.execute(recupererHistorique) as? NSPersistentHistoryResult
            guard
              // S'assurer qu'il y-a bien dans l'historique des transactions à traiter
              let transactions = resultatRequeteHistorique?.result as? [NSPersistentHistoryTransaction],
              !transactions.isEmpty
            else {
                self.l.info("🟣 Pas de transaction à traiter")
              return
              }
              
              self.l.info("🟣🟣 Il y-a dans l'historique des transactions à traiter")
            // Afficher les transactions de l'historique
            self.afficherLesEvolutions(from: transactions)
              
            // MàJ de notre contexte (viewContext) avec les changements issues de l'historique
            self.integrerLesEvolutions(from: transactions)
              self.l.info("🟣🟣🟣 MàJ dernierPoint")
            if let dernierPoint = transactions.last?.token {
            // Memoriser la derniere transaction
              self.consignerEvenement(dernierPoint)
                self.l.info("🟣🟣🟣 MàJ dernierPoint éffectuée")
            }
          } catch {
            let nsError = error as NSError
              self.appError = ErrorType( .trucQuiVaPas(num: 666) )
              self.l.error("🟣 Erreur de traitement de la requête sur l'historique des transactions : \(nsError)")
          }
        }
          self.l.info("🟣🟣🟣 Fin du Bloc")
          
      } // Fin du bloc "historyRequestQueue"
    
        l.info("🟣🟣🟣 Fin de traiterLesDernieresEvolutionsDuStockageDistant")
    } ////

    
    
    
    // MARK: - Gestion de l'historique

//    private
    func consulterMaPositionDansHistorique() {
        l.info("🟡 Retrouver ou j'en étais dans l'historique")
    // cf. loadHistoryToken
      do {
        let donnéesBrutes = try Data(contentsOf: urlFichierDesTokens) //tokenFileURL)
        // Regarder le dernier événement traité. (NSPersistentHistoryToken?)
        dernierEvenement = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: donnéesBrutes)
        print("🟡🟡 Le dernier événement consigné :", dernierEvenement?.hashValue ?? "...", "\n") //, dernierEvenement  ?? "")
        }
      catch {
        let nsError = error as NSError
        os_log(
          .error,
          log: .default,
          "🟡 Impossible de charger la consignation du dernier événement traité : %@",
          nsError)
        }
    }

    
    
    private func consignerEvenement(_ evenement: NSPersistentHistoryToken) {
        l.info("🟣🟣 Mémoriser ma position dans l'historique \(evenement.hashValue)")
        // cf storeHistoryToken
      do {
        let donnéesBrutes = try NSKeyedArchiver
          .archivedData(withRootObject: evenement, requiringSecureCoding: true)
        try donnéesBrutes.write(to: urlFichierDesTokens) // tokenFileURL)
        dernierEvenement = evenement
          l.info("🟣🟣 l'événement \(evenement.hashValue) est consigné")
      } catch {
        let nsError = error as NSError
//        os_log(
//          .error,
//          log: .default,
          l.error("Impossible de mémoriser le dernier événement traité : \(nsError)")
          
      }
    }
    
    
    
//    private func memoriserChronologie(_ evenement: NSPersistentHistoryToken) {
//      do {
//        let donnée = try NSKeyedArchiver.archivedData(
//            withRootObject: evenement,
//            requiringSecureCoding: true
//            )
//        try donnée.write(to: urlFichierDesTokens)
//        dernierEvenement = evenement
//        }
//      catch {
//        let nsError = error as NSError
//        os_log(
//          .error,
//          log: .default,
//          "Failed to write history token data file: %@",
//          nsError)
//        }
//    }

    
    
    private func afficherLesEvolutions(from historiqueDesTransactions: [NSPersistentHistoryTransaction]) {
    // cf. mergeChanges
//      let context = viewContext
        let contexte = conteneur.viewContext ///    ou newBackgroundContext() ??
        l.info("🟪 Affichons les évolutions (transactions)")
      contexte.perform {
        historiqueDesTransactions.forEach { transaction in
          // S'assurer qu'on a bien acces aux informations relatives à cette notification
          guard let infosNotification = transaction.objectIDNotification().userInfo else {
              self.l.info("🟪 Pas d'information spécifique pour cette transaction \(transaction.author ?? "") \(transaction.contextName ?? "") \(transaction.hashValue)   ")
              return
                }
//
            let jeton      = transaction.token.hashValue
            let _          = transaction.timestamp
            let numéro     = transaction.transactionNumber

            // details sur l'origine de la transaction
            let magasin    = transaction.storeID
            let bundle     = transaction.bundleID
            let processus  = transaction.processID
            let Kontexte   = transaction.contextName ?? "contexte inconnu"
            let auteur     = transaction.author      ?? "auteur inconnu"
            
            let _ = infosNotification.keys
            
            self.l.info ("🟪 Transaction № \(jeton) \(numéro), Magasin : \(magasin), Bundle : \(bundle), Processus : \(processus), Auteur : \(auteur), Contexte : \(Kontexte).")
            
            guard let évolutions = transaction.changes else { return }
            
            for évolution in évolutions {
                
                let _           = évolution.changedObjectID
                let changeID    = évolution.changeID
                let _           = évolution.transaction
                let changeType  = évolution.changeType
                
                switch(changeType) {
                case .update:
                    guard let updatedProperties = évolution.updatedProperties else {
                        self.l.info("\t🟪 MàJ № \(changeID) Pas de propriétés modifiées")
                        break
                        }
                    for updatedProperty in updatedProperties {
                        let nom = updatedProperty.name
                        self.l.info("\t🟪 MàJ № \(changeID) de la propriété : \(nom)")
                        }
                case .delete:
                    if let cimetière = évolution.tombstone {
                        let nom = cimetière["name"].debugDescription
                        self.l.info("\t🟪 Suppression № \(changeID) de : \(nom) ")
                        }
                default:
                    break
                }
            } // évolutions

        }
      } // perform
        l.info(" Fin de \(#function) \n\n")
    } // afficher
    
    /// MàJ de notre contexte (viewContext du conteneur) avec les changements issues de l'historique
    private func integrerLesEvolutions(from historiqueDesTransactions: [NSPersistentHistoryTransaction]) {
        l.info("🟣 Intégrer les évolutions")
    // cf. mergeChanges
//      let context = viewContext
      let contexte = conteneur.viewContext ///    ou newBackgroundContext() ??

      contexte.perform {
          historiqueDesTransactions.forEach { transaction in
              // S'assurer qu'on a bien accès aux informations relatives à cette notification
              guard
                let infosNotification = transaction.objectIDNotification().userInfo
              else { return }
                
              self.l.info("🟣🟣🟣 Intégrer la transaction : \(transaction.hashValue)")

              NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: infosNotification,
                into: [contexte]
                )
              self.l.info("🟣🟣🟣 Intégration terminée : \(transaction.hashValue)")

                // ERREUR :Vous avez enregistré un observateur de notification sur un objet qui a été libéré
                // et qui n'a pas supprimé l'observateur.
                // Ainsi, lorsqu'il essaie d'appeler le sélecteur, il plante.
                //
              }
        } // perform
        l.info(" Fin de \(#function) \n\n")
    } // integrerLesEvolutions

    private func faireLeMenage() {
//      let maintenant = Date() //
//      let deuxSemainesAuparavant = Calendar.current.date(byAdding: .day, value: -14, to: maintenant)!
        let laSemaineDerniere      = Date(timeIntervalSinceNow: TimeInterval(exactly: -604_800)!)

//      let netoyerHistorique_2 = NSPersistentHistoryChangeRequest.deleteHistory(before: deuxSemainesAuparavant)
        let netoyerHistorique   = NSPersistentHistoryChangeRequest.deleteHistory(before: laSemaineDerniere)

        
        
        // Exécuter le bloc de code dans la file d'attente de l'historique "historyRequestQueue"
         historyRequestQueue.async {
           // Obtenir un contexte dans lequel s'exécute une file d'attente privée. (pour ne pas bloquer)
           let backgroundContext = self.conteneur.newBackgroundContext()
           // Gérer chaque notification en série.
//           backgroundContext.execute(netoyerHistorique
                do {
        //          try persistentContainer.backgroundContext.execute(netoyerHistorique)
                    try backgroundContext.execute(netoyerHistorique)
                    }
                catch {
                    fatalError("Could not purge history: \(error)")
                    }
            }
        }

    
    lazy var fileAttenteOperation: OperationQueue = {
       var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
           
    
}
