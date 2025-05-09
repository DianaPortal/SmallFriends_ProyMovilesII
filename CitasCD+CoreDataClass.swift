//
//  CitasCD+CoreDataClass.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//
//  Este archivo define la clase `CitasCD`, que representa una cita en la aplicación SmallFriends.
//  La clase `CitasCD` hereda de `NSManagedObject`, lo que significa que se maneja automáticamente
//  a través del sistema de persistencia Core Data, permitiendo almacenar, recuperar y gestionar
//  las citas en la base de datos de la aplicación.
//
//  La clase `CitasCD` no contiene directamente las propiedades ni las relaciones de la entidad,
//  ya que estos están definidos en la extensión `CitasCD+CoreDataProperties.swift`.
//  Aquí solo se define la clase base para la entidad `CitasCD`, que se utiliza por Core Data
//  para mapear los objetos de la base de datos a objetos Swift.

import Foundation
import CoreData

/// Clase que representa una cita en la base de datos de Core Data.
public class CitasCD: NSManagedObject {
    // Esta clase hereda de `NSManagedObject`, lo que significa que Core Data maneja automáticamente
    // el ciclo de vida de las instancias de `CitasCD`. Las propiedades y relaciones de la cita, como
    // la descripción, fecha, lugar, tipo, estado y las relaciones con otras entidades (como `Mascota`,
    // `Usuario` y `NotificacionCD`), se definen en la extensión en `CitasCD+CoreDataProperties.swift`.
    //
    // No es necesario agregar código adicional aquí, ya que la implementación completa de la entidad
    // `CitasCD` está gestionada por Core Data.
}
