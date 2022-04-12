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

struct VuePrincipale: View {
    
  // Pas utilisée, sauf pour eventuelle prévisualisation
//  @EnvironmentObject private var persistance: ControleurPersistance
    
  @EnvironmentObject private var utilisateur: Utilisateur
  @EnvironmentObject private var nuage: Nuage

//  @EnvironmentObject private var causeur: Causeur

//TODO: Pas utilisé ?
  @EnvironmentObject private var persistance: ControleurPersistance
//    let controleurDePersistance = ControleurPersistance.shared

    
  @Environment(\.managedObjectContext) private var viewContext

  //@State private var groupeItemChoisi: Groupe? //= 0 //= groupe //[0]
    
  let uid = UserDefaults.standard.string(forKey: "UID")
    
//  @State var appError: ErrorType? = nil

  @StateObject private var viewModel = ViewModel()
    
    @FetchRequest(
      fetchRequest: Item.extractionItems, //ListeItem.demandeDeRecuperation,
      animation: .default)
    var items_: FetchedResults<Item>
    
    var tab_: [Item] = []

    let  l = Logger.interfaceUtilisateur

    init () {
        l.info("init VuePrincipale")
        
        
//        let fetchRequest = FetchRequest<Item>(
//               entity: Item.entity(),
//               sortDescriptors: [])
//
//        tab = fetchRequest.wrappedValue.map { $0 }
//
//        print("TIC-TOC:", tab.count)
//
//        Causeur.causer(items: tab)
    }
    
  var body: some View {
      
      VStack {
//          let _ = utilisateur.isICloudContainerAvailable()
//          Text( utilisateur.obtenirID() ).font(.footnote).fontWeight(.thin) //.ultraLight)
          
          TabView {
            ListeGroupe().tabItem {
                VStack {
                    Image(systemName: "sparkles")
                        .symbolRenderingMode(.hierarchical)

                    Text("Événements")
                    }
                }
            .tag(1)
//            .badge(0)

        
              ListeItem() //appError: $viewModel.appError)
                  .tabItem {
                    VStack {
                        Image(systemName: "sparkle")
                            .symbolRenderingMode(.multicolor)

                        Text("Items")
                        }
                    }
                  .tag(2)
      
            Reglages().tabItem {
                VStack {
                    Image(systemName: "sparkles.square.filled.on.square")
                        .symbolRenderingMode(.palette)
                         .foregroundStyle(
                             .linearGradient(colors: [.red, .black], startPoint: .top, endPoint: .bottomTrailing),
                             .linearGradient(colors: [.green, .black], startPoint: .top, endPoint: .bottomTrailing),
                             .linearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottomTrailing)
                         )
                    Text("Réglages")
                    }
                }
            .tag(3)
            .badge("!")

//              Bienvenue()
         Text("BOF")
              
              
          } // tab view
//          Text("OUI")

      } .background(Color.red, ignoresSafeAreaEdges: .all)
//      Text("NON")
//      .environmentObject(appError ?? <#default value#>)
//      .alert(item: $viewModel.appError) {appError in
//          Alert(title: Text("!!!!!"),
//                message: Text(appError.error.localizedDescription)//,
//  //              dismissButton: <#T##Alert.Button?#>
//          )
//          
//      }
      
  }
        // body
}


//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//      .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
//      .environmentObject(PersistenceController.preview)
//  }
//}
