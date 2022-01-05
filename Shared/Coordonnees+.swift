//Arachante
// michel  le 26/12/2021
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.1
//
//  2021
//

import Foundation
import MapKit

extension CLLocationCoordinate2D:Hashable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
        }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)

    }
}
//Generic struct 'ForEach' requires that 'CLLocationCoordinate2D' conform to 'Hashable'
