//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import MapKit
import CoreData

  
/// Edition et modification des caracteristique du groupe passé en parametre
struct VueModifGroupe: View {
    
    // parametre d'appel de la Vue
    @ObservedObject var groupe: Groupe
    // closure en parametre, a executer lorsque l'utilisateur quitte cette vue
    var achevée: (Bool) -> Void

    @Environment(\.managedObjectContext) var contexte
    @EnvironmentObject private var persistance : ControleurPersistance
    
    init(_ unGroupe: Groupe, achevée: @escaping  (Bool) -> Void) {
        self.groupe = unGroupe
//        self.principalItem = unGroupe.principal!
        self.achevée = achevée
////        if groupe.principal != nil {
////            self.principalItem = groupe.principal!
////            }
////        else {self.principalItem = nil}
        }

    var body: some View {
    VStack {
        TextField("Nouveau nom du groupe", text: $groupe.leNom)
            .submitLabel(.done)
            .textFieldStyle(.roundedBorder)
//            .clearButtonMode = .whileEditing
            .padding()
            .onSubmit { print("ENREGISTRER ET SAUVER LE CONTEXT") }
        
        VueValeurItemPrincipal(item: groupe.lePrincipal , groupe: groupe )
        
        Toggle("Collaboratif", isOn: $groupe.collaboratif)///   collaboration)
        Toggle("Valide",       isOn: $groupe.valide)

        if groupe.collaboratif {
            Button(action: enrôlerUnNouvelItem)    { Label("Enrôler",      systemImage: "plus.square.on.square")}
            }
          else { Text("Individuel") }
          
        Button(" VALIDER ") { validerFormulaire() }
            .buttonStyle(.borderedProminent)
        
        }.onAppear(perform: {
            // recuperer les champs modifiables Groupe CoreData
//            collaboration = groupe.collaboratif
//            valide        = groupe.valide
//            nom           = groupe.nom ?? "anonyme"
            // d'autres champs ?
//            laValeur = groupe.valeurPrincipale
            })
                    
        
    }
        
    
    
    
    
//MARK: --
    
    private func validerFormulaire() {
        
//        if !nom.isEmpty {groupe.nom  = nom}
//        groupe.collaboratif = collaboration
//        groupe.valide = valide
//        groupe.principal?.valeur = Int64(laValeur)
        //TODO: Enregistrer les autres changements
        persistance.sauverContexte("Groupe Item")
//        rafraichir += 1
        print(" ☑️VALEUR A SAUVER", groupe.valeurPrincipale, groupe.principal?.valeur ?? 0)
        achevée(true)
        }
    
    
    private func enrôlerUnNouvelItem() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : contexte , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:contexte, recrues: [nouvelItem])
            }
        }
    
    private func enrôlerDesItems() {
        withAnimation {
            let nouveaux: Set<Item> = []
            groupe.enrôler(contexte:contexte, recrues: nouveaux)
            }
        }
    
}




