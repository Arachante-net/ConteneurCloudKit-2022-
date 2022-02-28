//Arachante
// michel  le 20/02/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.2
//
//  2022
//

import Foundation
import SwiftUI

enum Icones:String, CaseIterable {
//    typealias RawValue = <#type#>
    case pointé  = "circle.inset.filled"
    case coché   = "checkmark"
    case valider = "checkmark.circle.fill"
    case ok      = "checkmark.circle" //chevron.right.square.fill
    case favoris = "heart.fill"

    case voirPlus  = "ellipsis.circle"
    case barreMenu = "ellipsis.rectangle"
    
    case création  = "plus" // ajouter
    case ajouter   = "plus.circle.fill"
    case augmenter = "plus.circle"
    case diminuer  = "minus.circle"
    
    case extraction = "arrow.2.circlepath"
    
    case abandoner = "arrowshape.turn.up.left.circle.fill"
    case arrière   = "arrow.counterclockwise.circle"
    case annuler   = "backward"

    case maPosition = "paperplane.fill"
    
    case editer,
         modifier = "square.and.pencil"
    case éditerP  = "rectangle.and.pencil.and.ellipsis"
    
    case supprimer = "trash"
    
    case affecter = "arrow.up.right.and.arrow.down.left.rectangle.fill"
    case enrolerI = "plus.square.on.square"
    case enroler  = "square.and.arrow.down.on.square.fill"
    case rallier  = "square.and.arrow.up"
    case rallier2 = "tray.and.arrow.down.fill"
    
    case groupes = "sparkles"
    case groupe  = "sparkle"
    
    case reglages = "sparkles.square.filled.on.square"
    // sparkles.square.filled.on.square
    // Icones.xxx.imageSystéme
    var imageSystéme:Image {Image(systemName: self.rawValue)}
    
    // Icones.xxx.imageSystéme()
//    func imageSystéme() -> Image {
//        Image(systemName: self.rawValue)
//                }
}
