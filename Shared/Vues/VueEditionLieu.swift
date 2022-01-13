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

//    @State private var nom: String
//    @State private var description: String
    
    @StateObject private var Ξ:ViewModel // = ViewModel(item)
    
    // pour récuperer des infos en retour de Vue
    var informationARetourner: (Lieu) -> Void

    
    /// Initialisation de la Vue
    ///  - _nom et _description representent les wrappers de propriétés eponymes eux-memes
    init(_ lieuAEditer: Lieu, onSave: @escaping (Lieu) -> Void) {
        self.lieu = lieuAEditer
        self.informationARetourner = onSave
        _Ξ = StateObject(wrappedValue: ViewModel(lieuAEditer))

//        _nom         = State(initialValue: lieuAEditer.libellé)
//        _description = State(initialValue: lieuAEditer.description)
        }
    
    // Rejet de la présentation actuelle
    @Environment(\.dismiss) var cloreLaVueActuelle

    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nom du lieu", text: $Ξ.nom)
                    TextField("Déscription", text: $Ξ.description)
                }
            }
            .navigationTitle("Details du lieu")
            .toolbar {
                Button("Sauver") {
                    var lieuEdité = lieu
                        lieuEdité.id = UUID()
                        lieuEdité.libellé = Ξ.nom
                        lieuEdité.description = Ξ.description
                    informationARetourner(lieuEdité)
                    cloreLaVueActuelle()
                }
            }
        }.navigationViewStyle(.stack)
    }
}



