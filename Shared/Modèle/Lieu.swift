//Arachante
// michel  le 26/12/2021
// pour le projet  PositionUtilisateur
// Swift  5.0  sur macOS  12.1
//
//  2021 27 Décembre
//

import Foundation
import MapKit
import os.log

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


struct PositionIdentifiable: Identifiable {
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
  let libellé: String
  let message:String
  let coordonnées: CLLocationCoordinate2D
  let couleur: UIColor
  let valeur : Int
//  let item : Item?
  let visible : Bool = true
  let itemID : UUID
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
    
//    mutating func zoom() {
//        span.latitudeDelta  = 10
//        span.longitudeDelta = 10
//        }
    
    /// La région géographique qui  englobe  un ensemble de coordonnées
    /// En entrée lesCoordonnées    : [CLLocationCoordinate2D]
    /// En sortie la région: MKCoordinateRegion  englobant toutesLesCoordonnées
    static func englobante(lesCoordonnées : [CLLocationCoordinate2D]) -> MKCoordinateRegion {
#warning("Attention ...    ")
//#error("Erreur ! ")
        
        let lesLongitudes = lesCoordonnées.map {$0.longitude}
        let lesLatitudes  = lesCoordonnées.map {$0.latitude}
        
        let P1 = CLLocationCoordinate2D(latitude: lesLatitudes.min()!, longitude: lesLongitudes.min()!)
        let P2 = CLLocationCoordinate2D(latitude: lesLatitudes.max()!, longitude: lesLongitudes.max()!)
        
        Logger.modélisationDonnées.info("🏁 Min Min \(P1.longitude) \(P1.latitude)")
        Logger.modélisationDonnées.info("🏁 Max Max \(P2.longitude) \(P2.latitude)")

        let   π = Double.pi
        let _2π = 2 * π
        let _3π = 3 * π

        let Rad = π/180
        let Deg = 180/π
        
        let φ1 = P1.latitude * Rad
        let φ2 = P2.latitude * Rad
        
        let λ1 = P1.longitude * Rad
        let λ2 = P2.longitude * Rad
        
        let Δλ = λ2 - λ1 // long
        let Δφ = φ2 - φ1  // lat
        
        Logger.modélisationDonnées.info("🏁 Delta long \(Δλ)  lat \(Δφ)")


// https://www.movable-type.co.uk/scripts/latlong.html
//        Bx = cos φ2 ⋅ cos Δλ
//        By = cos φ2 ⋅ sin Δλ
//        φm = atan2( sin φ1 + sin φ2, √(cos φ1 + Bx)² + By² )
//        λm = λ1 + atan2(By, cos(φ1)+Bx)
//--------------------------------------------------------------
// Voir aussi https://stackoverflow.com/questions/4169459/whats-the-best-way-to-zoom-out-and-fit-all-annotations-in-mapkit
        
// atan2 returne des valeurs entre -π ... +π ( -180° ... +180°)
// afin de normaliser en une valeur entre 0° et 360°, with −ve values ttransformées entre 180° ... 360°),
// convertir en degrees and then use (θ+360) % 360 ( % <=> truncatingRemainder(dividingBy) )
        
//        For final bearing, simply take the initial bearing from the end point to the start point and reverse it (using θ = (θ+180) % 360).
        
        let Bx = cos(φ2) * cos(Δλ)
        let By = cos(φ2) * sin(Δλ)
        let φm = atan2(sin(φ1) + sin(φ2), sqrt( (cos(φ1)+Bx)*(cos(φ1)+Bx) + By*By ) )
        let λm = λ1 + atan2(By, cos(φ1) + Bx)
        // Normaliser la longitude entre -180° et +180°
        let λm_ = (λm + _3π).truncatingRemainder(dividingBy: _2π) -  π
        // l'ecart de longitude
        let Δλ_ = abs((Δλ + _3π).truncatingRemainder(dividingBy: _2π) -  π)
        
        // ??? Normaliser la latitude entre -90° et +90° ?
//        let φm_ = φm * -1 //(φm + (3 * π / 2).truncatingRemainder(dividingBy: π) -  (π / 2))
//        let φm_ = (φm + π) .truncatingRemainder(dividingBy:_2π) - π // INCHANGÉ ...
//        let φm_ = (φm + (3 * π / 2)).truncatingRemainder(dividingBy: π) -  (π / 2) // INCHANGÉ
        let φm_ = (φm +   (π / 2 ) ).truncatingRemainder(dividingBy: π) -  (π / 2)
//        let φm_ = (φm +   (π / 2 ) ).truncatingRemainder(dividingBy: π) -  (π / 2)

        Logger.modélisationDonnées.info("🏁 φm brut \(φm * Deg) , normalisé \(φm_ * Deg)")

        // ???? l'ecart de latitude
        let Δφ_ = (Δφ + (3 * π / 2).truncatingRemainder(dividingBy: π) -  (π / 2))


        let P_milieu = CLLocationCoordinate2D(latitude:φm_ * Deg, longitude: λm_ * Deg)
        Logger.modélisationDonnées.info ("🏁 Le centre de \(P1.longitude) \(P1.latitude)  et  \(P2.longitude) \(P2.latitude)")
        Logger.modélisationDonnées.info ("🏁 est \(P_milieu.longitude) \(P_milieu.latitude)")
        Logger.modélisationDonnées.info ("🏁 l'écart en longitude est de \(Δλ * Deg) \(Δλ_ * Deg) °" )
        Logger.modélisationDonnées.info ("🏁 l'écart en  latitude est de \(Δφ * Deg) \(Δφ_ * Deg) °" )

        // normaliser la longitude entre  −180…+180 : (lon+540)%360-180
        // truncatingRemainder
        // (λ3+540).truncatingRemainder(dividingBy: 360) - 180
        
        // Élargir l'envergure de la zone de 5% 0.5
        // let envergure = MKCoordinateSpan(
        // latitudeDelta:  (ecartLatitudes  + (ecartLatitudes  * 0.5)).truncatingRemainder(dividingBy: 180),
        // longitudeDelta: (ecartLongitudes + (ecartLongitudes * 0.5)).truncatingRemainder(dividingBy: 360))
            let envergure = MKCoordinateSpan(
                // En degrée et un peu d'espace autour
                latitudeDelta:  Δφ_ * Deg * 1.5,
                longitudeDelta: Δλ_ * Deg * 1.5
                )
        
            // MapKit ne peut pas afficher l'ensemble du globe,
            // pour la région ci dessous il faut faire defiler la carte.
            // Detecter et prévenir que l'on depasse le facteur de zoom MapKit.  C'est lequel ??
            // max latitudeDelta : 180
            // cf regionThatFits
           _ = Lieu.étendueMax
        
//        MKCoordinateSpan(
//                latitudeDelta:  180,
//                longitudeDelta: 360
//                )

            Logger.modélisationDonnées.info ("🏁 Carte Milieu \(P_milieu.longitude) \(P_milieu.latitude) ")
            Logger.modélisationDonnées.info ("🏁 Carte Envergure long \(envergure.longitudeDelta) lat \(envergure.latitudeDelta)")

            let région = MKCoordinateRegion(center: P_milieu, span: envergure) //envergureMondiale)
//            let régionAdaptée = regionThatFits(région)
//        MapKit.MKCoordinateRegion.   regionThatFits(région)
            return région

    }
    
    static let ApplePark = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 37.334_900,
                                         longitude: -122.009_020),
          latitudinalMeters: 750,
          longitudinalMeters: 750
      )
}
