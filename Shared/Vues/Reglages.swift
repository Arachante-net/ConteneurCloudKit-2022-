//Arachante
// michel  le 21/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import SwiftUI
import CoreData
import CloudKit
//import UIKit

struct Reglages: View {
    
    @FetchRequest(
      fetchRequest: Item.extractionItems,
      animation: .default)
    var items: FetchedResults<Item>
    
    @FetchRequest(
      fetchRequest: Groupe.extractionGroupes,
      animation: .default)
    var groupes: FetchedResults<Groupe>

    @FetchRequest(
        fetchRequest: Item.extractionOrphelins,
        animation: .default)
    var orphelins: FetchedResults<Item>
    
//    @FetchRequest(
//        fetchRequest: Groupe.extractionSteriles,
//        animation: .default)
//    var stériles: FetchedResults<Groupe>
    
    @FetchRequest(
        fetchRequest: Item.extractionIsolés,
        animation: .default)
    var isolés: FetchedResults<Item>
    
      
    @Environment(\.managedObjectContext) private var contexte

    @State private var transacs : [NSPersistentHistoryTransaction] = []
       
    @EnvironmentObject private var persistance: ControleurPersistance
//    @EnvironmentObject private var nuage: Nuage
    @EnvironmentObject private var utilisateur: Utilisateur
    
  


