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
  @State private var groupesEnCourDeSuppression: IndexSet? //SetIndex<Item>?



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
//          Text("\(ListeGroupe.rafraichir.description)") // .font(.system(size: 1)).hidden()

          ForEach(recherche == "" ? Array(groupes) : groupesFiltrés) { groupe in // , id: \.id
              NavigationLink(destination: VueDetailGroupe(groupe: groupe, item: groupe.principal ?? Item()),
                             tag: groupe.nom ?? "",
                             selection: $courant) {
              HStack {
                Text("\(groupe.nom ?? "sans nom")").fontWeight(groupe.collaboratif ? .heavy : .thin )
                Spacer()
              }.badge( Text("\(groupe.valeur)").foregroundColor(.purple)    )
            }
        }
        .onDelete(perform: proposerSuppressionGroupes) //supprimerGroupes)
       

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
          .onChange(of: recherche) {valeurCherchée in
              groupesFiltrés = Array(groupes).filter {$0.nom?.contains(valeurCherchée) as! Bool }
            }
      
          .alert(item: $groupesEnCourDeSuppression) { jeuIndices in
              assert(jeuIndices.count == 1, "IndexSet non unitaire") // seulement pendant le dev
      //        precondition(jeuIndices.count == 1, "IndexSet non unitaire") // Même une fois en prod
              
              let nom = (jeuIndices.map {groupes[$0].nom}.first ?? "")!

              var description:String=""
              
              //TODO: Si certitude d'avoir un jeu de taille 1, pas la peine de boucler
              jeuIndices.forEach {
                  let groupe = groupes[$0]
                  description = groupe.description
                  }

              return Alert(
                  title: Text("Suppression du groupe ") + Text("'\(nom)'").foregroundColor(.accentColor),
                  message: Text(description),
                  primaryButton: .default(
                                  Text("NON, je dois réfléchir un peu."),
                                  action: abandoner
                              ),
                  secondaryButton: .destructive(Text("OUI, j'ai même pas peur !"), action: {
                      supprimerVraimentGroupes(positions: jeuIndices)
                  })
                  )

          }

  }

        
        
        
    // Pas Glop
    private func ajouterIndividuel_() {
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
//                         titre:"Collab-" + formatHorodatage.string(from: maintenant),
                         titre:"" + formatHorodatage.string(from: maintenant),

                         collaboratif:true)
            }
        }
    
    
    
    private func proposerSuppressionGroupes(positions: IndexSet) {
        print("🔘 Proposition de suppression de :", positions.map { groupes[$0].nom ?? ""} )
        groupesEnCourDeSuppression = positions
        }
    

    private func supprimerVraimentGroupes(positions: IndexSet) {
        print("🔘 Suppression réeel de :", positions.map { groupes[$0].nom ?? ""} )
        positions.forEach {
            print("\t🔘 Suppression de :", groupes[$0].nom ?? "" )
//TODO: -    items[$0].removeFromGroupes(items[$0].groupes ?? []) -
            persistance.sauverContexte()
            }
                    
        withAnimation {
            persistance.supprimerObjets(positions.map { groupes[$0] })
            }
        }
    
    private func abandoner() {}
    
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

