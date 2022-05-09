//Arachante
// michel  le 22/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import XCTest
@testable import ConteneurCloudKit
import CoreData

class TestsServicesCoreData: XCTestCase {
    
//    var reportService: ReportService!
    var coreDataStack: ControleurPersistance!
    
    override func setUp() {
      super.setUp()
      coreDataStack = CoreDataDeTest()
//      reportService = ReportService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        var donnéesDeTest = CoreDataDeTest()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testDesTrucs() throws {
        let donnéesDeTest = CoreDataDeTest()
        XCTAssertEqual(donnéesDeTest.desTrucs.count, 0, "doit être vide lors de l'init")
        XCTAssertTrue(donnéesDeTest.bloup == "BLOUP")
        }
    
    func testAjouterUnGroupe() throws {
        let donnéesDeTest = CoreDataDeTest()
        let signature = Groupe.signature
//        XCTAssertNotNil( donnéesDeTest.contexteDeTest)
        XCTAssertNotNil(coreDataStack.conteneur.viewContext)
        XCTAssertTrue(signature == "Arachante")
        XCTAssertEqual(Groupe.signature , "Arachante")

        
        let groupe = Groupe.fournirNouveau(contexte: coreDataStack.conteneur.viewContext, nom:"Pinochio")
        XCTAssertEqual(groupe.nom      , "Pinochio", "bof")
        XCTAssertEqual(groupe.leNom    , "Pinochio")
        XCTAssertEqual(groupe.createur , "6469F39C-0076-5E1D-8623-C270AB9F488B")

        XCTAssertFalse(groupe.collaboratif)
        XCTAssertTrue(groupe.valide)
        
        let groupe2 = Groupe.exemple(contexte: coreDataStack.conteneur.viewContext)
        XCTAssertEqual(groupe2.icone      , "rectangle")
        XCTAssertEqual(groupe2.nom        , "Exemple de groupe")
        XCTAssertEqual(groupe2.objectif   , "Voyage avec notre vaisseau spatial dans l'Espace, cette frontière de l'infini. Notre mission de cinq ans : explorer de nouveaux mondes étranges, découvrir de nouvelles vies, d'autres civilisations, et au mépris du danger avancer vers l'inconnu...")
        XCTAssertEqual(groupe2.ordre  ,  0)
        XCTAssertTrue(groupe2.valide)
        XCTAssertNotNil(groupe2.id)
        
        XCTAssertEqual(groupe.leNom    , "Pinochio")

        

//        Groupe.creer(contexte: coreDataStack.conteneur.viewContext, titre: "UN TITRE DE TEST", collaboratif: true)
//        XCTAssertEqual(groupe3.nom        , "Exemple de groupe")

//        XCTAssertTrue(donnéesDeTest.bloup == "BLOUP")
//          XCTAssertNotNil(controleurPersistanceDeTest, "on a un contexte")
        
//        XCTAssertNotNil(groupe, "Le nouveau groupe doit éxister donc ne pas être égal à nil")
//        XCTAssertTrue(groupe.valeur == 0)


//
//        let maintenant = Date()
////        Groupe.creer(contexte:contextDeTest, titre:"oui" , collaboratif:true)
//
//      XCTAssertNotNil(groupe.id, "Ne doit pas être nil")
//      XCTAssertTrue(groupe.valide, "Doit être valide")
    }
    
    
//    func testSauvegardeContexteApresAjout() {
//        let donnéesDeTest = CoreDataDeTest()
//        Groupe.creer(contexte: coreDataStack.conteneur.viewContext, titre: "UN TITRE DE TEST", collaboratif: true)
//
////      let derivedContext = coreDataStack.newDerivedContext()
////      reportService = ReportService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
//
//      expectation(
//        forNotification: .NSManagedObjectContextDidSave,
//        object: coreDataStack.conteneur.viewContext) { _ in
//            return true
//            }
//
//        coreDataStack.conteneur.viewContext.perform {
//            Groupe.creer(contexte: self.coreDataStack.conteneur.viewContext, titre: "UN TITRE DE TEST", collaboratif: true)
//
////            reportService.add("Death Star 2", numberTested: 600, numberPositive: 599, numberNegative: 1)
//
////        XCTAssertNotNil(groupe)
//      }
//
//      waitForExpectations(timeout: 5.0) { error in
//          XCTAssertNil(error, "Pas vu passer la sauvegarde")
//        }
//    }
    
    
    

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
////        measure {
////            // Put the code you want to measure the time of here.
////        }
//    }

}
