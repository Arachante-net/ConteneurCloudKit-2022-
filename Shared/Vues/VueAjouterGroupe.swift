//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI

struct VueAjouterGroupe: View {
  @State var nom = ""
  @State var collaboratif = false
  @FocusState private var focusSurLeChampNom: Bool //= false


  let achevé: (String, Bool) -> Void
    
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Groupe")) {
            TextField("BOF",
                      text: $nom,
                      prompt: Text("Saisissez le nom du groupe") )
                .focused($focusSurLeChampNom)
                .textFieldStyle(.roundedBorder)
                .border(focusSurLeChampNom ?  Color.accentColor : .secondary , width: 2)
                .onChange(of: nom, perform: {newValue in })

            
            Toggle("Collaboratif", isOn: $collaboratif)
                .toggleStyle(.switch)
            }
          
        Button(action: formAction) {
            Text("Enregistrer le nouveau groupe").bold()
            }.buttonStyle(.borderedProminent)
        }
        
      .navigationBarTitle(Text("Création d'un nouveau groupe"))
    }
  }

  private func formAction() {
    achevé(nom.isEmpty ? "Sans titre" : nom, collaboratif)
    }
}

