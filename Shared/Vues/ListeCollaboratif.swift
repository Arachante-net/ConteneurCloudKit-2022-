//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData
import os.log

/// Lister les événements collaboratifs
struct ListeCollaboratif: View {
    

    
    /// Les données resultant de la requete  Groupe.extractionCollaboratifs
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs, // extraction, //ListeGroupeItem.extraction,
      animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
    
    
    
  @EnvironmentObject private var persistance : ControleurPersistance

  @Environment(\.managedObjectContext) private var viewContext
    

    
//  @Binding ?
  @State private var multiSelection = Set<Groupe>()
//  @State private var selectedItem: Groupe?


  var body: some View {
    HStack {
        List {
          ForEach (groupesCollaboratifs, id: \.self) { groupe in
              HStack{
                  Image(systemName: multiSelection.contains(groupe)  ? "circle.inset.filled" : "circle")
                  Text(groupe.nom ?? "...").opacity(multiSelection.contains(groupe) ? 0.5 : 1.0)
                  }.onTapGesture {
                      Logger.interfaceUtilisateur.info("TAP \(groupe.leNom) ")
                      if multiSelection.contains(groupe) {
                          Logger.interfaceUtilisateur.info("REMOVE \(groupe.leNom)")
                          multiSelection.remove(groupe)
                          }
                      else {
                          Logger.interfaceUtilisateur.info("INSERT \(groupe.leNom)")
                          multiSelection.insert(groupe)
                          }
                      Logger.interfaceUtilisateur.info("SELECT \(multiSelection.count)")
                  }
            }
          .toolbar { EditButton() }
          .navigationTitle(Text("Collaboratifs"))

        } .listStyle(.plain)
        .toolbar { EditButton() }

    Text("\(multiSelection.count) selections")
     }
    } // Body

    
    
    
  private func supprimerGroupes(positions: IndexSet) {
    withAnimation {
        persistance.supprimerObjets(positions.map { groupesCollaboratifs[$0] })
        }
    }


    
    
}

