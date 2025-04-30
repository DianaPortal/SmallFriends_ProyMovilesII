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

}

extension Mascota : Identifiable {

}
