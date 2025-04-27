//
//  Usuario+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//
//

import Foundation
import CoreData


extension Usuario {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        return NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    @NSManaged public var email: String?
    @NSManaged public var idUsuario: String?
    @NSManaged public var provider: String?
    @NSManaged public var citas: NSSet?

}

// MARK: Generated accessors for citas
extension Usuario {

    @objc(addCitasObject:)
    @NSManaged public func addToCitas(_ value: CitasCD)

    @objc(removeCitasObject:)
    @NSManaged public func removeFromCitas(_ value: CitasCD)

    @objc(addCitas:)
    @NSManaged public func addToCitas(_ values: NSSet)

    @objc(removeCitas:)
    @NSManaged public func removeFromCitas(_ values: NSSet)

}

extension Usuario : Identifiable {

}
