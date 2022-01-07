//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI

//let truc = ""
@main
struct ConteneurCloudKitApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let controleurDePersistance = ControleurPersistance.shared
    let utilisateur = Utilisateur()
    var appError: ErrorType? = nil


    var body: some Scene {
        WindowGroup {
            VuePrincipale()
                .environment(\.managedObjectContext, controleurDePersistance.conteneur.viewContext)
                // 'ControleurPersistance' doit être conforme à 'ObservableObject'
                .environmentObject(controleurDePersistance)
                .environmentObject(utilisateur)
//                .environmentObject(appError)


//                .environment(\.persistence, persistenceController)

        }
        
        .onChange(of: scenePhase) { phase in
          switch phase {
              case .background:
//            persistenceController.sauverContext() // à écrire
              controleurDePersistance.sauverContexte()
              break
          default:
            break
          }
        }

        
    }
}
