//Arachante
// michel  le 16/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import UIKit
import CoreData
import os.log

/** Affiche la liste des groupes
 
 > Note:  Ici quelques tests de faux commentaires en `.md`

 Voir  ``Groupe`` et ``Item``
# Titre
## Sous-titre
 1. UN
 
 Il est ici representé par deux structures : ``Groupe`` et ``Item``

 - term Ice: Ice sloths thrive below freezing temperatures.

 - ``Groupe``
 - ``Item``
 
 destination views:

 /    NavigationView {
 /         List(model.notes) { note in
 /            NavigationLink(note.title, destination: NoteEditor(id: note.id))
 /        }
          Text("Select a Note")
 /    }
 
 /S
 
 ```swift
 struct Sightseeing: Activity {
     func perform(with sloth: inout Sloth) -> Speed {
         sloth.energyLevel -= 10
         return .slow
     }
 }
 }
 ```
 */
struct ListeGroupe: View {
    
  let  l = Logger.interfaceUtilisateur

  @EnvironmentObject private var persistance : ControleurPersistance

  @Environment(\.managedObjectContext) private var viewContext
    
  @FetchRequest(
    fetchRequest: Groupe.extractionGroupes,
    animation: .default)
   var groupes: FetchedResults<Groupe>
    { didSet { l.debug("SET ###### groupes \(groupes.count)") } }
    
    @FetchRequest(
      fetchRequest: Item.extractionItems, //ListeItem.demandeDeRecuperation,
      animation: .default)
    var items: FetchedResults<Item>
    
//    @ObservedResults(Item.self) var items: FetchedResults<Item>

  @State private var groupesEnCourDeSuppression: IndexSet? //SetIndex<Item>?
    { didSet { l.debug("SET ###### groupesEnCourDeSuppression \(groupesEnCourDeSuppression.debugDescription)              ") } }
  @State private var presenterCréationGroupe = false { didSet { l.debug("SET ###### presenterCréationGroupe \(presenterCréationGroupe) ") } }
  @State private var nouveauNom              = ""    { didSet { l.debug("SET ###### nouveauNom \(nouveauNom)              ") } }
  @State private var courant:String?         = nil   { didSet { l.debug("SET ###### courant \(courant ?? "")              ") } }
  @State private var recherche               = ""    { didSet { l.debug("SET ###### recherche \(recherche)                ") } }
  @State private var groupesFiltrés          = [Groupe]() { didSet { l.debug("SET ###### groupesFiltrés \(groupesFiltrés) ") } }
  
  @State private var groupeSelectioné: Groupe?

//  @State  static var rafraichir              = false


  

    
    init () {
        l.info("init ListeGroupe")
//        UITableViewCell.appearance().selectionStyle = .none
//        UITableViewCell.appearance().selectedBackgroundView = UIView()
//        UITableViewCell.appearance().selectedBackgroundView = {
//                      let view = UIView()
//                      view.backgroundColor = .blue
//                      return view
//                  }()

    }

