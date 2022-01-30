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
    fetchRequest: Groupe.extractionGroupes,
    animation: .default)
  private var groupes: FetchedResults<Groupe>

  @State private var groupesEnCourDeSuppression: IndexSet? //SetIndex<Item>?

  @State private var presenterCréationGroupe = false
  @State private var nouveauNom              = ""
  @State private var courant:String?         = nil
  @State private var recherche               = ""
  @State private var groupesFiltrés          = [Groupe]()
    
//  @State  static var rafraichir              = false



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
          ForEach(recherche == "" ? Array(groupes) : groupesFiltrés) { groupe in
//            NavigationLink(destination: VueDetailGroupe(groupe: groupe, item: groupe.principal ?? Item()),
              NavigationLink(destination: VueDetailGroupe(groupe: groupe), //.equatable(),
                             tag: groupe.nom ?? "",
                             selection: $courant) {
              HStack {
                Text("\(groupe.nom ?? "sans nom")").fontWeight(groupe.collaboratif ? .heavy : .thin )
                Spacer()
              }.badge( Text("\(groupe.valeur)")    )
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
        
      .toolbar {
          ToolbarItem(placement: .navigationBarTrailing)
            {EditButton().help("Editer") }
          ToolbarItem(placement: .principal)
            {Image(systemName: "ellipsis.circle")}
          ToolbarItem(placement: .navigationBarTrailing)
            { HStack {
                Button(action: { presenterCréationGroupe.toggle() })
                    { Image(systemName: "plus") }
                }
            }
          ToolbarItem(placement: .navigationBarLeading)
            { HStack {
                Button(action: { let _ = Item.extractionItems })
                    { Image(systemName: "arrow.2.circlepath")}
                }
            }
      }

      .navigationTitle(
        Text("Événements")
//        + Text(Image(systemName: "sparkles"))
//        + Text(".")
        )

        
        
    }.searchable(text: $recherche)
          .onChange(of: recherche) {valeurCherchée in
              groupesFiltrés = Array(groupes).filter {($0.nom?.contains(valeurCherchée))! as Bool } // Forced cast of 'Bool' to same type has no effect, N'EST PAS UNE ERREUR
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
                  //TODO: verifier si collaboration à d'autre groupes et du coup si la suppression est possible
                  // ??? groupe.collaborateursSansLePrincipal ???
                  groupe.collaborateurs.forEach
                    { print("Prévenir", $0.leNom, "de la suppression de", groupe.leNom) }
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

