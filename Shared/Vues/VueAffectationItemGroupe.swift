//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData

/// Associer à cet Item les groupes collaboratifs auxquels il desire participer ou ceux auxquels il participe
struct VueAffectationItemGroupe: View {
      
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs,
        animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
      
          
    @EnvironmentObject private var persistence: ControleurPersistance
    @Environment(\.managedObjectContext) private var viewContext
      
    @ObservedObject var groupe: Groupe // le StateObject est dans VuedetailGroupe

    /// Les groupes à affecter , initialisé vide et  renseigné par la  vue fille VueCelluleAffectationGroupe
    @State private var lesGroupesARetenir = Set<Groupe>()
    
    /// Retour d'information
    let traitementTerminéDe: (Bool, Set<Groupe>) -> Void

    var body: some View {
        NavigationView {
            Text("\(lesGroupesARetenir.count)")
            List(groupesCollaboratifs, id: \.id, selection: $lesGroupesARetenir) { gr in
                VueCelluleAffectationGroupe(
                    groupe,
                    groupeCiblePotentielle: gr,
//                    prisEnCompte: false,
                    affectations: $lesGroupesARetenir)
                }
              .navigationTitle(Text("Choisir les item groupes à affecter tes Thé"))
              .navigationBarItems(  trailing: Button("OK") { action_OK() }  )
            }
        }

//MARK: -
  /// Validation, par l'utilisateur, de la liste d'affectations actuellement affichée
  private func action_OK() {
    traitementTerminéDe(true, lesGroupesARetenir)
    }
    
    
}


