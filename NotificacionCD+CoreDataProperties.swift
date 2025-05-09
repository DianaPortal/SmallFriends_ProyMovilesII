//
//  NotificacionCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 4/05/25.
//
//  Este archivo contiene la extensión de la clase `NotificacionCD`, donde se definen las propiedades
//  de la entidad `NotificacionCD` y sus relaciones con otras entidades en la base de datos de Core Data.
//  La clase `NotificacionCD` es una subclase de `NSManagedObject`, lo que le permite ser gestionada
//  por el sistema de persistencia Core Data en la aplicación SmallFriends.
//
//  Este archivo extiende la clase `NotificacionCD` para definir los atributos que representan los detalles
//  de una notificación, así como la relación con la entidad `CitasCD`, lo que permite que las notificaciones
//  sean almacenadas, recuperadas y manipuladas dentro de la base de datos de Core Data.

import Foundation
import CoreData

/// Extensión de la clase `NotificacionCD` para definir las propiedades de la entidad `NotificacionCD` y sus relaciones.
extension NotificacionCD {

    /// Retorna una solicitud de búsqueda para la entidad `NotificacionCD` en Core Data.
    ///
    /// - Returns: `NSFetchRequest<NotificacionCD>`, que se puede utilizar para realizar consultas de notificaciones
    /// en la base de datos.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificacionCD> {
        return NSFetchRequest<NotificacionCD>(entityName: "NotificacionCD")
    }

    // MARK: - Atributos de la notificación
    
    /// Cuerpo o contenido de la notificación (por ejemplo, el mensaje o información que se desea comunicar).
    @NSManaged public var cuerpo: String?
    
    /// Fecha y hora programada para la notificación.
    @NSManaged public var fechaProgramada: Date?
    
    /// Identificador único de la notificación.
    @NSManaged public var idNotificacion: String?
    
    /// Identificador del usuario asociado a la notificación.
    @NSManaged public var idUsuario: String?
    
    /// Título o encabezado de la notificación (puede ser algo como "Recordatorio de cita").
    @NSManaged public var titulo: String?
    
    /// Relación con la entidad `CitasCD`, indicando la cita relacionada con la notificación.
    @NSManaged public var cita: CitasCD?
}

// MARK: - Protocolo `Identifiable`
/// La clase `NotificacionCD` adopta el protocolo `Identifiable`, lo que permite identificar de manera única
/// cada instancia de `NotificacionCD`. Esto generalmente se realiza usando la propiedad `idNotificacion`.
extension NotificacionCD : Identifiable {
}
