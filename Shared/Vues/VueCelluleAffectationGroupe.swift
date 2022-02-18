//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI

/// Visualise pour le groupe en cours d'édition :
///
/// - un des groupe partie prenante (collaborateur ou responasable)
/// - S'il est déjà en collaboration avec le groupe en cours
///
/// - returns  :
/// - Le nouvel ensemble des groupes  affectés ($selectionDeGroupes)
struct VueCelluleAffectationGroupe: View {
    
  // Les arguments de la vue
  /// Le groupe  parent, pour lequel on définit les affectations
  var groupeEnCoursEdition: Groupe
    
  ///  Le groupe en cours de réaffectation eventuelle
  var groupeAAffecter: Groupe
    
    
  /// La liste des groupes selectionés (collaborateurs ou  leaders)
  @Binding var selectionDeGroupes: Set<Groupe>
    
    
  ///  Vrai si le groupe en cours d'edition est actuellement sélectioné
  var estSelectioné: Bool { selectionDeGroupes.contains(groupeAAffecter) }
    
    
    init (_ leGroupe:Groupe,
          groupeCiblePotentielle:Groupe,
          affectations:Binding<Set<Groupe>>) {
        
                groupeEnCoursEdition = leGroupe
                groupeAAffecter      = groupeCiblePotentielle
                _selectionDeGroupes  = Binding(projectedValue: affectations)
        }
    
  var body: some View {
    HStack {
        Text("\(groupeAAffecter.leNom)")
            .foregroundColor(estSelectioné ? .primary : .secondary)

      Spacer()
        Image(systemName: "checkmark")
            .foregroundColor(estSelectioné ? .accentColor : .secondary)
            .isHidden(!estSelectioné)
    }
    .onTapGesture { alternerSelection() }

  }
    
   

    
//MARK: -
func alternerSelection() {
    if estSelectioné { selectionDeGroupes.remove(groupeAAffecter) }
              else   { selectionDeGroupes.insert(groupeAAffecter) }
    }
 
    
    
}


