//
//  CoreDataManager.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "SmallFriends")
        persistentContainer.loadPersistentStores {_, error in
            if let error = error {
                fatalError("Error al cargar Core Data: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
            return persistentContainer.viewContext
        }

        func saveContext() {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error al guardar: \(error)")
                }
            }
        }
    
    // LISTAR MASCOTAS REGISTRADAS
    func fetchMascotas() -> [Mascota] {
            let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                print("Error al obtener mascotas: \(error)")
                return []
            }
        }
    
    // LISTAR MASCOTAS REGISTRADAS POR USUARIO LOGUEADO
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
    
    // LISTAR MASCOTAS REGISTRADAS POR USUARIO LOGUEADO
    func fetchCitasDelUsuario(_ usuario: Usuario) -> [CitasCD] {
        let request: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "usuario == %@", usuario),
                NSPredicate(format: "estadoCita != %@", "Cancelada")
            ])

        do {
            return try CoreDataManager.shared.context.fetch(request)
        } catch {
            print("Error al obtener mascotas del usuario: \(error)")
            return []
        }
    }
    
    func deleteMascota(_ mascota: Mascota) {
            context.delete(mascota)
            saveContext()
        }
}
