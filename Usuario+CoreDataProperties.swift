//
//  Usuario+CoreDataProperties.swift
//  SmallFriends
//
//  Created by Diana on 28/04/25.
//
//  Esta extensión define las propiedades y relaciones de la entidad 'Usuario'.
//  Representa a los usuarios del sistema en el modelo de datos de Core Data.
//

import Foundation
import CoreData

extension Usuario {

    /// Método de clase que crea una solicitud de búsqueda (`fetch request`)
    /// para recuperar objetos de tipo 'Usuario' desde Core Data.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        return NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    /// Dirección de correo electrónico del usuario (opcional).
    @NSManaged public var email: String?

    /// Identificador único del usuario (opcional).
    @NSManaged public var idUsuario: String?

    /// Proveedor de autenticación (por ejemplo, email, Google, Apple) (opcional).
    @NSManaged public var provider: String?

    /// Nombre del usuario (opcional).
    @NSManaged public var nombre: String?

    /// Apellidos del usuario (opcional).
    @NSManaged public var apellidos: String?

    /// Relación con las mascotas asociadas a este usuario.
    @NSManaged public var mascota: NSSet?
}

// MARK: - Métodos generados para gestionar la relación 'mascota'
extension Usuario {

    /// Agrega una mascota al conjunto de mascotas del usuario.
    @objc(addMascotaObject:)
    @NSManaged public func addToMascota(_ value: Mascota)

    /// Elimina una mascota específica del conjunto del usuario.
    @objc(removeMascotaObject:)
    @NSManaged public func removeFromMascota(_ value: Mascota)

    /// Agrega varias mascotas al conjunto del usuario.
    @objc(addMascota:)
    @NSManaged public func addToMascota(_ values: NSSet)

    /// Elimina varias mascotas del conjunto del usuario.
    @objc(removeMascota:)
    @NSManaged public func removeFromMascota(_ values: NSSet)
}

extension Usuario : Identifiable {
    // Conforma al protocolo Identifiable para facilitar su uso en vistas que requieren identificación única.
}
