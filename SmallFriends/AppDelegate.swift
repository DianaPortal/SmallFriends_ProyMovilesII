//
//  AppDelegate.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//
//  Este archivo define la clase AppDelegate, que actúa como punto de entrada de la aplicación.
//  Configura servicios externos como Firebase, Google y Facebook, y administra el ciclo de vida
//  de la aplicación así como la configuración de Core Data y notificaciones locales.
//

import UIKit
import CoreData
import FirebaseCore
import GoogleSignIn
import FacebookCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Ventana principal de la aplicación (en aplicaciones sin escenas).
    var window: UIWindow?
    
    /// Método que se llama cuando la aplicación ha terminado de lanzarse.
    /// Aquí se configura Firebase, Facebook y se habilitan las notificaciones en primer plano.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Inicialización de Firebase
        FirebaseApp.configure()
        
        // Inicialización de Facebook SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Configuración del delegado para notificaciones en primer plano
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    /// Manejo de URLs abiertas por la aplicación (necesario para autenticación con Google y Facebook).
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Manejo de inicio de sesión con Google
        let googleDidHandle = GIDSignIn.sharedInstance.handle(url)
        
        // Manejo de inicio de sesión con Facebook
        let facebookDidHandle = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation] as Any
        )
        
        return googleDidHandle || facebookDidHandle
    }
    
    // MARK: UISceneSession Lifecycle
    
    /// Configuración para una nueva sesión de escena (en iOS con múltiples ventanas).
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    /// Método llamado cuando una o más sesiones de escena han sido descartadas.
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Aquí puedes liberar recursos relacionados con escenas descartadas.
    }
    
    // MARK: - Core Data stack
    
    /// Contenedor de persistencia de Core Data.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmallFriends")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Si ocurre un error al cargar el almacenamiento, se detiene la ejecución.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    /// Guarda el contexto actual de Core Data si hay cambios pendientes.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Manejo de errores al guardar los cambios.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Notificaciones en primer plano

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Método que permite mostrar notificaciones cuando la app está en primer plano.
    /// Se especifica que se muestre como banner, en la lista y con sonido.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
