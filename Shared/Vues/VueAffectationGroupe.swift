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
      
//    @FetchRequest var groupesCollaboratifsSaufMoi: FetchedResults<Groupe>

    @EnvironmentObject private var persistence: ControleurPersistance
    @Environment(\.managedObjectContext) private var viewContext
      
    @ObservedObject var groupe: Groupe // le StateObject est dans VuedetailGroupe
//    @Binding var groupe:Groupe
    
    // le choix de l'utilisateur
    @Binding var lesGroupesAAffecter: Set<Groupe>
    
    // Enroler (aller chercher des collaborateurs) ou Collaborer (rejoindre un groupe)
    @Binding var modeAffectation :ModeAffectationGroupes
    
    // Retour vers la vue appelante du resultat de la feuille (sheet) d'affectation
    let lesRéaffectationsSontRéalisées: (Bool) -> Void //, Set<Groupe>) -> Void
    let lesGroupesInitialementAffectés: Set<Groupe>
    // On passe par un init() afin de construire la requête groupesCollaboratifsSaufMoi
    // Nous avons alors deux methodes pour lister les affectations possibles :
    //   List(groupesCollaboratifsSaufMoi) ...
    //   List(groupesCollaboratifs.filter() { $0 != groupe} ...
    //TODO: C'est quoi le mieux ?
    init(groupe               : ObservedObject<Groupe>,
         id                   : UUID,
         lesGroupesAAffecter  : Binding<Set<Groupe>>,
         modeAffectation      : Binding<ModeAffectationGroupes>,
         affectationsRéalisées: @escaping (Bool) -> Void) { //}, Set<Groupe>) -> Void) {
        
        _groupe              = groupe  
        _lesGroupesAAffecter = lesGroupesAAffecter
        _modeAffectation     = modeAffectation
        
        lesGroupesInitialementAffectés      = lesGroupesAAffecter.wrappedValue
        self.lesRéaffectationsSontRéalisées = affectationsRéalisées 
        
//        _groupesCollaboratifsSaufMoi = FetchRequest<Groupe>(
//            sortDescriptors: [],
//            predicate: NSPredicate(format: "(collaboratif == true) AND (NOT id == %@)", id as CVarArg))
        }
    
    var body: some View {
        NavigationView {
            VStack {
//                List(groupesCollaboratifsSaufMoi) { Text($0.leNom)}
                
                Text("\(modeAffectation.description ?? "")")
                List(groupesCollaboratifs.filter() { $0 != groupe}, id: \.id, selection: $lesGroupesAAffecter) { grp in
                    VueCelluleAffectationGroupe(
                        groupe,
                        groupeCiblePotentielle: grp,
                        affectations: $lesGroupesAAffecter)
                    }
                }
            .toolbar {
//                ToolbarItemGroup() { //placement:   .automatic) { //}.navigationBarTrailing) {
//                    Button("<< OK >>") { action_OK() }
//                    }
                
                ToolbarItem(placement: .confirmationAction ) {
                    Button( action: action_OK ) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Valider").font(.caption)
                            }
                      }
                    .buttonStyle(.borderedProminent) }
                
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: abandonerAffectation) {
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
  private func action_OK() {
      print(">>>" ,lesGroupesAAffecter.count , "groupes collaboratifs retenus." )
      lesRéaffectationsSontRéalisées(true) //, lesGroupesAAffecter)
    }
 
    private func abandonerAffectation() {
        print(" On revient à \(lesGroupesInitialementAffectés.count), plutot qu'à \(lesGroupesAAffecter.count) ")
        lesRéaffectationsSontRéalisées(false) //, lesGroupesInitialementAffectés)
        }
    
}


