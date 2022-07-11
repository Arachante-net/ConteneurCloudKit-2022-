//Arachante
// michel  le 02/03/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.2
//
//  2022
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var caracteristique: String?
    @NSManaged public var couleur: Data?
    @NSManaged public var createur: String?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var modeBin: String?
    @NSManaged public var ordre: Int64
    @NSManaged public var timestamp: Date?
    @NSManaged public var titre: String?
    @NSManaged public var valeur: Int64
    @NSManaged public var valide: Bool
//    @NSManaged public var nuageux: Bool
    @NSManaged public var message: String?
    @NSManaged public var integration: Bool
    @NSManaged public var groupes: NSSet?
    @NSManaged public var principal: Groupe?

}

// MARK: Generated accessors for groupes
extension Item {

    @objc(addGroupesObject:)
    @NSManaged public func addToGroupes(_ value: Groupe)

    @objc(removeGroupesObject:)
    @NSManaged public func removeFromGroupes(_ value: Groupe)

    @objc(addGroupes:)
    @NSManaged public func addToGroupes(_ values: NSSet)

    @objc(removeGroupes:)
    @NSManaged public func removeFromGroupes(_ values: NSSet)

}

extension Item : Identifiable {

}