    var body: some View {
//        let _ = Nuage.evaluerStatut()
        ScrollView {

            HStack {
                VStack(alignment: .leading) {
                    //MARK: - Utilisateur
                    Section(header: Text("Utilisateur").font(.title)) {
                        Text("Compte : ") .bold().foregroundColor(.secondary)
                        + Text("\(utilisateur.nomComplet)")
                        Text("Statut : ") .bold().foregroundColor(.secondary)
                        + Text("\(persistance.statut)")
                        Text("Système : ") .bold().foregroundColor(.secondary)
                        + Text("\(utilisateur.systeme)")
                        Text("Hôte : ") .bold().foregroundColor(.secondary)
                        + Text("\(utilisateur.nomAppareil)")
                        + Text("  (\(utilisateur.idAppareil?.uuidString ?? "..."))").font(.footnote).fontWeight(.thin) //.ultraLight)
                    }.padding(.horizontal)
                    Spacer()
                    Section(header: Text("Base de Données locale").font(.title)) {
                        Text("Conteneur : ").bold().foregroundColor(.secondary)
                        + Text("\(persistance.nomConteneur)")

    //                    let urlText:Text = Text("\(persistance.conteneur.persistentStoreDescriptions.first!.url?.absoluteString ?? "") ")
    //                        .truncationMode(.middle)
                        Text("URL : ").bold().foregroundColor(.secondary)
                        Text("\(persistance.conteneur.persistentStoreDescriptions.first!.url?.absoluteString ?? "") ")
                            .lineLimit(1)
                            .truncationMode(.middle)
                        }.padding(.horizontal)
                    Spacer()
                        //MARK: - CloudKit
                    Section(header: Text("Base de Données CloudKit").font(.title)) {
                        Text("Conteneur : ").bold().foregroundColor(.secondary)
                        + Text("\(persistance.conteneur.persistentStoreDescriptions.first!.cloudKitContainerOptions?.containerIdentifier ?? "") ")
                        let idG = Groupe().objectID
    //                    let partages = try persistance.conteneur.fetchShares(matching: [idG])

//                        let _ = testPartage(conteneur: persistance.conteneur)
                        
                        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.Arachante.Espoir")
                        
                        Text("Portée : ").bold().foregroundColor(.secondary)
                        + Text(persistance.portée)
    //                    + Text(nuage.enregistrement)
                        Text("Zone : ").bold().foregroundColor(.secondary)
                        + Text(persistance.zone)
                        Text("Abonnement : ").bold().foregroundColor(.secondary)
                        + Text(persistance.abonnement)
                        Text("Autorisation : ").bold().foregroundColor(.secondary)
                        + Text(persistance.permissions)
                        Text("Proprietaire : ").bold().foregroundColor(.secondary)
                        + Text(persistance.proprietaire)
                        Text("Nom : ").bold().foregroundColor(.secondary)
                        + Text("\(persistance.prenom) \(persistance.nom) \(persistance.aUnCompte.voyant)")
                    }.padding(.horizontal)
                    Spacer()
                        //MARK: - CoreData
                    Section(header: Text("Modèle de données").font(.title)) {
                        Text("Entitées : ").bold().foregroundColor(.secondary)
                        + Text("\(persistance.conteneur.managedObjectModel.entities.count) ")

                        ForEach (persistance.conteneur.managedObjectModel.entities.map {$0.name ?? ""} , id:\.self) { nom in
                            Text("   \(nom)")
                            }

                    }.padding(.horizontal)


                    Divider()
//                    Spacer()
                    Section(header: Text("Maintenance").font(.title)) {
                        

                    ForEach(groupes, id: \.self) { (groupe:Groupe) in
                        // trouver les items dont le groupe courant est le principal
                        let liés  = items.filter { $0.principal == groupe }
                        // trouver les items qui sont les principaux du groupe courant
                        let liés2 = items.filter { groupe.principal == $0 }

                        Text("G | \(groupe.leNom) : \(liés.count) & \(liés2.count) ")
                        }
                        
                    ForEach(items, id: \.self) { (item:Item) in
                        // trouver les groupes dont le principal est l'item courant
                        let liés  = groupes.filter { $0.principal   == item } .count
                        // trouver les groupes qui sont les principaux de l'item courant
                        let liés2 = groupes.filter { item.principal == $0 } .count
                        let indicateur = liés * liés2
                        Text("I | \(item.leTitre) :  \(liés) & \(liés2) ") .foregroundColor(indicateur == 0 ? .red : .gray)
                        }
                        
//                    ForEach(items, id: \.self) { (item:Item) in
//                        Text(" \(item.leTitre) ") //\(groupes.filter( {groupe in item.principal == groupe} ).count) ")
//                        }
                        
//                    Text("\(stériles.count) Groupes stériles (sans principal)").bold()

//                    ForEach(stériles, id: \.self) { (sterile:Groupe) in
//                        Text("○ \(sterile.leNom) ")
//                        }
//
//                    Button("Enlever les groupes stériles (qui n'ont pas de principal)") {
//                        stériles.forEach() { stérile in
//                          supprimer(contexte: contexte, objet: stérile as Groupe)
//                          persistance.sauverContexte( depuis: "Réglages")
//                          }
//                        }
//                    Spacer()
                        
                    Text("\(orphelins.count) Items Orphelins (items qui ne participent à aucun groupe)").bold()
//                    Text("1er \(orphelins.first?.titre ?? ".") ")
                        
                        ForEach(orphelins, id: \.self) { (orphelin:Item) in
//                            let _ = print("🌀°°°°°", orphelin.titre ?? ".")
                            Text("° \(orphelin.titre ?? ".") ")
                            }
                   
//                    Text("Der \(orphelins.last?.titre ?? ".") ")

                        
//                        let _ = orphelins.forEach() {print("🌀°°°°°", $0.titre ?? ".")}
//
//                        ForEach(orphelins) {_ in
//                            let _ = print("🌀🌀🌀°°°°°")
////                            Text("° \(orphelin.titre ?? ".") ")
//                            }
//
//                        ForEach(orphelins) {orphelin in
//                            let _ = print("🌀°°°°°", orphelin.titre ?? ".")
//                            Text("° \(orphelin.titre ?? ".") ")
//                            }
//                        }
                    Button("Enlever les items orphelins") {
                        orphelins.forEach() { orphelin in
                          supprimer(contexte: contexte, objet: orphelin as Item)
                          }
                        }
//                    Spacer()
                    Text("!!! \(isolés.count) isolés (non associé à un évenement prinipal)").bold()
//                    List {
                        ForEach(isolés, id: \.self) { (isolé:Item) in
                            Text("° \(isolé.leTitre) ")
                            }
//                        }
                    Button("Enlever les items isolés") {
                        isolés.forEach() { isolé in
                          supprimer(contexte: contexte, objet: isolé as Item)
                          }
                        }
                    }
                
                
                
                
    //            VStack {
    ////                Text("⭕️ Historique").bold()
    //
    //
    ////                Button("⭕️ Ménage") {
    ////                    let backgroundContext = persistance.conteneur.newBackgroundContext()
    ////                    backgroundContext.performAndWait {
    ////                        let recupererHistorique = NSPersistentHistoryChangeRequest
    ////                          .fetchHistory(after: .distantPast)
    ////                        if let requetteHistorique = NSPersistentHistoryTransaction.fetchRequest {
    ////                            requetteHistorique.predicate = NSPredicate(format: "%K == %@", #keyPath(NSPersistentHistoryTransaction.contextName), "Groupe" )
    ////                            //NSPredicate(value:true)
    ////                            recupererHistorique.fetchRequest = requetteHistorique
    ////                            }
    ////
    ////                        do {
    ////                          let resultatRequeteHistorique = try backgroundContext.execute(recupererHistorique) as? NSPersistentHistoryResult
    ////                          transacs = resultatRequeteHistorique?.result as! [NSPersistentHistoryTransaction]
    ////                          guard
    ////                            // S'assurer qu'il y-a bien dans l'historique des transactions à traiter
    ////                            let transacs = resultatRequeteHistorique?.result as? [NSPersistentHistoryTransaction] ,
    ////                            !transacs.isEmpty
    ////                          else {
    ////                            print("⭕️ Historique vide")
    ////                            return
    ////                            }
    ////                            print("⭕️ Historique des transactions")
    ////                            transacs.forEach() {transaction in
    ////                                print("⭕️",
    ////                                      transaction.timestamp.formatted(.dateTime.day().month().year()),
    ////                                      "[",transaction.contextName ?? "...", "]",
    ////                                      transaction.author ?? "...")
    ////                                }
    ////
    ////                          } // do
    ////                        catch {}
    ////                    } // perform and wait
    ////
    ////
    ////
    ////                   } // bouton ménage
    //
    //
    ////                List {
    ////                    ForEach(transacs, id: \.self) {transaction in
    ////                        Text("\(transaction.timestamp.formatted(.dateTime.day().month().year())) [\(transaction.contextName ?? "")]     \(transaction.author ?? "") ")
    ////                        }
    ////                    }
    //
    //
    //
    ////                 ForEach(Icones.allCases, id: \.self) { val in
    ////                     HStack {
    ////                         val.imageSystéme
    ////                             .scaleEffect(2, anchor: .leading)
    ////                             .padding()
    ////                         Text(val.rawValue)
    ////                         }//.tag(val)
    ////                    }
    //
    //            } //VStack
                
                
                } // HStack
            } // Body
        }
        } // Reglages



///// Test le partage des composants du conteneur
//func testPartage(conteneur:NSPersistentCloudKitContainer) {
////    let idG = Groupe().objectID
////    print("🌀 idG", idG.debugDescription)
////    let conteneurCloudKit = CKContainer(identifier: "iCloud.Arachante.Espoir")
//
//    let partages = try? conteneur.fetchShares(matching: [Groupe().objectID, Item().objectID]) //  [NSManagedObjectID : CKShare]?
//    print("🌀 partage",[Groupe().objectID, Item().objectID],  partages ?? "", partages?.count ?? 0)
//    let premier = partages?.first // Dictionary<NSManagedObjectID, CKShare>.Element?
//    let partage = premier?.value
//    print("🌀 partage", partage ?? "...")
//    let proprio = partage?.owner
//    let participant = partage?.participants
//    let participants = partage?.currentUserParticipant
//    print("🌀 partage, proprio", proprio ?? "", "participant(s)", participant ?? "", participants)
//} // test Partage

//func isShared(objectID: NSManagedObjectID) -> Bool {
//        var isShared = false
//        if let persistentStore = objectID.persistentStore {
//            if persistentStore == sharedPersistentStore {
//                isShared = true
//            } else {
//                let container = persistentContainer
//                do {
//                    let shares = try container.fetchShares(matching: [objectID])
//                    if shares.first != nil {
//                        isShared = true
//                    }
//                } catch {
//                    print("Failed to fetch share for \(objectID): \(error)")
//                }
//            }
//        }
//        return isShared
    
    
    }

//func isOwner(object: NSManagedObject) -> Bool {
//     guard isShared(object: object) else { return false }
//     guard let share = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
//         print("Get ckshare error")
//         return false
//     }
//     if let currentUser = share.currentUserParticipant, currentUser == share.owner {
//         return true
//     }
//     return false
// }

func supprimer(contexte:NSManagedObjectContext, objet:NSManagedObject) {
    contexte.delete(objet)
    }

