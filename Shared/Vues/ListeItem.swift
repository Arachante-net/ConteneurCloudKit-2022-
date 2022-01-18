//Arachante
// michel  le 15/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//


import SwiftUI
import CoreData


extension IndexSet: Identifiable {
    public var id: Self { self } //RawValue { rawValue }
}


struct ListeItem: View {
    
//    static var demandeDeRecuperation: NSFetchRequest<Item> {
//        let requete: NSFetchRequest<Item> = Item.fetchRequest()
//        requete.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
//        return requete
//        }

    
    @FetchRequest(sortDescriptors: []) var reqêteMinimalePédagogique: FetchedResults<Item>

    @FetchRequest(
      fetchRequest: Item.extractionItems, //ListeItem.demandeDeRecuperation,
      animation: .default)
    var items: FetchedResults<Item>

    @FetchRequest(fetchRequest: Item.extractionValides)
    var valides: FetchedResults<Item>

    @FetchRequest(
        fetchRequest: Item.extractionOrphelins,
        animation: .default)
    var orphelins: FetchedResults<Item>
    
  @EnvironmentObject private var persistance: ControleurPersistance //PersistenceController

  @Environment(\.managedObjectContext) private var viewContext
    
//  @Binding var viewModel:VuePrincipale.ViewModel // = VuePrincipale.ViewModel()
  @StateObject private var Ξ = ViewModel() //    viewModel = ViewModel()
//  @State private var alerteAffichée = false
//  @State private var itemEnCours: Item?
//  @State private var itemsEnCourDeSuppression: IndexSet? //SetIndex<Item>?
   
  @Binding var appError: ErrorType? // = nil


    
  var body: some View {
      
//      let itemDeTest = items.first!
//Item.bidon() //items.first!

    NavigationView {
        
        List {
        ForEach(items) { item in
            NavigationLink( destination: VueDetailItem (
                item: item ,
                région: item.région
                ))
            { Text(item.leTitre) }
            
            .badge(Int(item.valeur))
        }
        .onDelete(perform: proposerSuppressionItems) //supprimerItems)
            
      }
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) {EditButton().help("SOS") }}
      .navigationBarTitle(Text("Items"))
      .navigationBarItems(
        leading:
            barreMenuNavigation,
        trailing:
            Button(action: { let _ = Item.extractionItems })
                { Image(systemName: "arrow.2.circlepath")}
                .opacity(0.7)
        )
        
    }
      
    .alert(item: $Ξ.itemsEnCourDeSuppression) { indicesDesItemsASupprimer in
        alerteSuppression(jeuIndices: indicesDesItemsASupprimer)
        }
      
  }
    
    
    
    var barreMenuNavigation: some View {
        HStack {
            Spacer()
            Button(action: ajouterGroupeItem){ Label("Ajouter un Groupe/Item", systemImage: "plus.circle.fill"   )
                .hoverEffect()
                .scaleEffect(1.5)
//                    .symbolRenderingMode(.hierarchical)
                .symbolRenderingMode(.multicolor)
                .saturation(1)

            }
            Spacer()
            Spacer()
            Button(role: .destructive, action: ajouterItem)
                { Label("Ajouter un Item", systemImage: "plus")}
                .foregroundColor(.red).opacity(0.5)
//              Button(action: RallierGroupe)    { Label("Rallier un groupe",      systemImage: "plus.square.on.square")}
            Button(action: GenererErreur)    { Label("générer une erreur",     systemImage: "ladybug.fill")}.opacity(0.7)
            }
        }

    
    /// Fournit une Alerte qui affiche une brève desciption de l''Item à supprimer
    /// et demande la confirmation de sa suppression
    /// - Parameter jeuIndices: le(s) rang(s) des éléments a supprimer, dans le FetchedResults du .onDelete utilisé
    /// - Returns: une Alerte
    func alerteSuppression(jeuIndices:IndexSet) ->  Alert {
        assert(jeuIndices.count == 1, "IndexSet non unitaire") // seulement pendant le dev
        
        let titre = (jeuIndices.map {items[$0].titre}.first ?? "")!

        var description:String=""
        
        //TODO: Si certitude d'avoir un jeu de taille 1, pas vraiment la peine de parcourir le jeu
        jeuIndices.forEach {
            let item = items[$0]
            description = item.description
            }

        return Alert(
            title: Text("Suppression de l'item ") + Text("'\(titre)'").foregroundColor(.accentColor),
            message: Text(description),
            primaryButton: .default(
                            Text("NON, je dois réfléchir un peu."),
                            action: abandoner
                        ),
            secondaryButton: .destructive(Text("OUI, j'ai même pas peur !"), action: {
                supprimerVraimentItems(positions: jeuIndices)
            })
            )
    }
    
    

    
    
    
    
    private func abandoner() {}
//    private func accepter(positions: IndexSet) {}

  
    private func ajouterItem() {
        withAnimation {
          Item.creer(contexte:viewContext)
          }
        }
    
    private func ajouterGroupeItem() {
        withAnimation {
            Groupe.creer(contexte:viewContext, titre:"Collab", collaboratif:true)
            }
        }

    
//    private func RallierGroupe() {
//        withAnimation {
////            Groupe.rallier(<#T##self: Groupe##Groupe#>)(contexte:viewContext)
//            }
//        }

    
    private func proposerSuppressionItems(positions: IndexSet) {
        print("🔘 Proposition de suppression de :", positions.map { items[$0].titre ?? ""} )
        Ξ.itemsEnCourDeSuppression = positions
        }
    

    private func supprimerVraimentItems(positions: IndexSet) {
        print("🔘 Suppression réeel de :", positions.map { items[$0].titre ?? ""} )
        positions.forEach {
//            let item = items[$0]
            print("\t🔘 Suppression de :", items[$0].titre ?? "" )
            items[$0].removeFromGroupes(items[$0].groupes ?? [])
            persistance.sauverContexte()
            }
                    
        withAnimation {
            persistance.supprimerObjets(positions.map { items[$0] })
            }
        }

    // Pas utilisé
//    private func supprimerItems_(positions: IndexSet) {
//    //TODO: on pourrait utiliser  item.prepareForDeletion()
//        print("🔘 Suppression de :", positions.map { items[$0].titre ?? ""} )
//        viewModel.alerteAffichée = true
//        positions.forEach {
//            let item = items[$0]
//            print("\t🔘 Suppression de :", item.titre ?? "" )
//            viewModel.itemEnCours = item
//            viewModel.alerteAffichée = true
//            print("🔘", $0 + 1, "° item du menu :", item.titre ?? ", valeur :", item.valeur , " , membre de" , item.groupes?.count ?? 0, "groupes")
//            print("🔘\t:" , item.groupes?.map { ($0 as! Groupe).nom ?? ""} ?? "" )
//
//            item.removeFromGroupes(item.groupes ?? [])
////            item.delete()
//            persistance.sauverContexte()
//            }
//
//        withAnimation {
//            persistance.supprimerObjets(positions.map { items[$0] })
//            }
//        }

    
    
    private func GenererErreur() {
        appError = ErrorType(error: .trucQuiVaPas(num: 666))
        }

}
