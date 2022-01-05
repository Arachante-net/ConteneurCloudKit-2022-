//Arachante
// michel  le 18/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI

struct VueCelluleItemGroupe: View {
  var groupe: Groupe
  @Binding var selection: Set<Groupe>
  var estSelectioné: Bool { selection.contains(groupe) }

  var body: some View {
    HStack {
      groupe.nom.map(Text.init)
      Spacer()
      if estSelectioné { Image(systemName: "checkmark") }
      }
    .onTapGesture {
      if estSelectioné { selection.remove(groupe) }
                else   { selection.insert(groupe) }
     }
  }
}


