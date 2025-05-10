//
//  Mascota+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//  Esta extensión define las propiedades y relaciones de la entidad 'Mascota'.
//  Cada propiedad corresponde a un atributo en el modelo de datos de Core Data.
//

import Foundation
import CoreData

extension Mascota {

    /// Método de clase para crear una solicitud de búsqueda (`fetch request`)
    /// para la entidad 'Mascota'.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mascota> {
        return NSFetchRequest<Mascota>(entityName: "Mascota")
    }

    /// Edad de la mascota.
    @NSManaged public var edad: Int16

    /// Nombre de la mascota (opcional).
    @NSManaged public var nombre: String?

    /// Tipo de animal (por ejemplo, perro, gato, etc.) (opcional).
    @NSManaged public var tipo: String?

    /// Descripción general de la mascota (opcional).
    @NSManaged public var descripcion: String?

    /// Peso de la mascota (opcional), representado como número decimal.
    @NSManaged public var peso: NSDecimalNumber?

    /// Documento de identidad del dueño asociado (opcional).
    @NSManaged public var dni: String?

    /// Estado de la mascota (por ejemplo, activo, inactivo, adoptado) (opcional).
    @NSManaged public var estado: String?

    /// Identificador del usuario dueño de la mascota (opcional).
    @NSManaged public var idUsuario: String?

    /// Raza de la mascota (opcional).
    @NSManaged public var raza: String?

    /// Foto de la mascota almacenada como datos binarios (opcional).
    @NSManaged public var foto: Data?

    /// Relación con la entidad 'Usuario' (usuario dueño de la mascota).
    @NSManaged public var usuario: Usuario?

    /// Estado específico de la mascota (puede usarse para estados personalizados) (opcional).
    @NSManaged public var estadoMascota: String?

    /// Relación con citas asociadas a la mascota.
    @NSManaged public var citas: NSSet?

    /// Identificador único adicional para la mascota (opcional).
    @NSManaged public var id: String?

}

// MARK: - Métodos generados para gestionar la relación 'citas'
extension Mascota {

    /// Agrega una cita a la mascota.
    @objc(addCitasObject:)
    @NSManaged public func addToCitas(_ value: CitasCD)

    /// Elimina una cita específica de la mascota.
    @objc(removeCitasObject:)
    @NSManaged public func removeFromCitas(_ value: CitasCD)

    /// Agrega un conjunto de citas a la mascota.
    @objc(addCitas:)
    @NSManaged public func addToCitas(_ values: NSSet)

    /// Elimina un conjunto de citas de la mascota.
    @objc(removeCitas:)
    @NSManaged public func removeFromCitas(_ values: NSSet)
}

extension Mascota : Identifiable {
    // Conforma al protocolo Identifiable para compatibilidad con SwiftUI y otras APIs de Apple.
}
