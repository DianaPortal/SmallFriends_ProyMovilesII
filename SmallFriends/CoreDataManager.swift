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
    
    func fetchMascotas() -> [Mascota] {
            let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                print("Error al obtener mascotas: \(error)")
                return []
            }
        }
    
    // LISTAR MASCOTAS POR USUARIO LOGUEADO
    func fetchMascotasDelUsuario(_ usuario: Usuario) -> [Mascota] {
        let request: NSFetchRequest<Mascota> = Mascota.fetchRequest()
        request.predicate = NSPredicate(format: "usuario == %@", usuario)

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
