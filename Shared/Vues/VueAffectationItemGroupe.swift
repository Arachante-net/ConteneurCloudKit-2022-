//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData

/// Associer à cet Item les groupes collaboratifs auxquels il desire participer
struct VueAffectationItemGroupe: View {
      
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs,
        animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
      
          
    @EnvironmentObject private var persistence: ControleurPersistance //    PersistenceController
    @Environment(\.managedObjectContext) private var viewContext
      

    @State var lesGroupesARetenir: Set<Groupe>
    let traitementTerminéDe: (Set<Groupe>) -> Void

    var body: some View {
        NavigationView {
            List(groupesCollaboratifs, id: \.id, selection: $lesGroupesARetenir) { groupe in
                VueCelluleItemGroupe(groupe: groupe, selection: $lesGroupesARetenir)
                }
              .navigationTitle(Text("Choisir les groupes à rallier"))
              .navigationBarItems(  trailing: Button("OK") { action_OK() }  )
            }
        }

//MARK: -
  private func action_OK() {
    traitementTerminéDe(lesGroupesARetenir)
    }
    
    
}


