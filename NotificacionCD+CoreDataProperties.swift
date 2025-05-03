//
//  NotificacionCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//
//

import Foundation
import CoreData


extension NotificacionCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificacionCD> {
        return NSFetchRequest<NotificacionCD>(entityName: "NotificacionCD")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var titulo: String?
    @NSManaged public var cuerpo: String?
    @NSManaged public var fechaProgramada: Date?
    @NSManaged public var idUsuario: String?
    @NSManaged public var cita: CitasCD?

}

extension NotificacionCD : Identifiable {

}
