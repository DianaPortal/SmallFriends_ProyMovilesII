//
//  NotificacionCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 4/05/25.
//
//

import Foundation
import CoreData


extension NotificacionCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificacionCD> {
        return NSFetchRequest<NotificacionCD>(entityName: "NotificacionCD")
    }

    @NSManaged public var cuerpo: String?
    @NSManaged public var fechaProgramada: Date?
    @NSManaged public var idNotificacion: String?
    @NSManaged public var idUsuario: String?
    @NSManaged public var titulo: String?
    @NSManaged public var cita: CitasCD?

}

extension NotificacionCD : Identifiable {

}
