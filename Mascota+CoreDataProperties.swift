//
//  Mascota+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//  Este archivo contiene la extensión de la clase `Mascota`, donde se definen las propiedades
//  de la entidad `Mascota` y las relaciones con otras entidades en la base de datos de Core Data.
//  La clase `Mascota` es una subclase de `NSManagedObject`, lo que le permite ser gestionada
//  por el sistema de persistencia Core Data en la aplicación SmallFriends.
//
//  En este archivo se definen las propiedades que corresponden a los atributos de la entidad
//  `Mascota` y las funciones para gestionar las relaciones de `Mascota` con otras entidades,
//  como la relación con `Usuario` y las citas asociadas a la mascota.

import Foundation
import CoreData

/// Extensión de la clase `Mascota` para definir las propiedades de la entidad `Mascota` y sus relaciones.
extension Mascota {

    /// Retorna una solicitud de búsqueda para la entidad `Mascota` en Core Data.
    ///
    /// - Returns: `NSFetchRequest<Mascota>`, que se puede utilizar para realizar consultas de mascotas
    /// en la base de datos.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mascota> {
        return NSFetchRequest<Mascota>(entityName: "Mascota")
    }

    // MARK: - Atributos de la mascota
    
    /// Edad de la mascota.
    @NSManaged public var edad: Int16
    
    /// Nombre de la mascota.
    @NSManaged public var nombre: String?
    
    /// Tipo de la mascota (por ejemplo, "perro", "gato").
    @NSManaged public var tipo: String?
    
    /// Descripción de la mascota (puede ser una breve biografía o información adicional).
    @NSManaged public var descripcion: String?
    
    /// Peso de la mascota.
    @NSManaged public var peso: NSDecimalNumber?
    
    /// DNI (identificador) único de la mascota.
    @NSManaged public var dni: String?
    
    /// Estado actual de la mascota (por ejemplo, "saludable", "en tratamiento").
    @NSManaged public var estado: String?
    
    /// Identificador único del usuario asociado a la mascota (relación con la entidad `Usuario`).
    @NSManaged public var idUsuario: String?
    
    /// Raza de la mascota.
    @NSManaged public var raza: String?
    
    /// Foto de la mascota en formato de datos binarios.
    @NSManaged public var foto: Data?
    
    /// Relación con la entidad `Usuario`, indica el propietario de la mascota.
    @NSManaged public var usuario: Usuario?
    
    /// Estado de la mascota, que podría indicar si está en adopción, en tratamiento, etc.
    @NSManaged public var estadoMascota: String?
    
    /// Relación con la entidad `CitasCD`, que almacena las citas asociadas a la mascota.
    @NSManaged public var citas: NSSet?
    
    /// Identificador único de la mascota.
    @NSManaged public var id: String?
}

// MARK: - Métodos generados para gestionar la relación con `CitasCD`
/// Extensión que define los métodos de acceso a la relación entre `Mascota` y `CitasCD`.
/// Estas funciones permiten agregar o eliminar citas de la colección asociada a una mascota.
extension Mascota {
    
    /// Añade una cita a la relación `citas`.
    ///
    /// - Parameter value: El objeto `CitasCD` que se desea agregar a la colección de citas.
    @objc(addCitasObject:)
    @NSManaged public func addToCitas(_ value: CitasCD)

    /// Elimina una cita de la relación `citas`.
    ///
    /// - Parameter value: El objeto `CitasCD` que se desea eliminar de la colección de citas.
    @objc(removeCitasObject:)
    @NSManaged public func removeFromCitas(_ value: CitasCD)

    /// Añade múltiples citas a la relación `citas`.
    ///
    /// - Parameter values: Un conjunto de objetos `CitasCD` que se desea agregar a la colección de citas.
    @objc(addCitas:)
    @NSManaged public func addToCitas(_ values: NSSet)

    /// Elimina múltiples citas de la relación `citas`.
    ///
    /// - Parameter values: Un conjunto de objetos `CitasCD` que se desea eliminar de la colección de citas.
    @objc(removeCitas:)
    @NSManaged public func removeFromCitas(_ values: NSSet)
}

/// Extensión para adoptar el protocolo `Identifiable`.
/// Esto permite identificar de manera única a cada instancia de `Mascota`.
extension Mascota : Identifiable {
}
