//
//  Usuario+CoreDataProperties.swift
//  SmallFriends
//
//  Created by Diana on 28/04/25.
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
    @NSManaged public var nombre: String?
    @NSManaged public var apellidos: String?
    @NSManaged public var mascota: NSSet?

}

// MARK: Generated accessors for mascota
extension Usuario {

    @objc(addMascotaObject:)
    @NSManaged public func addToMascota(_ value: Mascota)

    @objc(removeMascotaObject:)
    @NSManaged public func removeFromMascota(_ value: Mascota)

    @objc(addMascota:)
    @NSManaged public func addToMascota(_ values: NSSet)

    @objc(removeMascota:)
    @NSManaged public func removeFromMascota(_ values: NSSet)
}


extension Usuario : Identifiable {

}
