//Arachante
// michel  le 22/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import Foundation
import CoreData
import os.log
import ConteneurCloudKit

class _CoreDataDeTest:ControleurPersistance {
    var bloup = "BLOUP"
    var desTrucs = [String]()

    //override
    init() {
      super.init()
        
    let descriptionMagasinPersistant = NSPersistentStoreDescription()
    descriptionMagasinPersistant.type = NSInMemoryStoreType
    
    let modele: NSManagedObjectModel = {
          let urlModele = Bundle.main.url(forResource: "ConteneurCloudKit", withExtension: "momd")!
          return NSManagedObjectModel(contentsOf: urlModele)!
        }()
        
    let conteneurdeTest = NSPersistentContainer(
          name: "ConteneurCloudKit" , //ControleurPersistance.modelName,
          managedObjectModel: modele)
        
    conteneurdeTest.persistentStoreDescriptions = [descriptionMagasinPersistant]
        
//    conteneurdeTest.loadPersistentStores { storeDescription , error in
////          if let error = error as NSError? {
//////            fatalError("Unresolved error \(error), \(error.userInfo)")
////          }
//        }

//    var controleurPersistanceDeTest = controleurDePersistance
//    var controleurPersistanceDeTest = ControleurPersistance.shared
        let controleurPersistanceDeTest = ControleurPersistance(inMemory: true)

    let contextDeTest = controleurPersistanceDeTest.conteneur.viewContext
    let contexteDeTest = NSManagedObjectContext(.mainQueue)

      
//    conteneur = conteneurdeTest

        
    }
}
