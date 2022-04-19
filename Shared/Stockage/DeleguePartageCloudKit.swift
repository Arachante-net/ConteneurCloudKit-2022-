//Arachante
// michel  le 18/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import Foundation
import UIKit


///
/// Recevoir les notifications du contrôleur de partage CloudKit.
/// et fournir des informations supplémentaires
class DeleguePartageCloudKit:NSObject, ObservableObject, UICloudSharingControllerDelegate {
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("partage")
        }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        print("partage")
        return "titre"
        }
    
//    func isEqual(_ object: Any?) -> Bool {
//         false
//    }
    
//    var hash: Int = 0
    
//    var superclass: AnyClass?
    
//    func `self`() -> Self {
//    }
    
//    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
//
//    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
//
//    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        <#code#>
//    }
    
//    func isProxy() -> Bool {
//        false
//    }
    
//    func isKind(of aClass: AnyClass) -> Bool {
//        false
//    }
    
//    func isMember(of aClass: AnyClass) -> Bool {
//        false
//    }
    
//    func conforms(to aProtocol: Protocol) -> Bool {
//        false
//    }
    
//    func responds(to aSelector: Selector!) -> Bool {
//        false
//    }
    
//    var description: String = ""
    func maDescription() -> String {"CECI EST MA DESCRIPTION"}
    
    }

