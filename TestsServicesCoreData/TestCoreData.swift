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

class TestCoreData: XCTestCase {
    
    var dico: String?
    private var contexteDeTest: NSManagedObjectContext?

    override func setUp() {
        contexteDeTest = NSManagedObjectContext.versionPourTests()
//        print("Récupération d'un contexte pour test")
        }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        contexteDeTest = nil
//        print("Des larmes pour test")
        }

    
    
    //MARK: - tests unitaires -
    
    
    //MARK: Environnement
    func testEnvironementDeTest() {
        XCTAssertNotNil(contexteDeTest,                "Récupération d'un contexte de test")
        XCTAssertEqual(Groupe.signature , "Arachante", "Acces minimal à un objet 'Groupe'")
        }
    
    //MARK: Notifications
    // C'est pas vraiment l'appli qui est testée mais plutôt le mécanisme de notification
    func testEmissionReceptionNotificationMagasinEvolue() {
        let attenteNotification = XCTNSNotificationExpectation (
            name: .NSPersistentStoreRemoteChange,
            object: nil,
            notificationCenter: NotificationCenter.default)
        
        NotificationCenter.default.post(name: .NSPersistentStoreRemoteChange, object: self)
        
        wait(for: [attenteNotification], timeout: 0.1)
        }
    
    // Ici je ne teste pas mon appli, mais je verifie que les notifications circulent
    func testEmissionReceptionMaNotification() {
        // Créer ma notification
        let maNotification = Notification.Name(rawValue: "maNotification")

        // Préciser l'espérance attendue
        let notificationRecue = { (notification: Notification) -> Bool in
            XCTAssertEqual(notification.userInfo?["chiffre"] as! Int, 50, "le chiffre notifié est 50")
            return true
           }
        // Attendre une notification et executer le handler
        expectation(forNotification: maNotification, object: nil, handler: notificationRecue)

        // Mettre en place et lancer un bloc de code ...
        let operation = BlockOperation(block: {
            NotificationCenter.default.post(name: maNotification, object: nil, userInfo: ["chiffre": 50])
            })
        operation.start()
        // ... et espérer
        waitForExpectations(timeout: 0.5, handler: nil)

        // Asserts
//        XCTAssertNotNil(dico)
    }

    
    
    
    
    func testAjouterUnGroupe() throws {
        
        let groupe = Groupe.fournirNouveau(contexte: contexteDeTest!, nom:"Pinochio")
        
        XCTAssertNotNil(groupe,                      "Création d'un 'Groupe'")
        XCTAssertEqual( groupe.nom     , "Pinochio", "verifier sa propriété 'nom' brute")
        XCTAssertEqual( groupe.leNom   , "Pinochio", "verifier sa propriété 'nom' apretée")
        XCTAssertNotNil(groupe.createur,             "verifier que son créateur est bien défini")

        XCTAssertFalse(groupe.collaboratif, "par défaut un groupe n'est pas collaboratif")
        XCTAssertTrue(groupe.valide,        "par défaut à la création un groupe est valide")
        
        let exemple = Groupe.exemple(contexte: contexteDeTest!)
        
        XCTAssertNotNil(exemple,    "création d'un exemple de 'Groupe' avec un peu plus de propriétés")
        XCTAssertNotNil(exemple.id, "le groupe est bien identifié")

        XCTAssertEqual(exemple.icone      , "rectangle",         "Icône par défaut")
        XCTAssertEqual(exemple.nom        , "Exemple de groupe", "Nom par défaut")
        XCTAssertEqual(exemple.objectif   , "Voyage avec notre vaisseau spatial dans l'Espace, cette frontière de l'infini. Notre mission de cinq ans : explorer de nouveaux mondes étranges, découvrir de nouvelles vies, d'autres civilisations, et au mépris du danger avancer vers l'inconnu...", "Objectif par défaut")
        XCTAssertEqual(exemple.ordre  ,  0,                      "Valeur nulle par défaut")
        XCTAssertTrue(exemple.valide,                            "Valide par défaut")
        XCTAssertEqual(groupe.leNom    , "Pinochio",             "Nom par défaut du premier groupe de test, toujours présent")
        }
    
  
    func testSauvegardeContexteApresAjout() {
        Groupe.creer(contexte: contexteDeTest!, titre: "UN TITRE DE TEST", collaboratif: true)

        expectation(
            forNotification: .NSManagedObjectContextDidSave, //.NSPersistentStoreRemoteChange,
            object: contexteDeTest!) { notification in
                return true
                }
        
        contexteDeTest!.perform {
            Groupe.creer(contexte: self.contexteDeTest!, titre: "UN TITRE DE TEST", collaboratif: true)
            }

        waitForExpectations(timeout: 2.0) { erreur in
            XCTAssertNil(erreur, "Pas vu passer la notification de changement")
            }
        }
    
    func testCréationPrincipalEtSauvegardeContexte() {
        //FIXME: Pourquoi il faut aussi en plus du `contexteDeTest!.perform` cette ligne ?
        Groupe.creer(contexte: contexteDeTest!) //, titre: "UN TITRE DE TEST") //, collaboratif: true)
        do { try contexteDeTest!.save()} catch {}
        // On s'attend à voir circuler une notification de sauvegarde du contexte
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: contexteDeTest!) { notification in
//                print("Notification", notification.userInfo?.keys,"pour test")
                return true
                }

        contexteDeTest!.perform {
            // Création d'un Groupe CoreData au sein du contexte de test
            let groupe = Groupe.creer(contexte: self.contexteDeTest!)
            XCTAssertNotNil(groupe,                            "Le groupe est créé")
            XCTAssertNotNil(groupe.principal,                  "Son item principal est créé")
            XCTAssertEqual( groupe.principal?.valeur,  0,      "La valeur initiale de son item principal est nulle")
            XCTAssertEqual( groupe.principal?.titre , "⚡︎⚡︎⚡︎_0", "Titre par défaut, de l'item principal")
            }

        waitForExpectations(timeout: 2.0) { erreur in
            XCTAssertNil(erreur, "Pas vu passer la notification de sauvegarde")
            }
        }



    
    
    //MARK: FetchRequest
    func testRequeteGroupes() {
      let nouveauGroupe = Groupe.creer(contexte: contexteDeTest!)
      let desGroupes    = Groupe.obtenirGroupes(contexte: contexteDeTest!)

      XCTAssertNotNil(desGroupes)
      XCTAssertEqual(desGroupes?.count , 1)
      XCTAssertEqual(nouveauGroupe.id , desGroupes?.first?.id)
    }

    func testRequeteGroupesCollaboratifs() {
      let nouveauGroupe = Groupe.creer(contexte: contexteDeTest!, collaboratif: true)
      let desGroupes    = Groupe.extractionCollaboratifs // NSFetchRequest<Groupe>
      let groupes:[Groupe]?
      do {
          groupes = try self.contexteDeTest?.fetch(desGroupes)
          XCTAssertNotNil(groupes)
          XCTAssertEqual(groupes?.count , 1)
          XCTAssertEqual(nouveauGroupe.id , groupes?.first?.id)
      }
      catch {print("!!!!! pour test")} //XCTFail()}
    }
    
    func testSuppressionGroupe() {
      let unGroupe   = Groupe.creer(contexte: contexteDeTest!)
      var desGroupes = Groupe.obtenirGroupes(contexte: contexteDeTest!)
        
      XCTAssertEqual(desGroupes?.count , 1)
      XCTAssertEqual(unGroupe.id , desGroupes?.first?.id)

      Groupe.supprimer(contexte: contexteDeTest!, unGroupe)

      desGroupes = Groupe.obtenirGroupes(contexte: contexteDeTest!)

      XCTAssertTrue(desGroupes?.isEmpty ?? false)
    }
    
}
