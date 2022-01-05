//Arachante
// michel  le 02/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import Foundation
import CoreData




//extension Groupe {
//
//
//    /// Création d'un nouveau couple Groupe/Item
//    /// - Parameters:
//    ///   - titre: du groupe et du premier Item
//    ///   - collaboratif: ou individuel
//    static func creer(contexte:NSManagedObjectContext , titre:String, collaboratif:Bool=false) {
//        // créer un Item
//        let nouveauGroupe = fournirNouveau(contexte: contexte)
//            nouveauGroupe.collaboratif = collaboratif
//            nouveauGroupe.nom = titre
//            nouveauGroupe.createur = UserDefaults.standard.string(forKey: "UID") ?? "anonyme"
//
//        let nouvelItem    = Item.fournirNouveau(contexte: contexte , titre:titre)
//            nouvelItem.addToGroupes(nouveauGroupe)
//
//            nouveauGroupe.addToItems(nouvelItem)
//
//        // sauver le contexte
//        // persistance
//        do {
//            contexte.name = "Groupe"
//            try contexte.save()
////            try persistance.sauverContexte()
////            contexte.transactionAuthor = nil
//            }
//        catch {
//            //TODO: Peut mieux faire
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//
//
//    /// Créer un nouvel Item et le faire participer  à ce groupe collaboratif
//    /// - Parameters:
//    ///   - contexte: <#contexte description#>
//    ///   - titre: de l'item
//    func enrôler(contexte:NSManagedObjectContext , titre:String) {
//        guard self.collaboratif else {
//            print("ERREUR le groupe", self.nom ?? "?" , "n'est pas collaboratif")
//            return
//            }
//        let nouvelItem = Item.fournirNouveau(contexte: contexte , titre: self.nom! + titre)
//        nouvelItem.addToGroupes(self)
//        self.addToItems(nouvelItem)
//
//        // sauver le contexte
////        controleurDePersistance.sauverContexte()
//        // persistance....
//        do {
//            contexte.name = "Groupe"
//            try contexte.save()
////            try persistance.sauverContexte()
////            contexte.transactionAuthor = nil
//            }
//        catch {
//            //TODO: Peut mieux faire
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//    }
//
//
//    /// Ce groupe incluera un  ou plusieurs items  existants
//    /// - Parameters:
//    ///   - contexte:
//    func enrôler(contexte:NSManagedObjectContext , recrues: Set<Item>) {
//        guard self.collaboratif else {
//            print("Le groupe", self.nom ?? "" , "n'est pas collaboratif")
//            return
//            }
//
//        self.items = (self.items as! Set<Item>).union(recrues) as NSSet
//        recrues.forEach {nouvelleRecrue in
//            print ("⚾︎ Traitement item", nouvelleRecrue.titre ?? "...")
//            var lesGroupesDeLaNouvelleRecrue = nouvelleRecrue.groupes as! Set<Groupe>
//            let (inséré,  aprèsInsertion) = lesGroupesDeLaNouvelleRecrue.insert(self)
//            print("⚾︎ Inséré :" , inséré,
//                  "après :"  , aprèsInsertion,
//                  "les"      , lesGroupesDeLaNouvelleRecrue.count,
//                  "groupes :", lesGroupesDeLaNouvelleRecrue)
//            }
//        }
//
//
//
//
//    /// Participer  à  un  ou plusieurs groupes collaboratifs existants
//    /// - Parameters:
//    ///   - contexte:
////    func rallier(contexte:NSManagedObjectContext , items: Set<Item>) {
////        guard
////            // je suis bien collabotatif
////            self.collaboratif,
////
////            // ceux que je veux rejoindre aussi
////           ( groupes.reduce(true) {$0 && $1.collaboratif} )
////
////        else {
////            print("ERREUR un groupe n'est pas collaboratif")
////            return
////            }
////
////        groupes.forEach {groupe in
////            self.lesItems.insert(items)             }
////
////        }
//
//   }

