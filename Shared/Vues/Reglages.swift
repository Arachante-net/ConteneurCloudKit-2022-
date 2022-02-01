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
        fetchRequest: Item.extractionOrphelins,
        animation: .default)
    var orphelins: FetchedResults<Item>
    
    @FetchRequest(
        fetchRequest: Item.extractionIsolés,
        animation: .default)
    var isolés: FetchedResults<Item>
    
      
    @EnvironmentObject private var persistance: ControleurPersistance
    @Environment(\.managedObjectContext) private var contexte

    @State private var transacs : [NSPersistentHistoryTransaction] = []
       
    let utilisateur = Utilisateur()

    var body: some View {

        HStack {
            VStack(alignment: .leading) {
                Section(header: Text("Utilisateur").font(.title)) {
                    Text("Statut : ") .bold().foregroundColor(.secondary)
                    + Text("\(utilisateur.leStatut)")
                    let _ = utilisateur.isICloudContainerAvailable()
                    Text( utilisateur.obtenirID() ).font(.footnote).fontWeight(.thin) //.ultraLight)

                }.padding(.horizontal)

                Section(header: Text("Base de Données").font(.title)) {
                    Text("Conteneur local : ").bold().foregroundColor(.secondary)
                    + Text("\(persistance.nomConteneur)")
                    Text(", URL : ").bold().foregroundColor(.secondary)
                    + Text("\(persistance.conteneur.persistentStoreDescriptions.first!.url?.absoluteString ?? "") ")
                    
                    Text("Base CloudKit : ").bold().foregroundColor(.secondary)
                    + Text("\(persistance.conteneur.persistentStoreDescriptions.first!.cloudKitContainerOptions?.containerIdentifier ?? "") ")
                    
                    let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.Arachante.Espoir")
                    Text("Portée : ").bold().foregroundColor(.secondary)
                    + Text("\(options.__databaseScope) ") // 2 = privée ?
                    
                    Text("Modele : ").bold().foregroundColor(.secondary)
                    + Text("\(persistance.conteneur.managedObjectModel.entities.count) Entitées")
                    
                    ForEach (persistance.conteneur.managedObjectModel.entities.map {$0.name ?? ""} , id:\.self) { nom in
                        Text("   \(nom)")
                        }
                    
                }.padding(.horizontal)
                
    
                Divider()
//                Spacer()
                
                Text("\(orphelins.count) Orphelins (qui ne participent à aucun groupe)").bold()
                List {
                    ForEach(orphelins) {orphelin in
                        Text("° \(orphelin.titre ?? ".") ")
                        }
                    }
                Button("Enlever les items orphelins") {
                    orphelins.forEach() { orphelin in
                      supprimer(contexte: contexte, objet: orphelin as Item)
                      }
                    }
                
                Text("\(isolés.count) isolés (non assicié à un évenement prinipal)").bold()
                List {
                    ForEach(isolés) { Text("° \($0.titre ?? ".") ") }
                    }
                Button("Enlever les items isolés") {
                    isolés.forEach() { isolé in
                      supprimer(contexte: contexte, objet: isolé as Item)
                      }
                    }
                }
            
            
            
            
            VStack {
                Text("⭕️ Historique").bold()
                Button("⭕️ Ménage") {
                    let backgroundContext = persistance.conteneur.newBackgroundContext()
                    backgroundContext.performAndWait {
                        let recupererHistorique = NSPersistentHistoryChangeRequest
                          .fetchHistory(after: .distantPast)
                        if let requetteHistorique = NSPersistentHistoryTransaction.fetchRequest {
                            requetteHistorique.predicate = NSPredicate(format: "%K == %@", #keyPath(NSPersistentHistoryTransaction.contextName), "Groupe" )
                            //NSPredicate(value:true)
                            recupererHistorique.fetchRequest = requetteHistorique
                            }
                        
                        do {
                          let resultatRequeteHistorique = try backgroundContext.execute(recupererHistorique) as? NSPersistentHistoryResult
                          transacs = resultatRequeteHistorique?.result as! [NSPersistentHistoryTransaction]
                          guard
                            // S'assurer qu'il y-a bien dans l'historique des transactions à traiter
                            let transacs = resultatRequeteHistorique?.result as? [NSPersistentHistoryTransaction] ,
                            !transacs.isEmpty
                          else {
                            print("⭕️ Historique vide")
                            return
                            }
                            print("⭕️ Historique des transactions")
                            transacs.forEach() {transaction in
                                print("⭕️",
                                      transaction.timestamp.formatted(.dateTime.day().month().year()),
                                      "[",transaction.contextName ?? "...", "]",
                                      transaction.author ?? "...")
                                }
                            
                          } // do
                        catch {}
                    } // perform and wait
                    
                    
                    
                   }
                List {
                    ForEach(transacs, id: \.self) {transaction in
                        Text("\(transaction.timestamp.formatted(.dateTime.day().month().year())) [\(transaction.contextName ?? "")]     \(transaction.author ?? "") ")
                        }
                    }

                }
            }
        }
    }

func supprimer(contexte:NSManagedObjectContext, objet:NSManagedObject) {
    contexte.delete(objet)
    }

