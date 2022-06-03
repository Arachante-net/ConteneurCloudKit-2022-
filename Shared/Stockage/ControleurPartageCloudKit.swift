
import CloudKit
import SwiftUI

//struct CloudSharingView: UIViewControllerRepresentable {
struct VuePartageCloudKit: UIViewControllerRepresentable {
    
// VuePartageCloudKit est conforme au protocole UIViewControllerRepresentable
// et enveloppe le UICloudSharingController de UIKit, afin de l'utiliser depuis SwiftUI.

  let partage:     CKShare     // Un enregistrement qui gère une collection de documents partagés.
  let conteneurCK: CKContainer // le conteneur Cloud Kit qui contient les bases de données privées, partagées ou publiques.
  
  let itemAPartager: Item // l'objet (l'entité) à partager (qui contient les données à partager)
  let coordinateur : DéléguéDuControleurDePartageChargéDeLaCoordination // défini dans VueDetailItem


    
    
//    mutating func makeCoordinator() -> CoordinateurDePartageCloudKit {
//      coordinateur = CoordinateurDePartageCloudKit(item: itemAPartager)
//      let _ = print("〽️〽️ make Coordinateur", coordinateur)
//      return coordinateur
//    }

  /// Fournir l'écran permettant à l'utilisateur  d'inviter, octroyer des droits, arrêter de participer ...
  func makeUIViewController(context: Context) -> UICloudSharingController { // UIViewControllerRepresentableContext<Self>
    let _ = print("〽️〽️ Construction du controlleur 'UI View Controller'")
    //////////////////  partage[CKShare.SystemFieldKey.title] = "⏹〽️〽️\(itemAPartager.titre) makeUIViewController" // Affiché lors du partage
    
      /// Définir le controleur de partage CK et lui associer son délégué à la coordination (défini dans  VueDetailItem)
      let contrôleurDePartage = UICloudSharingController(share: partage, container: conteneurCK)
//        controller.toolbarItems = [] //DEVIL
        contrôleurDePartage.modalPresentationStyle = .popover //.formSheet cf. iPad
      let _ = print("〽️〽️ Délégation au coordinateur", coordinateur, "du contrôle de partage.")
        contrôleurDePartage.delegate = coordinateur //makeCoordinator()  //  CoordinateurDePartageCloudKit(item: itemAPartager) //context.coordinator // UICloudSharingControllerDelegate? //DEVIL
        contrôleurDePartage.availablePermissions = [.allowPrivate, .allowReadOnly] // allowReadWrite   //DEVIL
    let _ = print("〽️〽️ coordinateur délégué du controleur", contrôleurDePartage.delegate) //context.coordinator)
    return contrôleurDePartage
    } // makeUIViewController

  func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
      let _ = print("〽️ MàJ fenêtre de partage (appel de updateUIViewController)")
      }
    
  } //VuePartageCloudKit






/// Fournir des informations supplémentaires et recevoir des notifications
/// contrôleur de partage CloudKit.
final class DéléguéDuControleurDePartageChargéDeLaCoordination: NSObject, UICloudSharingControllerDelegate {
    @EnvironmentObject private var persistance : ControleurPersistance
    
    let item: Item
    
    init(item: Item) {
        print("〽️〽️ Initialisation du coordinateur/délégué du partage (CloudSharingCoordinator)", "pour",  item.titre ?? "...")
        self.item = item }

  func itemTitle(for csc: UICloudSharingController) -> String? {
      print("〽️〽️〽️ Définition du titre du partage (", item.titre ?? "...", ")")
      return "✅\(String(describing: item.titre) ) délégué" }

    
  // Fournir la vue miniature de l'invitation de partage.
    // itemThumbnailData(for:) n'est appelé que lors de la création d'un nouveau partage.
    // Pour un partage existant, l'image miniature est récupérée à partir du partage à l'aide de la clé CKShare_SystemFieldKey_imageData.
  func itemThumbnailData(for: UICloudSharingController) -> Data? {
      let image = UIImage(named: "Soucoupe")
      let donnéesImage = image?.pngData()
      print("〽️〽️〽️ création de la vue miniature de l'invitation de partage, largeur :", image?.size.width ?? 0, "x hauteur :", image?.size.height ?? 0,  ", données:" , donnéesImage?.count ?? 0, "octets")//   isEmpty ?.debugDescription)
      return donnéesImage     // .pngRepresentationData
      }

//   // Uniform Type Identifier (UTI) d'un item.
//  func itemType(for: UICloudSharingController) -> String? {
//      // return kUTTypePNG as String
//      nil
//      }
    
  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
      // Indique au délégué que le contrôleur de partage CloudKit n'a pas réussi à enregistrer l'enregistrement de partage.
      print("〽️〽️〽️ Erreur à l'enregistrement du partage : \(error)")
      }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
      // Indique au délégué que le contrôleur de partage CloudKit a enregistré l'enregistrement de partage.
      print("〽️〽️〽️ Le contrôleur de partage iCloud a bien enregistré le partage (cloudSharingControllerDidSaveShare)")
      }

    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        // Indique au délégué que l'utilisateur a cessé de partager l'enregistrement.
      print("〽️〽️〽️ Le contrôleur de partage iCloud a arrêté de partager  (cloudSharingControllerDidStopSharing)")
        if !persistance.jeSuisPropriétaire(objet: item) {
            persistance.supprimerObjets([item])
        }
        
//        if !stack.isOwner(object: item) {
///////////////////        stack.delete(item)
//        stack.supprimerObjets([item])
//      }
        
        
    }
    
    func tester() { print("〽️〽️〽️ testons donc", self, item.leTitre) }
    
    
}// CloudSharingCoordinator
