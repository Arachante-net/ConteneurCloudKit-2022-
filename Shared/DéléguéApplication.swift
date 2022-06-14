
import CloudKit
import SwiftUI


final class DéléguéApplication: NSObject, UIApplicationDelegate {
    
  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    print("〽️〽️⚜️ Délégué de l'application")
    let configurationScene = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    configurationScene.delegateClass = DéléguéScene.self
    return configurationScene
    }
    
  }



final class DéléguéScene: NSObject, UIWindowSceneDelegate {
    // hérité de UIWindowSceneDelegate.windowScene(_:userDidAcceptCloudKitShareWith:).
  
    
    /// Indique au délégué l'accès aux informations de partage CloudKit.
    /// repondre à une invitation  de partage CK
    func windowScene(_ windowScene: UIWindowScene,
                   userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
      print("〽️⚜️ Délégué de Scene, fênetre accepter les invitations de partage de" , cloudKitShareMetadata.share.owner.userIdentity.nameComponents?.givenName ?? "...")
        
      let controleurDePersistance = ControleurPersistance.shared
      let magasinPartagé          = controleurDePersistance.magasinPersistantPartagé
      let conteneurPersistent     = controleurDePersistance.conteneur
        
      conteneurPersistent.acceptShareInvitations(from: [cloudKitShareMetadata], into: magasinPartagé) { oo, error in
          print("〽️⚜️ Délégué de Scene, conteneur persistent : accepter les invitations de partage.")
          print("〽️⚜️" ,            oo?.first?.ownerIdentity.nameComponents?.givenName ?? "..." , "|", oo?.first?.containerIdentifier ?? "...", "|", oo?.count ?? "...")
          print("〽️⚜️" , cloudKitShareMetadata.ownerIdentity.nameComponents?.givenName ?? "..." , "|", cloudKitShareMetadata.share.recordType )
          
          if let error = error {
                print("❗️ ERREUR avec acceptShareInvitation :\(error)")
                }
          }
      }
  }
