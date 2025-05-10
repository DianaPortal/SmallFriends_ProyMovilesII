//  CoreDataManager.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import CoreData
import UIKit

// Clase singleton encargada de gestionar las operaciones de CoreData
class CoreDataManager {
    
    // Instancia única de CoreDataManager
    static let shared = CoreDataManager()
    
    // Contenedor persistente para gestionar el acceso a los datos
    let persistentContainer: NSPersistentContainer
    
    // Inicializador privado para garantizar el patrón Singleton
    private init() {
        // Inicialización del contenedor persistente con el nombre del modelo de datos
        persistentContainer = NSPersistentContainer(name: "SmallFriends")
        
        // Carga de los stores persistentes de Core Data
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                // Si hay un error en la carga, se genera una fatalError
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
        
        // Establecer la política de fusión para manejar los conflictos de datos
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    // Propiedad computada que proporciona el contexto de vista de Core Data
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Función para guardar los cambios en el contexto
    func saveContext() {
        let context = self.context
            
        // Establecer la política de fusión justo antes de guardar
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        // Verificar si hay cambios en el contexto antes de guardar
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Si ocurre un error al guardar, se imprime en consola
                print("Error al guardar: \(error)")
            }
        }
    }
    
    // Función para listar todas las mascotas registradas en el sistema
    func fetchMascotas() -> [Mascota] {
        let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        do {
            // Intentar obtener todas las mascotas desde Core Data
            return try context.fetch(request)
        } catch {
            // Si ocurre un error, se imprime en consola y se devuelve una lista vacía
            print("Error al obtener mascotas: \(error)")
            return []
        }
    }
    
    // Función para listar las mascotas registradas por el usuario logueado
    func fetchMascotasDelUsuario(_ usuario: Usuario) -> [Mascota] {
        let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        
        // Filtro para obtener mascotas asociadas al usuario y que no estén inactivas
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "usuario == %@", usuario),
            NSPredicate(format: "estadoMascota != %@", "Inactiva")
        ])
        
        do {
            // Intentar obtener las mascotas asociadas al usuario desde Core Data
            return try CoreDataManager.shared.context.fetch(request)
        } catch {
            // Si ocurre un error, se imprime en consola y se devuelve una lista vacía
            print("Error al obtener mascotas del usuario: \(error)")
            return []
        }
    }
    
    // Función para listar las citas asociadas al usuario logueado
    func fetchCitasDelUsuario(_ usuario: Usuario) -> [CitasCD] {
        let request: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
        
        // Filtro para obtener citas asociadas al usuario y que no estén canceladas
        request.predicate = NSPredicate(format: "usuario == %@ AND estadoCita != %@", usuario, "Cancelada")
        
        do {
            // Obtener todas las citas y ordenarlas por fecha (más recientes primero)
            let citas = try context.fetch(request)
            return citas.sorted(by: { ($0.fechaCita ?? Date()) > ($1.fechaCita ?? Date()) })
        } catch {
            // Si ocurre un error, se imprime en consola y se devuelve una lista vacía
            print("Error al obtener las citas del usuario: \(error)")
            return []
        }
    }
    
    // Función para eliminar una mascota
    func deleteMascota(_ mascota: Mascota) {
        // Eliminar la mascota del contexto
        context.delete(mascota)
        
        // Guardar los cambios realizados en el contexto
        saveContext()
    }
}
