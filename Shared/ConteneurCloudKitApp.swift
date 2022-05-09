//Arachante
// michel  le 02/11/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.0
//
//  2021
//

import SwiftUI


@main
struct ConteneurCloudKitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase)              private var scenePhase
    
    let leControleurDePersistance = ControleurPersistance.shared
//    let partageur = DeleguePartageCloudKit()
    let utilisateur = Utilisateur()
    let nuage = Nuage()
//    let causeur = Causeur()
    var appError: ErrorType? = nil


    var body: some Scene {
        WindowGroup {
            VuePrincipale()
            //  .environment(\.managedObjectContext, CoreDataStack.shared.context)                  // NSManagedObjectContext
                .environment(\.managedObjectContext, leControleurDePersistance.conteneur.viewContext) // NSManagedObjectContext
/**
 ## Integorations personelles
 `@EnvironmentObject` ressemble beaucoup à un **singleton**
 avec quelques différences (importantes ?)  :
 C'est un éditeur Combine, il se met donc à jour  automatiquement en arrière-plan.
 (Tout ce qui y est abonné est mis à jour.)
 SwiftUI  utilise la notion de source unique de vérité. La vue est une fonction de l'état, de sorte que la vue ne dit jamais au ViewModel quoi faire.
 En théorie, cette approche devrait avoir tous les avantages d'un singleton sans les effets secondaires négatifs ?
 */
            
            
                // Fournir des objets observables ('ObservableObject') à la hiérarchie de vues.
                // 'ControleurPersistance' et les autres doivent être conformes à 'ObservableObject'
                // C'est le singleton qui est placé dans l'environnement
                // Les objets sont lus par n'importe quel enfant en utilisant EnvironmentObject.
                .environmentObject(leControleurDePersistance)
                .environmentObject(utilisateur)
                .environmentObject(nuage)
//                .environmentObject(partageur)


//                .environmentObject(causeur)
//                .environmentObject(appError)
//                .environment(\.persistence, persistenceController)

        }
        
        .onChange(of: scenePhase) { phase in
          switch phase {
              case .background:
                  print("Rafraichir background")
//                  controleurDePersistance.sauverContexte()
              break
          default:
            break
          }
        }

        
    }
}
