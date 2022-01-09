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
    
    
  @EnvironmentObject private var persistance: ControleurPersistance
//    let controleurDePersistance = ControleurPersistance.shared

    
  @Environment(\.managedObjectContext) private var viewContext

  @State private var groupeItemChoisi: Groupe? //= 0 //= groupe //[0]
    
  let uid = UserDefaults.standard.string(forKey: "UID")
    
  @State var appError: ErrorType? = nil

    
  var body: some View {
      
      VStack {
//          let _ = utilisateur.isICloudContainerAvailable()
//          Text( utilisateur.obtenirID() ).font(.footnote).fontWeight(.thin) //.ultraLight)
          
          TabView {
            ListeGroupe().tabItem {
                VStack {
                    Image(systemName: "tray.full.fill")
                    Text("Événements")
                    }
                }
            .tag(1)
//            .badge("G")

        
              ListeItem(appError: $appError).tabItem {
//              ListeItem().tabItem {
                VStack {
                    Image(systemName: "sun.max.fill")
                    Text("Items")
                    }
                }
            .tag(2)
            .badge("I")
      
            Reglages().tabItem {
                VStack {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Réglages")
                    }
                }
            .tag(3)
  
          } // tab view
      }
//      .environmentObject(appError ?? <#default value#>)
      .alert(item: $appError) {appError in
          Alert(title: Text("!!!!!"),
                message: Text(appError.error.localizedDescription)//,
  //              dismissButton: <#T##Alert.Button?#>
          )
          
      }
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