    var maCouleur = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)   //  #colorLiteral()

  var body: some View {
    let _ = l.info("ListeGroupe BODY")
      GeometryReader { g in
    NavigationView {
      List() {
          let _ = l.info("ListeGroupe LIST ######")
//          ForEach(recherche == "" ? Array(groupes) : groupesFiltrés) { groupe in
          ForEach(groupes) { groupe in
              let _ = l.info("ListeGroupe ForEach ###### \(groupe.leNom) \(groupe.message) ")
              let _ = groupe.identifiant()
//              let t = groupe.nom.userInfo["test"]
              
              let tg = groupe as NSManagedObject
////              let _ = dump(tg, name:"key")
              let e = NSManagedObject.entity()
              let i = e.attributesByName
              let _ = print("attributesByName", i.count, i.keys)
//              let ttg = tg.primitiveValue(forKey: ".")
//              let _ = print("key", ttg ?? "bof")

//            NavigationLink(destination: VueDetailGroupe(groupe: groupe, item: groupe.principal ?? Item()),
              ZStack {
                  Cellule(groupe, config: [.entête,.description, .informations, .indicateurs]) //, .description, .indicateurs]) //, .description, .informations, .indicateurs])
//                  CelluleGabarit(config: [.entête,.description, .indicateurs]).frame( height: 200)
//              HStack(spacing: 0)  {
//                  Cellule(groupe: groupe, config: [.entête]) //, .description, .indicateurs]) //, .description, .informations, .indicateurs])

                  NavigationLink(destination: VueDetailGroupe(groupe), //.equatable(),
                             tag: groupe.leNom,
                             selection: $courant) {
                  EmptyView()
                      let _ = print("⚙️", groupe.leNom)

                      }
                  
//                             .frame(height: 100)
//                                   .opacity(0)
//                  Cellule(groupe: groupe, config: [.entête]) //, .description, .indicateurs]) //, .description, .informations, .indicateurs])
//                      .frame(width: 255, height: 150)
//                      .aspectRatio(16/9, contentMode: .fill)
//                      .padding()
//              HStack {
//                  Text("\(groupe.leNom)").fontWeight(groupe.collaboratif ? .heavy : .thin )
//                  Text("\(groupe.lePrincipal.leMessage)")
//                Spacer()
//              }//.aspectRatio(16/9, contentMode: .fit)
//              .background(RoundedRectangle(cornerRadius: 3).fill(.red))
//              .aspectRatio(16/9, contentMode: .fit)
                  
                      //.badge( Text("\(groupe.valeur)")    )
//            }
              }//.background(ignoresSafeAreaEdges : .all)
//              .onTapGesture { groupeSelectioné = groupe }
//                  .listRowBackground(courant == groupe.leNom ? Color.yellow : Color(UIColor.systemGroupedBackground))
              .opacity(courant == groupe.leNom ? 1.0 : 0.75)
              .padding(.vertical, 5)
              .shadow(color: courant == groupe.leNom ? Color.primary : Color(UIColor.systemGroupedBackground), radius: 2)
//              .swipeActions(edge: .leading,  allowsFullSwipe: true) {Button {} label: {Label("\(groupe.leNom) \(courant ?? "...")", systemImage: "0.circle")}.tint(.indigo).saturation(0.5).opacity(0.4)}//.padding()
//              .swipeActions(edge: .trailing, allowsFullSwipe: true) {Button(role:.destructive) {print(" SUPPRIMER \(groupe.leNom)")} label: {Label("Supprimer \(groupe.leNom)", systemImage: "trash")}}//.padding()


        }
//        .onDelete(perform: proposerSuppressionGroupes) //supprimerGroupes)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Text("oui")
            Button {} label: {Label("!", systemImage: "1.circle")}.tint(.indigo).saturation(0.5).opacity(0.4).clipped().cornerRadius(20).border(.yellow, width:5).padding()
            Spacer()
            Button {} label: {Label("!", systemImage: "3.circle")}.tint(.pink).saturation(0.5).opacity(0.4).clipped().border(.yellow).padding()
            Text("Non")
            }
//        .swipeActions(edge: .leading, allowsFullSwipe: true) {Button {} label: {Label("?", systemImage: "2.circle")}.tint(.indigo).saturation(0.7).opacity(0.5).padding()}//.padding()
//        .swipeActions(edge: .trailing, allowsFullSwipe: true) {Button(role:.destructive) {} label: {Label("Supprimer", systemImage: "trash")}}

      }
//      .environment(\.defaultMinListRowHeight, 10)
      .listStyle(SidebarListStyle())
      .refreshable {
          // MàJ de la liste
          rafraichir()
      }

        
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

        
        
    }
//        .navigationViewStyle(.stack)
        .searchable(text: $recherche)
          .onChange(of: recherche) {valeurCherchée in
              groupesFiltrés = Array(groupes).filter {($0.nom?.contains(valeurCherchée))! as Bool } // Forced cast of 'Bool' to same type has no effect, N'EST PAS UNE ERREUR
            }
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
//                $0.integration.toggle()
                $0.objectWillChange.send()
            }
//            $0.integration.toggle()
            $0.objectWillChange.send()

        }
//        persistance.sauverContexte()
    }
    
    
}

