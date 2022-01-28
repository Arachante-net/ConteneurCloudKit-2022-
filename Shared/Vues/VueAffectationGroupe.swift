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
struct VueAffectationGroupe: View {
      
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs,
        animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
      
          
    @EnvironmentObject private var persistence: ControleurPersistance
    @Environment(\.managedObjectContext) private var viewContext
      
    @Binding var groupe:Groupe
    @Binding var lesGroupesAAffecter: Set<Groupe>
    
    @Binding var modeAffectation :ModeAffectationGroupes
    
    let traitementTerminéDe: (Set<Groupe>) -> Void
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(modeAffectation.description ?? "")")
                List(groupesCollaboratifs.filter() { $0 != groupe}, id: \.id, selection: $lesGroupesAAffecter) { grp in
//                List(test, id: \.id, selection: $lesGroupesAAffecter) { grp in
//                    VueCelluleAffectationGroupe(groupe: gr, selectionDeGroupes: $lesGroupesARetenir)
//                    let bip = groupe.estMonPrincipal(groupe: gr)
                    VueCelluleAffectationGroupe(
                        groupe,
                        groupeCiblePotentielle: grp,
//                        prisEnCompte: groupe.estMonPrincipal(groupe: grp),
                        affectations: $lesGroupesAAffecter)
                    }
                }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("<< OK >>") { action_OK() }
                    }
                }
            .navigationTitle(Text("Choisir les groupes à affecter à \(groupe.leNom)"))
        }.onAppear() {
            var test = Set<Groupe>(groupesCollaboratifs)
            var test2 = test.remove(groupe)
            
        } // as Set<Groupe>

        }

    
    
    
    
//MARK: -
  private func action_OK() {
      print(">>>" ,lesGroupesAAffecter.count , "groupes collaboratifs retenus." )
      traitementTerminéDe(lesGroupesAAffecter)
    }
    
    
}


