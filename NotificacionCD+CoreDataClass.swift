//
//  NotificacionCD+CoreDataClass.swift
//  SmallFriends
//
//  Created by DAMII on 4/05/25.
//
//  Este archivo define la clase `NotificacionCD`, que representa una notificación en la aplicación SmallFriends.
//  La clase `NotificacionCD` hereda de `NSManagedObject`, lo que significa que es gestionada automáticamente
//  por el sistema de persistencia Core Data, permitiendo que las instancias de `NotificacionCD` se almacenen,
//  recuperen y manipulen en la base de datos de Core Data.
//
//  Este archivo solo contiene la definición de la clase base `NotificacionCD` y no incluye las propiedades ni
//  relaciones, que se encuentran definidas en la extensión `NotificacionCD+CoreDataProperties.swift`.
//  Específicamente, las propiedades relacionadas con la notificación, como el cuerpo, la fecha, el título,
//  y las relaciones con otras entidades (como `CitasCD`), se gestionan en dicha extensión.

import Foundation
import CoreData

/// Clase que representa una notificación en la base de datos de Core Data.
///
/// La clase `NotificacionCD` está diseñada para ser utilizada dentro del sistema de persistencia de Core Data de la aplicación
/// SmallFriends. Cada instancia de `NotificacionCD` representa una notificación que puede estar asociada a una cita o evento
/// relacionado con las mascotas. La notificación incluye detalles como el cuerpo del mensaje, el título, la fecha programada,
/// y el usuario al que está asociada.
public class NotificacionCD: NSManagedObject {
    // Esta clase actúa como el objeto que se mapea a los registros de la tabla de notificaciones en la base de datos de Core Data.
    // Los detalles específicos de las propiedades y relaciones se definen en la extensión `NotificacionCD+CoreDataProperties.swift`.
}
