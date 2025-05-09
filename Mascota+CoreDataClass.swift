//
//  Mascota+CoreDataClass.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//  Esta clase define el modelo `Mascota`, que representa a una mascota en la aplicación SmallFriends.
//  La clase `Mascota` hereda de `NSManagedObject`, lo que significa que es una clase gestionada por
//  Core Data, el sistema de persistencia de datos utilizado en iOS y macOS.
//
//  La clase `Mascota` está diseñada para almacenar la información relacionada con una mascota,
//  como sus atributos, su relación con el dueño (usuario) y otras entidades relacionadas,
//  como las citas. La persistencia y recuperación de estos datos se maneja automáticamente
//  a través de Core Data.
//
//  Este archivo contiene la definición básica de la clase `Mascota` sin atributos ni funciones,
//  que están definidos en la extensión `Mascota+CoreDataProperties.swift`.

import Foundation
import CoreData

/// Clase que representa a una mascota dentro del contexto de Core Data.
public class Mascota: NSManagedObject {
    // Esta clase se extiende en `Mascota+CoreDataProperties.swift`, donde se definen los atributos y las relaciones
    // de la entidad `Mascota`, como su nombre, edad, tipo, etc., junto con las funciones de acceso y manipulación
    // de estas propiedades.
    
    // En esta clase base (Mascota), no es necesario agregar atributos o funciones directamente,
    // ya que todos son gestionados en la extensión que se encuentra en `Mascota+CoreDataProperties.swift`.
}
