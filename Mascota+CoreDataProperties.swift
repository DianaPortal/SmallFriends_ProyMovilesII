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

    @NSManaged public var nombre: String?
    @NSManaged public var dniMascota: String?
    @NSManaged public var edad: String?
    @NSManaged public var peso: Double
    @NSManaged public var descripcion: String?
    @NSManaged public var estado: Int16
    @NSManaged public var idUsuario: String?
    @NSManaged public var tipoMascota: String?
    @NSManaged public var raza: String?

}

extension Mascota : Identifiable {

}
