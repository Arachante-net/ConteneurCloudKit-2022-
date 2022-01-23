//Arachante
// michel  le 26/12/2021
// pour le projet  PositionUtilisateur
// Swift  5.0  sur macOS  12.1
//
//  2021 27 Décembre
//

import Foundation
import MapKit

struct Lieu: Identifiable, Codable, Equatable {
    var id: UUID // ?? UUID() on peut avoir à le modifier

    var libellé: String
    var description: String
    var coordonnées: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    let latitude: Double
    let longitude: Double
//    let couleur: UIColor sinon il manque Codable


    static let BuckinghamPalace = Lieu(latitude:  51.501   , longitude:   -0.141    ,libellé: "Buckingham Palace", description: "Where Queen Elizabeth lives with her dorgis."                                              )
    static let MontSaintMichel  = Lieu(latitude:  48.636021, longitude:   -1.511496 ,libellé: "Mont Saint-Michel", description: "Îlot rocheux consacré à saint Michel où s’élève aujourd’hui l’abbaye du Mont-Saint-Michel.")
    static let Paris            = Lieu(latitude:  48.856614, longitude:    2.3522219,libellé: "Paris",             description: "La capitale des Français"                                                                  )
    static let Londres          = Lieu(latitude:  51.507222, longitude:   -0.1275   ,libellé: "Londres",           description: "La capitale des Anglais"                                                                   )
    static let Tonga            = Lieu(latitude: -19.916086, longitude: -175.202622 ,libellé: "Tonga",             description: "Une île trés à l'Ouest presque 20° sous l'équateur"                                        )
    static let Fidji            = Lieu(latitude: -18.123973, longitude:  179.01226  ,libellé: "Fidji",             description: "Une île trés à l'Est presque 20° sous l'équateur"                                          )

    static let exemple = MontSaintMichel
    
    static func ==(lhs: Lieu, rhs: Lieu) -> Bool { lhs.id == rhs.id }
    
    static let coordonnéesParDéfaut = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0)
    
    static let étendueParDéfaut = MKCoordinateSpan(
        latitudeDelta:  0.5,
        longitudeDelta: 0.5
        )
    
    static let étendueMax = MKCoordinateSpan(
        latitudeDelta:  180,
        longitudeDelta: 360
        )
    
    init(id: UUID = UUID(), latitude: Double, longitude: Double, libellé:String="", description:String="") {
        self.id = id
//        self.coordonnées = CLLocationCoordinate2D(
//            latitude: lat,
//            longitude: long)
        self.latitude    = latitude
        self.longitude   = longitude
        self.libellé     = libellé
        self.description = description
    }
}


struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}




//FIXME: Une Annotation c'est different d'un Lieu (A RATIONALISER)
struct AnnotationGeographique: Identifiable, Hashable {
  let id = UUID()
  let libellé : String
  let coordonnées: CLLocationCoordinate2D
    
  let couleur: UIColor
  }


//// Mardi 28 décembre : NON UTILISÉ
//struct Annotation: Identifiable, Hashable {
//
//  static func == (lhs: Annotation, rhs: Annotation) -> Bool { lhs.id == rhs.id }
//   func hash(into hasher: inout Hasher) { hasher.combine(id) }
//
//  let id = UUID()
//  var id0:Lieu {lieu}   // POURQUOI NE PEUT ÊTRE L'ID ?
//  let lieu: Lieu
//  let couleur: UIColor
//  }


extension MKCoordinateRegion {
    /// recentrer la Région sur les coordonnées de l'Item
    mutating func centrerSur(_ item:Item) {
        center.latitude  = item.latitude
        center.longitude = item.longitude
        }
    
    mutating func zoom() {
        span.latitudeDelta  = 10
        span.longitudeDelta = 10
        }
}
