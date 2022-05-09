//Arachante
// michel  le 23/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import XCTest
@testable import ConteneurCloudKit
import CoreData
import CoreLocation

class TestGéographie: XCTestCase {
    
    private var contexteDeTest: NSManagedObjectContext?

    override func setUp() {
        contexteDeTest = NSManagedObjectContext.versionPourTests()
        }
    
    override func tearDownWithError() throws {
        super.tearDown()
        contexteDeTest = nil
        }

    
    
    //MARK: - tests unitaires -
    
    
    //MARK: Environnement
    func testEnvironementDeTest() {}
    
    //MARK:
    
    func testCoordonnées() {
        // rappel :
        // Les latitudes sont exprimées en degrés : entre -90.000° & 90.0000°
        // Les longitudes sont exprimés en degrés : entre -180.0000° et 180.000°
        let groupe = Groupe.creer(contexte: contexteDeTest!)
//        var lesCoordonnées: [CLLocationCoordinate2D]

        groupe.principal?.latitude  = 5
        groupe.principal?.longitude = 5
        XCTAssertEqual(groupe.lesCoordonnées.count, 0, "Uniquement le principal, pas d'items associés")

        XCTAssertEqual(groupe.régionEnglobante.center.longitude, groupe.principal?.longitude, "Les coordonnées du seul principal")
        XCTAssertEqual(groupe.régionEnglobante.center.latitude,  groupe.principal?.latitude,  "Les coordonnées du seul principal")

        
        // position1
        let item1 = Item.fournirNouveau(contexte: contexteDeTest!)
        item1.latitude  = -10
        item1.longitude = -10

        // position2
        let item2 = Item.fournirNouveau(contexte: contexteDeTest!)
        item2.latitude  = 10 //70
        item2.longitude = 10 //70

        // Ajouter un premier item au groupe
        groupe.lesItems.insert(item1)
        XCTAssertEqual(groupe.lesCoordonnées.count, 1, "Seulement un item (et le principal)")
        XCTAssertEqual(groupe.lesCoordonnées.first?.latitude, item1.latitude)
        XCTAssertEqual(groupe.lesCoordonnées.count, groupe.lesItems.count, "Autant de coordonnées que d'items")

        XCTAssertEqual(groupe.lesCoordonnées.count, 1)
        XCTAssertEqual(groupe.lesCoordonnées.count, groupe.lesItems.count, "Autant de coordonnées que d'items")

        XCTAssertEqual(groupe.régionEnglobante.center.longitude, -2.46 , accuracy: 0.1, "le centre entre principal (5) et item (-10)")
        XCTAssertEqual(groupe.régionEnglobante.center.latitude,  -2.52 , accuracy: 0.1, "le centre entre principal (5) et item (-10)")

        // Ajouter un deuxieme item au groupe
        groupe.lesItems.insert(item2)
        XCTAssertEqual(groupe.lesCoordonnées.count, 2)
        XCTAssertEqual(groupe.lesCoordonnées.count, groupe.lesItems.count, "Autant de coordonnées que d'items")

        XCTAssertEqual(groupe.régionEnglobante.center.longitude,   0, accuracy: 1, "longitude entre (-10, -10) et (10, 10)")
        XCTAssertEqual(groupe.régionEnglobante.center.latitude,    0, accuracy: 1,  "latitude entre (-10, -10) et (10, 10)")
    }
    
    func testGéo1() {
        // position1
        // position2
        let centreLatitude = 0
        let centreLongitude = 0
        XCTAssertEqual(centreLatitude,  0)
        XCTAssertEqual(centreLongitude, 0)
        }
    
    
}
