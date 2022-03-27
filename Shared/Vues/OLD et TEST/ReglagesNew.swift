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

struct ReglagesNew: View {

//    @FetchRequest(
//        fetchRequest: Item.extractionOrphelins,
//        animation: .default)
//    var orphelins: FetchedResults<Item>
//
//    @FetchRequest(
//        fetchRequest: Item.extractionIsolés,
//        animation: .default)
//    var isolés: FetchedResults<Item>


    @EnvironmentObject private var persistance: ControleurPersistance
    @Environment(\.managedObjectContext) private var contexte

    @State private var transacs : [NSPersistentHistoryTransaction] = []

    let utilisateur = Utilisateur()

    var body: some View {

        HStack {
            Text("Titre")
            } // HStack
        } // Body
    } // Reglages




func supprimer(contexte:NSManagedObjectContext, objet:NSManagedObject) {
    contexte.delete(objet)
    }

