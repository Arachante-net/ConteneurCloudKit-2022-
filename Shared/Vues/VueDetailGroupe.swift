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

  
/// Affiche les propriétés du Groupe passé en argument
struct VueDetailGroupe: View {
    
    @Environment(\.managedObjectContext) private var contexte

    @EnvironmentObject private var persistance : ControleurPersistance
    @EnvironmentObject private var configUtilisateur : Utilisateur

    // Source de veritée, c'est cette Vue qui est proprietaire de groupe
    // Rq: avec @State l'etat n'est pas MàJ immediatement
    /// Argument, Le groupe en cours d'édition, propriétée de  la Vue  VuedetailGroupe
    @StateObject var groupe: Groupe

    // Etats 'locaux' de la Vue
    @State var collaboration = false
    @State var nom           = ""

    @State var feuilleModificationPresentée = false
    
    /// Le groupe édité fait partie des favoris de l'utilisateur
    @State private var estFavoris = false
    // configUtilisateur.estFavoris(groupe) //TODO: comment faire ça ?
    //TODO: essayer estFavoris? = nil

    @ViewBuilder
    var body: some View {
    let _ = assert(groupe.principal != nil, "❌ Groupe isolé")
    VStack(alignment: .leading, spacing: 2) {
        VStack(alignment: .leading, spacing: 2)  {
            Group {
                Etiquette( "Item principal", valeur: (groupe.principal != nil) ? groupe.principal!.titre ?? "␀" : "❌")
                Etiquette( "Valeur locale" , valeur: Int(groupe.principal?.valeur ?? 0))
                Etiquette( "Collaboratif"  , valeur: groupe.collaboratif)
                Etiquette( "Collaborateurs", valeur: Int(groupe.nombre))
                ForEach(Array(groupe.lesItems)) { item in
                    Etiquette("⚬ \(item.titre ?? "␀")" , valeur : Int(item.valeur))
                    }
                Etiquette( "Valeur globale", valeur: groupe.valeur)
                Etiquette( "Créateur"      , valeur: groupe.createur)
                Etiquette( "Identifiant"   , valeur: groupe.id?.uuidString)
                Etiquette( "Valide"        , valeur: groupe.valide)
    //            Etiquette( "Suppression"   , valeur: groupe.isDeleted)
                Etiquette( "En erreur"     , valeur: groupe.isFault)
                }
                .padding(.leading)
            }
                
            VueCarteGroupe(
                région:      groupe.régionEnglobante,
                annotations: groupe.lesAnnotations
                )
        
        
        }
        .isHidden(groupe.isDeleted || groupe.isFault ? true : false)
        .opacity(groupe.valide ? 1 : 0.1)
        .disabled(groupe.valide ? false : true)
        
        .onAppear() {
            let _ = groupe.verifierCohérence(depuis: #function)
            estFavoris = configUtilisateur.estFavoris(groupe)
            }

        .sheet(isPresented: $feuilleModificationPresentée) {
            VueModifGroupe(groupe) { quiterLaVue in
                            print("Retour de VueModifGroupe avec", quiterLaVue )
                            feuilleModificationPresentée = false
                            }
                .environment(\.managedObjectContext, persistance.conteneur.viewContext)
            }
            .transition(.opacity) //.move(edge: .top))
            
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing)
                { barreMenu }
            }
          .navigationBarTitle(Text(groupe.nom ?? ""))
    }
        
    
    
    var barreMenu: some View {
        HStack {
            Spacer()

            Button(action: {
                configUtilisateur.inverserFavoris(groupe, jeSuisFavoris: &estFavoris)
            }) {
                VStack {
                    Image(systemName: "heart.fill").foregroundColor(estFavoris ? .red : .secondary)
                    Text("Favoris").font(.caption)
                    }
              } .buttonStyle(.borderedProminent)
            
            
            
            Button(action: { feuilleModificationPresentée.toggle()  }) {
                VStack {
                    Image(systemName: "square.and.pencil")
                    Text("Modifier").font(.caption)
                    }
              }.buttonStyle(.borderedProminent)

            Button(role: .destructive, action: { print ("NON IMPLEMENTÉ") }) {
                //TODO: A implementer (cf. ListeItem)
                VStack {
                    Image(systemName: "trash")
                    Text("Supprimer").font(.caption)
                    }
            }.buttonStyle(.borderedProminent)
                .opacity(0.5)
                .saturation(0.5)

            Spacer()
            }
        }

    
    private func enrôlerUnNouvelItem() {
        withAnimation {
            let nouvelItem = Item.fournirNouveau(contexte : contexte , titre : "Nouvelle recrue de test")
            groupe.enrôler(contexte:contexte, recrues: [nouvelItem])
            }
        }
    
    
    func incrementer(max:Int) {
//        valeurLocale += 1
//        if valeurLocale >= max { valeurLocale = max }
//        groupe.principal?.valeur = Int64(valeurLocale)
//        persistance.sauverContexte("Item")
       }

    func decrementer(min:Int) {
//        valeurLocale -= 1
//        if valeurLocale < min { valeurLocale = min }
//        groupe.principal?.valeur = Int64(valeurLocale)
//        persistance.sauverContexte("Item")
       }
    
}




