//
//  CoreDataManager.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//  Esta clase es responsable de la gestión centralizada de Core Data en la aplicación. Proporciona acceso al contenedor persistente
//  de Core Data y facilita la interacción con la base de datos. Es una implementación singleton para garantizar que haya solo
//  una instancia de esta clase en toda la aplicación.

import CoreData
import UIKit

class CoreDataManager {
    
    /// Instancia compartida de `CoreDataManager` (Singleton).
    static let shared = CoreDataManager()
    
    /// Contenedor persistente de Core Data, utilizado para gestionar el almacenamiento de datos.
    let persistentContainer: NSPersistentContainer
    
    /// Inicializa el contenedor persistente de Core Data y carga los almacenes persistentes.
    /// Establece la política de fusión para evitar conflictos entre datos en el contexto.
    private init() {
        persistentContainer = NSPersistentContainer(name: "SmallFriends")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
        
        // Establecer la política de fusión para que las propiedades del almacén prevalezcan en caso de conflicto.
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    /// Contexto de trabajo para interactuar con los objetos gestionados de Core Data.
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Guardado de Datos
    
    /// Guarda los cambios realizados en el contexto de Core Data.
    ///
    /// Si el contexto tiene cambios pendientes, los guarda utilizando el contexto configurado previamente.
    /// Se maneja cualquier error durante el guardado imprimiéndolo en la consola.
    func saveContext() {
        let context = self.context
        
        // Establecer la política de fusión antes de guardar para evitar conflictos entre cambios.
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error al guardar: \(error)")
            }
        }
    }
    
    // MARK: - Métodos de Obtención de Datos
    
    /// Obtiene todas las mascotas registradas en la base de datos.
    ///
    /// - Returns: Un array de objetos `Mascota` obtenidos de la base de datos.
    /// - Si ocurre un error durante la obtención de los datos, se imprime un error en la consola y se retorna un array vacío.
    func fetchMascotas() -> [Mascota] {
        let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error al obtener mascotas: \(error)")
            return []
        }
    }
    
    /// Obtiene las mascotas asociadas a un usuario específico que no estén marcadas como "Inactiva".
    ///
    /// - Parameter usuario: El usuario cuyo conjunto de mascotas se va a obtener.
    /// - Returns: Un array de objetos `Mascota` que pertenecen al usuario y no están inactivas.
    func fetchMascotasDelUsuario(_ usuario: Usuario) -> [Mascota] {
        let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "usuario == %@", usuario),
            NSPredicate(format: "estadoMascota != %@", "Inactiva")
        ])
        
        do {
            return try CoreDataManager.shared.context.fetch(request)
        } catch {
            print("Error al obtener mascotas del usuario: \(error)")
            return []
        }
    }
    
    /// Obtiene las citas asociadas a un usuario específico que no estén canceladas.
    ///
    /// - Parameter usuario: El usuario cuyas citas se van a obtener.
    /// - Returns: Un array de objetos `CitasCD` ordenados por fecha de cita (de más reciente a más antigua).
    func fetchCitasDelUsuario(_ usuario: Usuario) -> [CitasCD] {
        let request: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
        request.predicate = NSPredicate(format: "usuario == %@ AND estadoCita != %@", usuario, "Cancelada")
        
        do {
            let citas = try context.fetch(request)
            return citas.sorted(by: { ($0.fechaCita ?? Date()) > ($1.fechaCita ?? Date()) })
        } catch {
            print("Error al obtener las citas del usuario: \(error)")
            return []
        }
    }
    
    // MARK: - Eliminación de Datos
    
    /// Elimina una mascota de la base de datos.
    ///
    /// - Parameter mascota: La mascota que se va a eliminar.
    func deleteMascota(_ mascota: Mascota) {
        context.delete(mascota)
        saveContext()
    }
}