// ------------

//    extension Item {
//        
//        /// Cet Item participera à  un  ou plusieurs groupes collaboratifs existants
//        /// - Parameters:
//        ///   - contexte:
////        func rallier_(contexte:NSManagedObjectContext , groupes: Set<Groupe>) {
////            guard
////                // Les groupes que je veux rejoindre sont bien tous collaboratifs
////               ( groupes.reduce(true) {$0 && $1.collaboratif} )
////                
////            else {
////                print("ERREUR un des groupes visés n'est pas collaboratif")
////                return
////                }
////            
////            // Ajouter les groupes passés en parametre à la liste des groupes auquel participe déja cet Item
////
////            // NSSet?    =
////            self.groupes = (self.groupes as! Set<Groupe>).union(groupes) as NSSet
//////                .insert(groupes)
////            groupes.forEach {groupe in
////            //            self.lesItems.insert(items)
////            }
////
////        
////            }
//        
//        /// Cet Item participera à  une communauté de  groupes collaboratifs existants
//        /// - Parameters:
//        ///   - contexte:
//        ///   - communauté : un  ou plusieurs groupes collaboratifs
//        func rallier(contexte:NSManagedObjectContext , communauté: Set<Groupe>) {
//       
////            guard // un seul group
////                //FIXME: condition inclue dans la garde suivante, Inutile si rien de specifique
////                lesGroupes.count == 1 &&
////                // ET il est bien collaboratif
////                lesGroupes.first?.collaboratif ?? false else {
////                    print("⚾︎ ERREUR l'unique groupe actuel", lesGroupes.first?.nom ?? "..." ,"n'est pas collaboratif")
////                    return
////                    }
//            
//            guard // mes groupes actuels sont bien tous collaboratifs
//                (lesGroupes.reduce(true) {$0 && $1.collaboratif} ) else {
//                    print("⚾︎ ERREUR un des groupes actuels de l'item", titre ?? "" ,"n'est pas collaboratif")
//                    lesGroupes.forEach { print("⚾︎", $0.nom ?? "..." , $0.collaboratif) }
//                    return
//                    }
//            
//            guard // Les groupes que je veux rejoindre sont bien tous collaboratifs
//                ( communauté.reduce(true) {$0 && $1.collaboratif} ) else {
//                
//                    print("⚾︎ ERREUR un des groupes visés n'est pas collaboratif")
//                    communauté.forEach { print("⚾︎", $0.nom ?? "..." , $0.collaboratif) }
//                    return
//                    }
//            
//            self.groupes = (self.groupes as! Set<Groupe>).union(communauté) as NSSet
//            communauté.forEach {nouveauGroupe in
//                print ("⚾︎ Traitement groupe", nouveauGroupe.nom ?? "...")
//                var lesGroupesDeLaNouvelleRecrue = nouveauGroupe.items as! Set<Item>
//                let (inséré,  aprèsInsertion) = lesGroupesDeLaNouvelleRecrue.insert(self)
//                print("⚾︎ Inséré :" , inséré,
//                      "après :"  , aprèsInsertion,
//                      "les"      , lesGroupesDeLaNouvelleRecrue.count,
//                      "groupes :", lesGroupesDeLaNouvelleRecrue)
//                }
//            }
//
//        
//        func supprimer(contexte:NSManagedObjectContext) {
//            
//            lesGroupes.forEach { groupe in
//                print("Suppression de" ,titre ?? "..." , "du groupe ", groupe.nom ?? "..." )
////                ( groupe.items as! Set<Item>).remove(self)
////                groupe.lesItems.remove(self)
////     @NSManaged public func removeFromGroupes(_ values: NSSet)
//                self.removeFromGroupes(groupes ?? [])
////                var TT = groupe.lesItems
////                var T = groupe.items as! Set<Item> // NSSet?
////                if T.contains(self) {
////                    print("OK")
////                    T.remove(self)
////                    }
//                }
//            }
//
//        
//        }
    

