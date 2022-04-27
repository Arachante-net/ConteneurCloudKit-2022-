//Arachante
// michel  le 23/04/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//

import CoreData

extension NSManagedObjectContext {
    
    class func versionPourTests() -> NSManagedObjectContext {
        // Accéder au modèle
        let modèle = NSManagedObjectModel.mergedModel(from: Bundle.allBundles)!
//        print("Acquisition du modèle pour test")
        // Créer et configurer un coordinateur
        let coordinateur = NSPersistentStoreCoordinator(managedObjectModel: modèle)
        try! coordinateur.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil)
//        print("Mise en lace d'un coordinateur pour test")

        // Définir le contexte
        let contexte = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        contexte.persistentStoreCoordinator = coordinateur
//        print("Mise en lace d'un contexte pour test")

        return contexte
    }
    
}
