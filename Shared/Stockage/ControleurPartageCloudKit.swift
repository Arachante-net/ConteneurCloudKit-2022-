
import CloudKit
import SwiftUI

//struct CloudSharingView: UIViewControllerRepresentable {
struct VuePartageCloudKit: UIViewControllerRepresentable {
    
// VuePartageCloudKit est conforme au protocole UIViewControllerRepresentable
// et enveloppe le UICloudSharingController de UIKit, afin de l'utiliser depuis SwiftUI.

  let partage: CKShare // Un enregistrement qui gère une collection de documents partagés.
  let conteneurCK: CKContainer // le conteneur Cloud Kit qui contient les bases de données privées, partagées ou publiques.
  let item: Item // l'entité à partager (qui contient les données à partager)


    
    
  func makeCoordinator() -> CloudSharingCoordinator {
      let _ = print("〽️ make Coordinator")
    return CloudSharingCoordinator(item: item)
    }

  func makeUIViewController(context: Context) -> UICloudSharingController { // UIViewControllerRepresentableContext<Self>
    let _ = print("〽️ make UI View Controller")
    partage[CKShare.SystemFieldKey.title] = item.titre //caption
    let controller = UICloudSharingController(share: partage, container: conteneurCK)
        controller.modalPresentationStyle = .formSheet
        controller.delegate = context.coordinator
    let _ = print("〽️ make context.coordinator", context.coordinator)
    return controller
    } // makeUIViewController

  func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
      let _ = print("〽️ make update UI View Controller")
      }
    
  } //VuePartageCloudKit






final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
    @EnvironmentObject private var persistance : ControleurPersistance
    // comment etre certain qu'il sagit bien du sungleton ?
    ////////////    let stack =    ControleurPersistance.shared //  CoreDataStack.shared
    
    let item: Item
    
    init(item: Item) {
        print("〽️ make init CloudSharingCoordinator", item.titre)
        self.item = item }

  func itemTitle(for csc: UICloudSharingController) -> String? { item.titre }

    
  // Fournir la vue miniature de l'invitation de partage.
  func itemThumbnailData(for: UICloudSharingController) -> Data? {
      let image = UIImage(named: "Soucoupe")
      let donnéesImage = image?.pngData()
      print("❗️❗️❗️❗️make vue miniature de l'invitation de partage, largeur :", image?.size.width ?? 0, "x hauteur :", image?.size.height ?? 0,  ", données:" , donnéesImage?.count, "octets")//   isEmpty ?.debugDescription)
      return donnéesImage     // .pngRepresentationData
      }

   // Uniform Type Identifier (UTI) d'un item.
  func itemType(for: UICloudSharingController) -> String? {
      // return kUTTypePNG as String
      nil
      }
    
  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
    print("❗️❗️❗️make Failed to save share: \(error)")
    }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("❗️make Le contrôleur de partage iCloud a enregistré le partage (cloudSharingControllerDidSaveShare)")
    }

    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
      print("❗️make Le contrôleur de partage iCloud a arrêté de partager  (cloudSharingControllerDidStopSharing)")
        if !persistance.isOwner(object: item) {
            persistance.supprimerObjets([item])
        }
        
//        if !stack.isOwner(object: item) {
///////////////////        stack.delete(item)
//        stack.supprimerObjets([item])
//      }
    }
    
    
}// CloudSharingCoordinator
