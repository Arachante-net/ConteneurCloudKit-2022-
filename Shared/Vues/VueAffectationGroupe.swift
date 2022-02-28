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
///  - parameters
///     La liste des groupes qui collaborent actuellement à mon objectif
///     La Liste des groupes auxquels je collabore actuellement
///  - returns
///     Le mode d'affectation retenu (Rallier ou Enrôler)
///     La liste d'affectation
///
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
    
    /// Les affectations retenues par l'utilisateur (rallier ou enrôler)
    @Binding var groupesAReaffecter: Set<Groupe>
    
    /// Type d'affectations : Enrôler (aller chercher des collaborateurs) ou Collaborer (rejoindre un groupe)
    @Binding var modeAffectation: AffectationGroupes

    typealias RetourDinfos = (Bool, AffectationGroupes) -> Void
    
    // Retour d'information vers la vue appelante du resultat de la feuille (sheet) d'affectation
    let reponseAmaMère: RetourDinfos //(Bool, AffectationGroupes) -> Void
    
    
    
    // On passe par un init() afin de construire la requête groupesCollaboratifsSaufMoi
    // Nous avons alors deux methodes pour lister les affectations possibles :
    //   List(groupesCollaboratifsSaufMoi) ...
    //   List(groupesCollaboratifs.filter() { $0 != groupe} ...
    //TODO: C'est quoi le mieux ? Valider le NSPredicate
    init(_ unGroupe           : Groupe,
         /// Les groupes qui collaborent à mon objectif
         lesCollaborateursAAffecter : Binding<Set<Groupe>>,
         /// Les groupes auxquels je collabore
         lesChefsADesigner          : Binding<Set<Groupe>>, //TODO: pour un chef c'est pas affecter
         /// La nature (enrôler ou rallier) des affectations en cours
         modeAffectation            : Binding<AffectationGroupes>,
         /// Retour d'information (la liste d'affectations)
         affectationsRéalisées: @escaping RetourDinfos ) {
        
            _groupe              = ObservedObject<Groupe>(wrappedValue : unGroupe)
        
            _modeAffectation     = modeAffectation
        
            // Un jeu de Groupes vide
            let bindingVide = Binding<Set<Groupe>>(
                get: { Set<Groupe>() },
                set: {_ in }
                )
                    
            switch modeAffectation.wrappedValue {
                    /// On enrôle des collaborateurs
                case .enrôlement : _groupesAReaffecter = lesCollaborateursAAffecter
                    /// On rallie des chefs
                case .ralliement : _groupesAReaffecter = lesChefsADesigner
                    /// ... On s'amuse
                case .test : _groupesAReaffecter =  bindingVide
                }
                            
            reponseAmaMère = affectationsRéalisées
            
            _groupesCollaboratifsSaufMoi = FetchRequest<Groupe>(
                sortDescriptors: [],
                predicate: NSPredicate(format: "(collaboratif == true) AND (NOT id == %@)", unGroupe.id! as CVarArg))
               
            // Pour l'apparence du picker segmenté
            UISegmentedControl.appearance().selectedSegmentTintColor = .link
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label ], for: .normal )
            }
    
    var body: some View {
        NavigationView {
            VStack {
//              List(groupesCollaboratifsSaufMoi) { Text($0.leNom)} //TODO: Voir quelle technique garder
                
                Picker("Affectation", selection: $modeAffectation) {
                    ForEach(AffectationGroupes.allCases, id: \.self) {
                        Text($0.rawValue).foregroundColor(.accentColor)
                    }
                }
                .pickerStyle(.segmented)
                .foregroundColor(.accentColor)
                .padding()
                
                Text("\(modeAffectation.description ?? "")")
                
                List(groupesCollaboratifs.filter() { $0 != groupe}, id: \.id, selection: $groupesAReaffecter) { grp in
                    VueCelluleAffectationGroupe(
                        groupe,
                        groupeCiblePotentielle: grp,
                        
                        affectations: $groupesAReaffecter)
                    }
                }
            
            .toolbar {
                ToolbarItem(placement: .confirmationAction ) {
                    Button( action: validerAffectations ) {
                        VStack {
//                            Image(systemName: "checkmark.circle.fill")
                            Icones.ok.imageSystéme
                            Text("OK").font(.caption)
                            }
                      }
                    .buttonStyle(.borderedProminent) }
                
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: abandonerAffectations) {
                        VStack {
                            Icones.abandoner.imageSystéme
                            Text("Abandon...").font(.caption)
                            }
                      }
                    }
                } // toolbar
         } // NavigationVue
        .onAppear() {
            print("onAppear VueAffectationGroupe")
            var test = Set<Groupe>(groupesCollaboratifs)
            var _ = test.remove(groupe)
            }

        } // body

    
    
    
    
//MARK: - Retour d'information
    

    private func validerAffectations() {
        print("☑️ validerAffectations")
        reponseAmaMère(true, modeAffectation)
        }
 
    private func abandonerAffectations() {
        print("☑️ abandonerAffectations")
        reponseAmaMère(false, modeAffectation)
        }
    
}


