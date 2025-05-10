//
//  CitasCD+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//
//  Esta extensión define las propiedades y relaciones de la entidad 'CitasCD'.
//  Estas propiedades están mapeadas al modelo de datos de Core Data y permiten
//  acceder y modificar los valores almacenados para cada instancia de cita.
//

import Foundation
import CoreData

extension CitasCD {

    /// Método de clase para crear una solicitud de búsqueda (`fetch request`)
    /// para la entidad 'CitasCD'.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CitasCD> {
        return NSFetchRequest<CitasCD>(entityName: "CitasCD")
    }

    /// Descripción de la cita (opcional).
    @NSManaged public var descripcionCita: String?

    /// Fecha programada para la cita (opcional).
    @NSManaged public var fechaCita: Date?

    /// Identificador numérico de la cita.
    @NSManaged public var idCita: Int16

    /// Lugar donde se llevará a cabo la cita (opcional).
    @NSManaged public var lugarCita: String?

    /// Tipo de cita (por ejemplo, consulta, vacunación, etc.) (opcional).
    @NSManaged public var tipoCita: String?

    /// Relación con la entidad 'Mascota' (una cita está asociada a una mascota).
    @NSManaged public var mascota: Mascota?

    /// Estado actual de la cita (por ejemplo, pendiente, confirmada, cancelada) (opcional).
    @NSManaged public var estadoCita: String?

    /// Relación con la entidad 'Usuario' (usuario que creó o asistirá a la cita).
    @NSManaged public var usuario: Usuario?

    /// Relación con la entidad 'NotificacionCD' (una cita puede tener una notificación asociada).
    @NSManaged public var notificaciones: NotificacionCD?

    /// Identificador único adicional en formato `String` (opcional).
    @NSManaged public var id: String?

}

extension CitasCD : Identifiable {
    // Esta extensión permite que CitasCD cumpla con el protocolo Identifiable,
    // útil para su uso en SwiftUI o listas identificables.
}
