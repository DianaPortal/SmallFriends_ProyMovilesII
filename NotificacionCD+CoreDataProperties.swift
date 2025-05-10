//
//  NotificacionCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 4/05/25.
//
//  Esta extensión define las propiedades de la entidad 'NotificacionCD'.
//  Representa notificaciones programadas dentro del modelo de datos de Core Data.
//

import Foundation
import CoreData

extension NotificacionCD {

    /// Método de clase que crea una solicitud de búsqueda (`fetch request`)
    /// para recuperar objetos de tipo 'NotificacionCD'.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificacionCD> {
        return NSFetchRequest<NotificacionCD>(entityName: "NotificacionCD")
    }

    /// Cuerpo o contenido del mensaje de la notificación (opcional).
    @NSManaged public var cuerpo: String?

    /// Fecha y hora programada para que se dispare la notificación (opcional).
    @NSManaged public var fechaProgramada: Date?

    /// Identificador único de la notificación (opcional).
    @NSManaged public var idNotificacion: String?

    /// Identificador del usuario al que está asociada la notificación (opcional).
    @NSManaged public var idUsuario: String?

    /// Título de la notificación (opcional).
    @NSManaged public var titulo: String?

    /// Relación con la entidad 'CitasCD'; una notificación puede estar asociada a una cita.
    @NSManaged public var cita: CitasCD?
}

extension NotificacionCD : Identifiable {
    // Conforma al protocolo Identifiable, útil para trabajar con listas en SwiftUI u otras vistas.
}
