//
//  Usuario+CoreDataProperties.swift
//  SmallFriends
//
//  Created by Diana on 28/04/25.
//
//  Este archivo contiene la extensión de la clase `Usuario`, donde se definen las propiedades
//  de la entidad `Usuario` y las relaciones con otras entidades, específicamente con la entidad
//  `Mascota`, que está gestionada por Core Data en la aplicación SmallFriends.
//
//  La clase `Usuario` es una subclase de `NSManagedObject`, lo que permite que la entidad
//  `Usuario` se maneje en el contexto de Core Data, permitiendo la persistencia de los datos.
//
//  Este archivo extiende la clase `Usuario` agregando las propiedades, los métodos para acceder
//  a la base de datos, y las funciones para gestionar las relaciones entre usuarios y sus mascotas.

import Foundation
import CoreData

/// Extensión de la clase `Usuario` para definir las propiedades y funciones que interactúan con Core Data.
extension Usuario {

    /// Retorna una solicitud de búsqueda para la entidad `Usuario` en Core Data.
    ///
    /// - Returns: `NSFetchRequest<Usuario>`, que se puede utilizar para realizar consultas de usuarios en la base de datos.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        return NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    // MARK: - Atributos del usuario
    
    /// Dirección de correo electrónico del usuario.
    @NSManaged public var email: String?
    
    /// Identificador único del usuario en el sistema.
    @NSManaged public var idUsuario: String?
    
    /// Proveedor de autenticación (por ejemplo, Google, Facebook, etc.).
    @NSManaged public var provider: String?
    
    /// Nombre del usuario.
    @NSManaged public var nombre: String?
    
    /// Apellidos del usuario.
    @NSManaged public var apellidos: String?
    
    /// Relación de uno a muchos con la entidad `Mascota`, que indica las mascotas asociadas al usuario.
    @NSManaged public var mascota: NSSet?
}

// MARK: - Métodos generados para gestionar la relación con `Mascota`
/// Extensión que define los métodos de acceso a la relación entre `Usuario` y `Mascota`.
/// Estas funciones permiten agregar o eliminar mascotas de la colección asociada a un usuario.
extension Usuario {

    /// Añade una mascota a la relación `mascota`.
    ///
    /// - Parameter value: El objeto `Mascota` que se desea agregar a la colección.
    @objc(addMascotaObject:)
    @NSManaged public func addToMascota(_ value: Mascota)

    /// Elimina una mascota de la relación `mascota`.
    ///
    /// - Parameter value: El objeto `Mascota` que se desea eliminar de la colección.
    @objc(removeMascotaObject:)
    @NSManaged public func removeFromMascota(_ value: Mascota)

    /// Añade múltiples mascotas a la relación `mascota`.
    ///
    /// - Parameter values: Un conjunto de objetos `Mascota` que se desea agregar.
    @objc(addMascota:)
    @NSManaged public func addToMascota(_ values: NSSet)

    /// Elimina múltiples mascotas de la relación `mascota`.
    ///
    /// - Parameter values: Un conjunto de objetos `Mascota` que se desea eliminar de la colección.
    @objc(removeMascota:)
    @NSManaged public func removeFromMascota(_ values: NSSet)
}

// MARK: - Protocolo `Identifiable`
/// La clase `Usuario` adopta el protocolo `Identifiable`, lo que permite identificar de manera única
/// a cada instancia de `Usuario`. Generalmente, esto se usa con la propiedad `idUsuario` para asignar
/// un identificador único al objeto.
extension Usuario : Identifiable {
}
