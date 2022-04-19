//Arachante
// michel  le 13/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import Foundation

protocol Synthétisable {
    associatedtype Element
    static func synthétiser() -> Element?
    }
