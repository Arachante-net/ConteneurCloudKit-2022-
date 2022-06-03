
import CloudKit
import SwiftUI


final class DéléguéApplication: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    print("〽️〽️ Délégué de l'application")
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = DéléguéScene.self
    return sceneConfig
    }
  }



final class DéléguéScene: NSObject, UIWindowSceneDelegate {
    // hérité de UIWindowSceneDelegate.windowScene(_:userDidAcceptCloudKitShareWith:).
  func windowScene(_ windowScene: UIWindowScene,
                   userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
      print("〽️〽️ Délégué de Scene : fênetre accepter les invitations de partage")
      let controleurDePersistance = ControleurPersistance.shared
      let shareStore              = controleurDePersistance.magasinPersistantPartagé
      let persistentContainer     = controleurDePersistance.conteneur//    persistentContainer
      persistentContainer.acceptShareInvitations(from: [cloudKitShareMetadata], into: shareStore) { _, error in
        print("〽️〽️ Conteneur persistent : accepter les invitations de partage / délégué de scene ")
        if let error = error {
            print("acceptShareInvitation error :\(error)")
            }
      }
    }
  }
