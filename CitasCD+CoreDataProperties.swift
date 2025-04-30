//
//  CitasCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//
//

import Foundation
import CoreData


extension CitasCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CitasCD> {
        return NSFetchRequest<CitasCD>(entityName: "CitasCD")
    }

    @NSManaged public var descripcionCita: String?
    @NSManaged public var fechaCita: Date?
    @NSManaged public var idCita: Int16
    @NSManaged public var lugarCita: String?
    @NSManaged public var tipoCita: String?
    @NSManaged public var usuario: Usuario?
    @NSManaged public var estadoCita: String?

}

extension CitasCD : Identifiable {

}
