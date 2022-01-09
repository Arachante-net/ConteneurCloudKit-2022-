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
    
  @State private var alerteAffichée = false
  @State private var itemEnCours: Item?
  @State private var itemsSupprimables: IndexSet? //SetIndex<Item>?
  @Binding var appError: ErrorType? // = nil


  var body: some View {
    NavigationView {
        
        List {
        ForEach(items) { item in // , id: \.timestamp
            let _ = print("👁 ", item.titre ?? "-")
            NavigationLink(destination: VueDetailItem(item: item )) {
                Text("")
                + Text(item.titre ?? "-")
                }
            .badge(Int(item.valeur))
        }
        .onDelete(perform: proposerSuppressionItems) //supprimerItems)
      }
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) {EditButton().help("SOS") }}
      .navigationBarTitle(Text("Items"))
      .navigationBarItems(
        leading:
            HStack {
                Button(action: ajouterItem)      { Label("Ajouter un Item",        systemImage: "plus"                 )} .help("OUI")
                Button(action: ajouterGroupeItem){ Label("Ajouter un Groupe/Item", systemImage: "plus.square.dashed"   )}
                Button(action: RallierGroupe)    { Label("Rallier un groupe",      systemImage: "plus.square.on.square")}
                Button(action: GenererErreur)    { Label("générer une erreur",     systemImage: "ladybug.fill")}

                },
        trailing: Button(action: { let _ = Item.extractionItems }) { Image(systemName: "arrow.2.circlepath")}
       )
        
        
        
    }
      
    .alert(item: $itemsSupprimables) { truc in
        let titres = truc.map {items[$0].titre}
        let t = (titres.first ?? "")!
        var description = Text("Truc \(t)")
        var description_ = ""
        
        truc.forEach {
            let item = items[$0]
//            description_ = description_ + "\(item.titre ?? " ") "
            description_ = description_ + "\($0 + 1)° de la liste, valeur : \(item.valeur), membre de \(item.groupes?.count ?? 0) groupes"
            item.groupes?.forEach {
                description_ = description_ + " \( ($0 as! Groupe).nom ?? "")   "
                }
            }

        return Alert(
            title: Text("Suppression de l'item ") + Text("'\(t)'").foregroundColor(.accentColor),
            message: Text(description_),
//            dismissButton: .cancel())
            primaryButton: .default(
                            Text("NON, je dois réfléchir un peu."),
                            action: abandoner
                        ),
            secondaryButton: .destructive(Text("OUI, j'ai même pas peur !"), action: {
                print("🔘 YO \(truc)")
                print("🔘 Suppression de :", items[truc.first ?? 0].titre)
                supprimerVraimentItems(positions: truc)
                //itemsSupprimables.map { items[$0].titre ?? ""} )
            })
            ) //accepter(positions: i) )

    }

//    .alert(isPresented: $alerteAffichée) {
//        let i:IndexSet = []
//        Alert(
//            title: Text("\(itemEnCours?.titre ?? "") ATTENTION !").foregroundColor(.red),
//            message: Text("Supprimer les contibutions de cet item ")
//            + Text("délégué principal de l'évenement '\(itemEnCours?.principal?.leNom ?? ""),' \n")
//            + Text("et membre de \(itemEnCours?.groupes?.count ?? 0) autres groupes ?")
//            + Text("\(itemEnCours?.groupes?.map {($0 as! Groupe).nom}.debugDescription ?? "") "),
//            primaryButton: .default(
//                            Text("NON, je dois réfléchir un peu."),
//                            action: abandoner
//                        ),
//            secondaryButton: .destructive(Text("OUI, j'ai même pas peur !"), action: {print("")}) //accepter(positions: i) )
//            // ou dismissButton
//        )
//    }
      
      
//    .alert(item: $appError) {appError in
//        Alert(title: Text("!!!!!"),
//              message: Text(appError.error.localizedDescription),//,
//              dismissButton: .default(Text("Got it!"))
//        )
//
//    }
    
    
//    .alert("Suppresion", isPresented: $alerteAffichée) {
//        Alert(title: Text("Attention"),
//              message: Text("Supprimer les contibutions de \(itemEnCours?.titre ?? "") ?"),
//              dismissButton: .default(Text("Got it!"))
//            )
//        Text("Supprimer les contibutions de \(itemEnCours?.titre ?? "") ?")
//        Button("Oui", role: .destructive) { }
//        Button("Non", role: .cancel) { }
//    }
      
      
      
  }

    private func abandoner() {}
    private func accepter(positions: IndexSet) {}

  
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

    
    private func RallierGroupe() {
        withAnimation {
//            Groupe.rallier(<#T##self: Groupe##Groupe#>)(contexte:viewContext)
            }
        }

    
    private func proposerSuppressionItems(positions: IndexSet) {
        print("🔘 Proposition de suppression de :", positions.map { items[$0].titre ?? ""} )
        itemsSupprimables = positions
        }
    
    private func supprimerItems(positions: IndexSet) {
    //TODO: on pourrait utiliser  item.prepareForDeletion()
        print("🔘 Suppression de :", positions.map { items[$0].titre ?? ""} )
        alerteAffichée = true
        positions.forEach {
            let item = items[$0]
            print("\t🔘 Suppression de :", item.titre ?? "" )
            itemEnCours = item
            alerteAffichée = true
            print("🔘", $0 + 1, "° item du menu :", item.titre ?? ", valeur :", item.valeur , " , membre de" , item.groupes?.count ?? 0, "groupes")
            print("🔘\t:" , item.groupes?.map { ($0 as! Groupe).nom ?? ""} ?? "" )

            item.removeFromGroupes(item.groupes ?? [])
//            item.delete()
            persistance.sauverContexte()
            }
                    
        withAnimation {
            persistance.supprimerObjets(positions.map { items[$0] })
            }
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

    
    private func GenererErreur() {
        appError = ErrorType(error: .trucQuiVaPas(num: 666))
        }

}
