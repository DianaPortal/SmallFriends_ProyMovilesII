//
//  CitasCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//
//  Este archivo contiene la extensión de la clase `CitasCD`, donde se definen las propiedades
//  de la entidad `CitasCD` y sus relaciones con otras entidades en la base de datos de Core Data.
//  La clase `CitasCD` es una subclase de `NSManagedObject`, lo que le permite ser gestionada
//  por el sistema de persistencia Core Data en la aplicación SmallFriends.
//
//  Este archivo extiende la clase `CitasCD` para definir los atributos que representan los detalles
//  de una cita y las relaciones con las entidades `Mascota`, `Usuario` y `NotificacionCD`,
//  permitiendo que las citas sean almacenadas, recuperadas y manipuladas dentro de la base de datos de Core Data.

import Foundation
import CoreData

/// Extensión de la clase `CitasCD` para definir las propiedades de la entidad `CitasCD` y sus relaciones.
extension CitasCD {

    /// Retorna una solicitud de búsqueda para la entidad `CitasCD` en Core Data.
    ///
    /// - Returns: `NSFetchRequest<CitasCD>`, que se puede utilizar para realizar consultas de citas
    /// en la base de datos.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CitasCD> {
        return NSFetchRequest<CitasCD>(entityName: "CitasCD")
    }

    // MARK: - Atributos de la cita
    
    /// Descripción de la cita (por ejemplo, el propósito de la cita o notas adicionales).
    @NSManaged public var descripcionCita: String?
    
    /// Fecha y hora de la cita.
    @NSManaged public var fechaCita: Date?
    
    /// Identificador único de la cita.
    @NSManaged public var idCita: Int16
    
    /// Lugar donde se llevará a cabo la cita (por ejemplo, clínica, parque, etc.).
    @NSManaged public var lugarCita: String?
    
    /// Tipo de cita (por ejemplo, "consulta", "vacunación", "revisión").
    @NSManaged public var tipoCita: String?
    
    /// Relación con la entidad `Mascota`, indicando la mascota asociada con la cita.
    @NSManaged public var mascota: Mascota?
    
    /// Estado de la cita (por ejemplo, "confirmada", "pendiente", "cancelada").
    @NSManaged public var estadoCita: String?
    
    /// Relación con la entidad `Usuario`, indicando el usuario que ha creado o está asociado con la cita.
    @NSManaged public var usuario: Usuario?
    
    /// Relación con la entidad `NotificacionCD`, indicando las notificaciones relacionadas con la cita.
    @NSManaged public var notificaciones: NotificacionCD?
    
    /// Identificador único de la cita en formato de cadena.
    @NSManaged public var id: String?
}

// MARK: - Protocolo `Identifiable`
/// La clase `CitasCD` adopta el protocolo `Identifiable`, lo que permite identificar de manera única
/// cada instancia de `CitasCD`. Generalmente, esto se usa con la propiedad `id` para asignar
/// un identificador único a la cita.
extension CitasCD : Identifiable {
}
