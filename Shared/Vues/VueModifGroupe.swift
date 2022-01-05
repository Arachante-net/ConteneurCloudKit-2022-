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

  

struct VueModifGroupe: View {
    
    // parametre d'appel de la Vue
//    @State var groupe:     Groupe
    @ObservedObject var groupe: Groupe
    @ObservedObject var principal: Item

    var achevée: (Bool) -> Void
//    @State var laValeur:Int = 0
//    @State var rafraichir : Int = 0
    @Environment(\.managedObjectContext) var contexte
    @EnvironmentObject private var persistance : ControleurPersistance
    
//    @State var collaboration = false
//    @State var valide = false
//    @State var nom           = ""
//    init(_ unGroupe: Groupe) {
//        self.groupe = unGroupe
//        self.principalItem = unGroupe.principal!
//        self.achevée = { (false) in }
////        if groupe.principal != nil {
////            self.principalItem = groupe.principal!
////            }
////        else {self.principalItem = nil}
//        }

    var body: some View {
    VStack {
//        Text("\(rafraichir)")
        TextField("Nouveau nom du groupe", text: $groupe.leNom)
            .submitLabel(.done)
            .textFieldStyle(.roundedBorder)
//            .clearButtonMode = .whileEditing
            .padding()
            .onSubmit { print("ENREGISTRER ET SAUVER LE CONTEXT") }
//      Text("nb items : \(items.count) | \(chronomètre.temps) - ")
//        Text("\(principal.valeur) \(groupe.valeurPrincipale)  \(laValeur)")
        
//        Stepper("Valeur locale : \(laValeur)", value: $laValeur)
//            .padding(.leading)
//        
//        Stepper("Valeur locale : \(principal.valeur)", value: $principal.valeur)
//            .padding(.leading)
//        
//        Stepper("Valeur locale : \(groupe.valeurPrincipale)", value: $groupe.valeurPrincipale)
//            .padding(.leading)
        
        VueValeurItemPrincipal(item: groupe.principal! )
        
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




