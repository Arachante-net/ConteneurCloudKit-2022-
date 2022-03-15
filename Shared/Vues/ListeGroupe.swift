//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData
import os.log

struct ListeGroupe: View {
    
  let  l = Logger.interfaceUtilisateur

  @EnvironmentObject private var persistance : ControleurPersistance

  @Environment(\.managedObjectContext) private var viewContext
    
  @FetchRequest(
    fetchRequest: Groupe.extractionGroupes,
    animation: .default)
  private var groupes: FetchedResults<Groupe>
    { didSet { l.debug("SET ###### groupes \(groupes.count)") } }

  @State private var groupesEnCourDeSuppression: IndexSet? //SetIndex<Item>?
    { didSet { l.debug("SET ###### groupesEnCourDeSuppression \(groupesEnCourDeSuppression.debugDescription)              ") } }
  @State private var presenterCréationGroupe = false { didSet { l.debug("SET ###### presenterCréationGroupe \(presenterCréationGroupe) ") } }
  @State private var nouveauNom              = ""    { didSet { l.debug("SET ###### nouveauNom \(nouveauNom)              ") } }
  @State private var courant:String?         = nil   { didSet { l.debug("SET ###### courant \(courant ?? "")              ") } }
  @State private var recherche               = ""    { didSet { l.debug("SET ###### recherche \(recherche)                ") } }
  @State private var groupesFiltrés          = [Groupe]() { didSet { l.debug("SET ###### groupesFiltrés \(groupesFiltrés) ") } }
    
//  @State  static var rafraichir              = false



    
    init () {l.info("init ListeGroupe")}

    var maCouleur = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)   //  #colorLiteral()

  var body: some View {
    let _ = l.info("ListeGroupe BODY")
      
    NavigationView {
      List() {
          let _ = l.info("ListeGroupe LIST ######")
//          ForEach(recherche == "" ? Array(groupes) : groupesFiltrés) { groupe in
          ForEach(groupes) { groupe in
              let _ = l.info("ListeGroupe ForEach ###### \(groupe.leNom)")
//            NavigationLink(destination: VueDetailGroupe(groupe: groupe, item: groupe.principal ?? Item()),
              NavigationLink(destination: VueDetailGroupe(groupe), //.equatable(),
                             tag: groupe.leNom,
                             selection: $courant) {
              HStack {
                  Text("\(groupe.leNom)").fontWeight(groupe.collaboratif ? .heavy : .thin )
                  Text("\(groupe.lePrincipal.leMessage)")
                Spacer()
              }//.aspectRatio(16/9, contentMode: .fit)
//              .background(RoundedRectangle(cornerRadius: 3).fill(.red))
//              .aspectRatio(16/9, contentMode: .fit)
                      .badge( Text("\(groupe.valeur)")    )
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
//              Button(action: { let _ = Item.extractionItems })
                Button(action: { rafraichir() })
                    { Image(systemName: "arrow.2.circlepath") }
                }
            }
      }
// 15 mars
//      .navigationTitle(
//        Text("Événements")
//        )

        Bienvenue()

        
        
    }.searchable(text: $recherche)
          .onChange(of: recherche) {valeurCherchée in
              groupesFiltrés = Array(groupes).filter {($0.nom?.contains(valeurCherchée))! as Bool } // Forced cast of 'Bool' to same type has no effect, N'EST PAS UNE ERREUR
            }
      
          .onAppear(perform: rafraichir)
      
          .alert(item: $groupesEnCourDeSuppression) { jeuIndices in
              let (nom, description) = preparerSuppression(jeuIndices: jeuIndices)
//              assert(jeuIndices.count == 1, "IndexSet non unitaire") // seulement pendant le dev
//      //        precondition(jeuIndices.count == 1, "IndexSet non unitaire") // Même une fois en prod
//
//              let nom = (jeuIndices.map {groupes[$0].nom}.first ?? "")!
//
//              var description:String=""
//
//              //TODO : Si certitude d'avoir un jeu de taille 1, pas la peine de boucler
//              jeuIndices.forEach {
//                  let groupe = groupes[$0]
//                  description = groupe.description
//                  //TODO : verifier si collaboration à d'autre groupes et du coup si la suppression est possible
//                  // ??? groupe.collaborateursSansLePrincipal ???
//                  groupe.collaborateurs.forEach
//                    { print("Prévenir", $0.leNom, "de la suppression de", groupe.leNom) }
//                  }
              
              return Alert(
                  title: Text("Suppression du groupe ") + Text("'\(nom)'").foregroundColor(.accentColor),
                  message: Text(description),
                  primaryButton: .default(
                                  Text("NON, je dois réfléchir un peu."),
                                  action: abandoner
                              ),
                  secondaryButton: .destructive(Text("OUI, j'ai même pas peur !"), action: {
                      supprimerVraimentGroupes(positions: jeuIndices, mode: .simulation)
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
    
    
    private func preparerSuppression (jeuIndices:IndexSet) -> (nom:String, description:String) {
        assert(jeuIndices.count == 1, "IndexSet non unitaire") // seulement pendant le dev
//        precondition(jeuIndices.count == 1, "IndexSet non unitaire") // Même une fois en prod
        
        let nom = (jeuIndices.map {groupes[$0].nom}.first ?? "")!

        var description:String = ""
        
        //RQ: Si certitude d'avoir un jeu de taille 1, pas la peine de boucler
        jeuIndices.forEach {
            let groupe = groupes[$0]
            description = groupe.description
            //TODO: verifier si collaboration à d'autre groupes et du coup si la suppression est possible
            // ??? groupe.collaborateursSansLePrincipal ???
            groupe.collaborateurs.forEach
              { l.info("Prévenir \($0.leNom) de la suppression de \(groupe.leNom)") }
            }
        return (nom: nom, description: description)
    }
    
    private func proposerSuppressionGroupes(positions: IndexSet) {
        l.info("🔘 Proposition de suppression de : \( positions.map { groupes[$0].leNom } )" )
        groupesEnCourDeSuppression = positions
        }
    

    private func supprimerVraimentGroupes(positions: IndexSet, mode: Suppression = .simulation) {
        let lesGroupes = positions.map { groupes[$0] }
        let lesNoms    = lesGroupes.map {$0.leNom}
        l.info("🔘 Suppression confirmée (  \(mode.hashValue) de : \(lesNoms) ")
        Groupe.supprimerAdhérences(groupes: lesGroupes, mode:mode)
        withAnimation {
            l.info("\t🔘 Suppression (\(mode.hashValue) ) du(des) groupe(s) : \(lesNoms)") //groupes[$0].leNom )
            persistance.supprimerObjets(lesGroupes, mode: mode) //positions.map { groupes[$0] })
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
    
    func rafraichir() {
        l.info("Rafraichir la vue liste groupe")
        groupes.forEach {
            l.info("\tRafraichir le groupe \($0.leNom)")
            $0.lesItems.forEach {
                l.info("\t\tRafraichir l'item \($0.leTitre)")
                $0.integration.toggle()
            }
            $0.integration.toggle()
        }
//        persistance.sauverContexte()
    }
    
    
}

