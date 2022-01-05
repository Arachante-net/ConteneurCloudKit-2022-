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


    static let BuckinghamPalace = Lieu(id: UUID(), libellé: "Buckingham Palace", description: "Where Queen Elizabeth lives with her dorgis.",                                               latitude:  51.501   , longitude:   -0.141    )
    static let MontSaintMichel  = Lieu(id: UUID(), libellé: "Mont Saint-Michel", description: "Îlot rocheux consacré à saint Michel où s’élève aujourd’hui l’abbaye du Mont-Saint-Michel.", latitude:  48.636021, longitude:   -1.511496 )
    static let Paris            = Lieu(id: UUID(), libellé: "Paris",             description: "La capitale des Français",                                                                   latitude:  48.856614, longitude:    2.3522219)
    static let Londres          = Lieu(id: UUID(), libellé: "Londres",           description: "La capitale des Anglais",                                                                    latitude:  51.507222, longitude:   -0.1275   )
    static let Tonga            = Lieu(id: UUID(), libellé: "Tonga",             description: "Une île trés à l'Ouest presque 20° sous l'équateur",                                         latitude: -19.916086, longitude: -175.202622 )
    static let Fidji            = Lieu(id: UUID(), libellé: "Fidji",             description: "Une île trés à l'Est presque 20° sous l'équateur",                                           latitude: -18.123973, longitude:  179.01226  )

    static let exemple = MontSaintMichel
    
    static func ==(lhs: Lieu, rhs: Lieu) -> Bool { lhs.id == rhs.id }
}

//FIXME: Une Annotation c'est different d'un Lieu
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
