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

    //@NSManaged public var fotoPerfil: Data?
    @NSManaged public var nombre: String?
    @NSManaged public var edad: Int16
    @NSManaged public var tipo: String?
    @NSManaged public var peso: NSDecimalNumber?
    @NSManaged public var raza: String?
    @NSManaged public var dni: String?

}

extension Mascota : Identifiable {

}
