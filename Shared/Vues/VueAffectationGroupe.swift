//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData

/// Associer (Rallier ou Abandonner,  Enrôler ou Révoquer)  ce groupe à d'autres groupes, avec lesquels il collaborera.
struct VueAffectationGroupe: View {
      
    @FetchRequest(
        fetchRequest: Groupe.extractionCollaboratifs,
        animation: .default)
    private var groupesCollaboratifs: FetchedResults<Groupe>
      
    @FetchRequest var groupesCollaboratifsSaufMoi: FetchedResults<Groupe>

    @EnvironmentObject private var persistence: ControleurPersistance
    @Environment(\.managedObjectContext) private var viewContext
    
    // La source de veritée, le StateObject, est dans VuedetailGroupe
    @ObservedObject var groupe: Groupe
    
    /// Les choix de l'utilisateur
    @Binding var groupesAReaffecter: Set<Groupe>
    
    /// Enrôler (aller chercher des collaborateurs) ou Collaborer (rejoindre un groupe)
    @Binding var modeAffectation: ModeAffectationGroupes
    
    // Retour vers la vue appelante du resultat de la feuille (sheet) d'affectation
    let lesRéaffectationsSontRéalisées: (Bool) -> Void
    
    
    // On passe par un init() afin de construire la requête groupesCollaboratifsSaufMoi
    // Nous avons alors deux methodes pour lister les affectations possibles :
    //   List(groupesCollaboratifsSaufMoi) ...
    //   List(groupesCollaboratifs.filter() { $0 != groupe} ...
    //TODO: C'est quoi le mieux ? Valider le NSPredicate
    init(_ unGroupe           : Groupe,
         lesGroupesAAffecter  : Binding<Set<Groupe>>,
         modeAffectation      : Binding<ModeAffectationGroupes>,
         affectationsRéalisées: @escaping (Bool) -> Void) {
        
            _groupe              = ObservedObject<Groupe>(wrappedValue : unGroupe)
            _groupesAReaffecter  = lesGroupesAAffecter
            _modeAffectation     = modeAffectation
            
            lesRéaffectationsSontRéalisées = affectationsRéalisées
            
        _groupesCollaboratifsSaufMoi = FetchRequest<Groupe>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "(collaboratif == true) AND (NOT id == %@)", unGroupe.id! as CVarArg))
        }
    
    var body: some View {
        NavigationView {
            VStack {
                List(groupesCollaboratifsSaufMoi) { Text($0.leNom)}
                
                Text("\(modeAffectation.description ?? "")")
                List(groupesCollaboratifs.filter() { $0 != groupe}, id: \.id, selection: $groupesAReaffecter) { grp in
                    VueCelluleAffectationGroupe(
                        groupe,
                        groupeCiblePotentielle: grp,
                        affectations: $groupesAReaffecter)
                    }
                }
            .toolbar {
//                ToolbarItemGroup() { //placement:   .automatic) { //}.navigationBarTrailing) {
//                    Button("<< OK >>") { action_OK() }
//                    }
                
                ToolbarItem(placement: .confirmationAction ) {
                    Button( action: validerAffectations ) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Valider").font(.caption)
                            }
                      }
                    .buttonStyle(.borderedProminent) }
                
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: abandonerAffectations) {
                        VStack {
                            Image(systemName: "arrowshape.turn.up.left.circle.fill")
                            Text("Abandon").font(.caption)
                            }
                      }
                    }
                }
//            .navigationTitle(Text("Choisir les groupes à affecter à \(groupe.leNom)"))
        }.onAppear() {
            print("onAppear VueAffectationGroupe")
            var test = Set<Groupe>(groupesCollaboratifs)
            var _ = test.remove(groupe)
            
        } // as Set<Groupe>

        }

    
    
    
    
//MARK: -
  private func validerAffectations() {
      lesRéaffectationsSontRéalisées(true)
    }
 
    private func abandonerAffectations() {
        lesRéaffectationsSontRéalisées(false)
        }
    
}


