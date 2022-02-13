//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI

// Recuperer les informations minimales pour créer un nouveau Groupe
// son Nom et son eventuelle collaboration
struct VueAjouterGroupe: View {
  @State private var nom = ""
  @State private var collaboratif = false
    
  @FocusState private var focusSurLeChampNom: Bool //= false
    
  // Informer la Vue appelante
  let traitementTerminéDuGroupeSupplementaire: (String, Bool) -> Void
    
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Groupe")) {
            TextField("BOF",
                      text: $nom,
                      prompt: Text("Saisir le nom du groupe") )
                .focused($focusSurLeChampNom)
                .textFieldStyle(.roundedBorder)
                .border(focusSurLeChampNom ?  Color.accentColor : .secondary , width: 2)
                .onChange(of: nom, perform: {_ in })

            
            Toggle("Collaboratif", isOn: $collaboratif)
                .toggleStyle(.switch)
            }
          
        Button(action: traitementTerminé) {
            Text("Enregistrer le nouveau groupe").bold()
            }.buttonStyle(.borderedProminent)
        }
        
      .navigationTitle(Text("Création d'un nouveau groupe"))
    }
  }

//MARK: -
  private func traitementTerminé() {
    traitementTerminéDuGroupeSupplementaire(nom.isEmpty ? "Sans titre" : nom, collaboratif)
    }
    
}

