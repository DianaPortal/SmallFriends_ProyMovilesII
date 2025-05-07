//
//  Mascota+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//

import Foundation
import CoreData


extension Mascota {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mascota> {
        return NSFetchRequest<Mascota>(entityName: "Mascota")
    }

    @NSManaged public var edad: Int16
    @NSManaged public var nombre: String?
    @NSManaged public var tipo: String?
    @NSManaged public var descripcion: String?
    @NSManaged public var peso: NSDecimalNumber?
    @NSManaged public var dni: String?
    @NSManaged public var estado: String?
    @NSManaged public var idUsuario: String?
    @NSManaged public var raza: String?
    @NSManaged public var foto: Data?
    @NSManaged public var usuario: Usuario?
    @NSManaged public var estadoMascota: String?
    @NSManaged public var citas: NSSet?
    @NSManaged public var id: String?

}

// MARK: Generated accessors for citas
extension Mascota {
    @objc(addCitasObject:)
    @NSManaged public func addToCitas(_ value: CitasCD)

    @objc(removeCitasObject:)
    @NSManaged public func removeFromCitas(_ value: CitasCD)

    @objc(addCitas:)
    @NSManaged public func addToCitas(_ values: NSSet)

    @objc(removeCitas:)
    @NSManaged public func removeFromCitas(_ values: NSSet)
}

extension Mascota : Identifiable {

}
