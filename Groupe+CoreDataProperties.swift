//Arachante
// michel  le 22/03/2022
// pour le projet  ConteneurCloudKit
// Swift  5.0  sur macOS  12.3
//
//  2022
//
//

import Foundation
import CoreData


extension Groupe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Groupe> {
        return NSFetchRequest<Groupe>(entityName: "Groupe")
    }

    @NSManaged public var collaboratif: Bool
    @NSManaged public var createur: String?
    @NSManaged public var id: UUID?
    @NSManaged public var integration: Bool
    @NSManaged public var nom: String?
    @NSManaged public var nombre: Int64
    @NSManaged public var ordre: Int64
    @NSManaged public var valide: Bool
    @NSManaged public var objectif: String?
    @NSManaged public var icone: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var principal: Item?

}

// MARK: Generated accessors for items
extension Groupe {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension Groupe : Identifiable {

}
