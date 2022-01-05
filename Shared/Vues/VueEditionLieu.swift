//Arachante
// michel  le 26/12/2021
// pour le projet  PositionUtilisateur
// Swift  5.0  sur macOS  12.1
//
//  2021 27 Décembre
//

import SwiftUI

/// Editer (modifier) les informations décrivant un lieu géographique
/// - Parameters:
///   - lieu: le Lieu à éditer
///   - informationARetourner: Une Closure fournissant les informations retournée par la Vue
/// - VueEditionLieu( place ) { newLocation in ...  }
struct VueEditionLieu: View {
    var lieu: Lieu

    @State private var nom: String
    @State private var description: String
    
    var informationARetourner: (Lieu) -> Void

    
    /// Initialisation de la Vue
    ///  - _nom et _description representent les wrappers de propriétés eponymes eux-memes
    init(_ lieuAEditer: Lieu, onSave: @escaping (Lieu) -> Void) {
        self.lieu = lieuAEditer
        self.informationARetourner = onSave

        _nom         = State(initialValue: lieuAEditer.libellé)
        _description = State(initialValue: lieuAEditer.description)
        }
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle

    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nom du lieu", text: $nom)
                    TextField("Déscription", text: $description)
                }
            }
            .navigationTitle("Details du lieu")
            .toolbar {
                Button("Sauver") {
                    var leuEdité = lieu
                        leuEdité.id = UUID()
                        leuEdité.libellé = nom
                        leuEdité.description = description
                    print("🚩🚩🚩 Nom du lieu", leuEdité.libellé, leuEdité.description)
                    informationARetourner(leuEdité)
                    cloreLaVueActuelle()
                }
            }
        }.navigationViewStyle(.stack)
    }
}



