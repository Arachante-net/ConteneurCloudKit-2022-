//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData

struct ListeGroupe: View {
    
  @EnvironmentObject private var persistance : ControleurPersistance

  @Environment(\.managedObjectContext) private var viewContext
    
  @FetchRequest(
    fetchRequest: Groupe.extractionGroupes, //ListeGroupe.fetchRequest,
    animation: .default)
  private var groupes: FetchedResults<Groupe>

    
  @State var presenterCréationGroupe = false
  @State private var nouveauNom = ""
  @State var courant:String? = nil
  @State private var recherche = ""
  @State var groupesFiltrés = [Groupe]()
  @State static var rafraichir    = false


    private let formatHorodatage: DateFormatter = {
        let formateur = DateFormatter()
            formateur.dateStyle = .short
            formateur.timeStyle = .medium
            formateur.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
//          formatter.timeZone = TimeZone(     "UTC")
        return formateur
    }()
    


  var body: some View {

    NavigationView {
      List() {
          Text("\(ListeGroupe.rafraichir.description)") // .font(.system(size: 1)).hidden()

          ForEach(recherche == "" ? Array(groupes) : groupesFiltrés) { groupe in // , id: \.id
              NavigationLink(destination: VueDetailGroupe(groupe: groupe),
                             tag: groupe.nom ?? "",
                             selection: $courant) {
              HStack {
                Text("\(groupe.nom ?? "sans nom")").fontWeight(groupe.collaboratif ? .heavy : .thin )
                Spacer()
              }.badge( Text("\(groupe.valeur)").foregroundColor(.purple)    )
            }
        }
        .onDelete(perform: supprimerGroupes)
       

      }
      .listStyle(SidebarListStyle())
      .sheet(isPresented: $presenterCréationGroupe) {
          VueAjouterGroupe { (nom , collaboratif) in
              ajouterGroupe(nom: nom, collaboratif:collaboratif)
              
              presenterCréationGroupe = false
              courant = nom
              }
          }
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) {EditButton().help("Editer") }}
       
      .navigationBarTitle(Text("Événements"))
      //FIXME: remplacer par toolbar(content:) avec placement navigationBarLeading ou navigationBarTrailing .
      .navigationBarItems(
        leading:
            HStack {
//                Spacer()
//                Button(action: ajouterIndividuel)
//                { Label("Ajouter un Individuel", systemImage: "plus").help("YES")}
//                    .help("Créer un suivi individuel")
//                Button(action: ajouterCollaboratif)
//                    { Label("Ajouter un Groupe/Item Collaboratif", systemImage: "plus.square.dashed")}
//                    .help("Créer un suivi collaboratif")
                Button(action: { presenterCréationGroupe.toggle() }) {
                  Image(systemName: "plus")
                  }.help("YES")
                },
        trailing:
            HStack {
//                Spacer()
                Button(action: { let _ = Item.extractionItems })
                    { Image(systemName: "arrow.2.circlepath")}
            }
      )
    }.searchable(text: $recherche)
          .onChange(of: recherche) {valeurCherchée in groupesFiltrés = Array(groupes).filter {$0.nom?.contains(valeurCherchée) as! Bool }}
  }

        
        
        
        
    private func ajouterIndividuel() {
        let maintenant = Date()
        withAnimation {
            Groupe.creer(contexte:viewContext,
                         titre:"Indiv-" + formatHorodatage.string(from: maintenant) ,
                         collaboratif:false)
            }
        }
    
    
    private func ajouterCollaboratif() {
        let maintenant = Date()
        withAnimation {
            Groupe.creer(contexte:viewContext,
                         titre:"Collab-" + formatHorodatage.string(from: maintenant),
                         collaboratif:true)
            }
        }
    
    
    
  /// Supprimer les groupes passés en parametre,
  /// et enlever les references à ces groupes presentes dans lleurs .items
  private func supprimerGroupes(positions: IndexSet) {
    withAnimation {
        courant = nil
        
        // pour tout les groupes passés en parametre
        positions.forEach() {
            let groupe = groupes[$0]
            groupe.valide = false
//            print("🔘", $0 + 1, "° groupe de la liste :", groupe.nom ?? ", valeur :", groupe.valeur , " , composé de" , groupe.items?.count ?? 0, "items")
            // Que mes items m'oublient
            groupe.removeFromItems(groupe.items ?? [])
            }
        // Finalement, enlever les groups eux-mêmes
        persistance.supprimerObjets(positions.map { groupes[$0] })
        }
    }

    private func ajouterGroupe(nom: String, collaboratif:Bool) {
    withAnimation {
        Groupe.creer(contexte:viewContext, titre:nom, collaboratif:collaboratif)
    }
  }
    
    
}

