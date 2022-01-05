//Arachante
// michel  le 15/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//


import SwiftUI
import CoreData

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
        .onDelete(perform: supprimerItems)
      }
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) {EditButton().help("SOS") }}
      .navigationBarTitle(Text("Items"))
      .navigationBarItems(
        leading:
            HStack {
                Button(action: ajouterItem)      { Label("Ajouter un Item",        systemImage: "plus"                 )} .help("OUI")
                Button(action: ajouterGroupeItem){ Label("Ajouter un Groupe/Item", systemImage: "plus.square.dashed"   )}
                Button(action: RallierGroupe)    { Label("Rallier un groupe",      systemImage: "plus.square.on.square")}
                },
        trailing: Button(action: { let _ = Item.extractionItems }) { Image(systemName: "arrow.2.circlepath")}
       )
        
        
        
    } .alert("Suppresion", isPresented: $alerteAffichée) {
        Text("Supprimer les contibutions ?")
        Button("Oui", role: .destructive) { }
        Button("Non", role: .cancel) { }

    }
  }

    
  
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

    
    private func supprimerItems(positions: IndexSet) {
    //TODO: on pourrait utiliser  item.prepareForDeletion()
        print("🔘 Suppression de :", positions.map { items[$0].titre ?? ""} )
        alerteAffichée = true
        positions.forEach {
            let item = items[$0]
//            print("🔘", $0 + 1, "° item du menu :", item.titre ?? ", valeur :", item.valeur , " , membre de" , item.groupes?.count ?? 0, "groupes")
//            print("🔘\t:" , item.groupes?.map { ($0 as! Groupe).nom ?? ""} ?? "" )

            item.removeFromGroupes(item.groupes ?? [])
            }
                    
        withAnimation {
            persistance.supprimerObjets(positions.map { items[$0] })
            }
        }
    


}
