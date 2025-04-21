//
//  Citas+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//

import Foundation
import CoreData


extension Citas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Citas> {
        return NSFetchRequest<Citas>(entityName: "Citas")
    }

    @NSManaged public var idCita: Int16
    @NSManaged public var fechaCita: Date?
    @NSManaged public var tipoCita: String?
    @NSManaged public var lugarCita: String?
    @NSManaged public var doctor: String?
    @NSManaged public var estado: Int16

}

extension Citas : Identifiable {

}
