//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(
      fetchRequest: Item.extractionItems, //ListeItem.demandeDeRecuperation,
      animation: .default)
    var items_: FetchedResults<Item>

    
    @EnvironmentObject private var persistance: ControleurPersistance

    @State var titre: String = ""
    @State var valeur: Int = 0

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    
                    NavigationLink(destination: VueDetailItem(item: item)) {
                        Text("\(item.valeur)   | ") +
                        Text(item.titre ?? "-")
                        }
                    
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter) ")
//                        TextField("Titre carte :", text: $titre)
//                        Stepper("\(valeur) points", value: $valeur, in: 4...12, step: 1)
//                        Button(action: {
//                            item.titre  = titre
//                            item.valeur = Int64(valeur)
//
//                            do {
//                                try viewContext.save()
//                            } catch {
//                                print(error)
//                            }
//
////                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Text("Sauver")
//                        }
//
//
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
                    .onAppear(perform: {
                        valeur = Int(item.valeur)
                        titre = item.titre ?? ""
                        })
                    .onDisappear {
                        print("\nAu revoir !", titre, item.titre ?? "" , "\n")}
                }
                .onDelete(perform: deleteItems)
//              .onMove(perform: deplacer)
               
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.titre = "nouveau"
            newItem.valeur = 0

            persistance.sauverContexte("Item")
            
//            do { try persistance.sauverContexte("Item") } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
            
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            persistance.sauverContexte("Item") 
//            do {try persistance.sauverContexte("Item") }
//            catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, ControleurPersistance.preview.container.viewContext)
//    }
//}
