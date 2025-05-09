//
//  AppDelegate.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//
//  Este archivo contiene la implementación del `AppDelegate` de la aplicación SmallFriends. El `AppDelegate`
//  es responsable de manejar eventos de ciclo de vida de la aplicación, como su inicio, cierre, y configuración de
//  servicios esenciales, como Firebase, Google Sign-In, Facebook Login, notificaciones locales, y Core Data.
//
//  A continuación se documentan los métodos principales y la configuración de la aplicación.

import UIKit
import CoreData
import FirebaseCore
import GoogleSignIn
import FacebookCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // MARK: - Ciclo de Vida de la Aplicación
    
    /// Método llamado cuando la aplicación ha terminado de lanzar y está lista para empezar a ejecutarse.
    ///
    /// Este método se utiliza para realizar la configuración inicial de la aplicación, como la configuración de Firebase,
    /// la integración con Google y Facebook, y la habilitación de notificaciones locales.
    ///
    /// - Parameter application: La instancia de la aplicación.
    /// - Parameter launchOptions: Opciones de lanzamiento, como los datos de la notificación remota si existe.
    /// - Returns: Un valor booleano que indica si la aplicación se ha lanzado correctamente.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configuración de Firebase
        FirebaseApp.configure()  // Inicializa Firebase para usar sus servicios
        
        // Configuración de Facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)  // Inicializa Facebook SDK
        
        // Configuración de Notificaciones Locales
        UNUserNotificationCenter.current().delegate = self  // Permite manejar notificaciones en primer plano
        
        return true
    }
    
    // MARK: - Manejo de URL para Google y Facebook
    
    /// Método llamado cuando la aplicación maneja una URL externa, utilizado para manejar el inicio de sesión
    /// a través de Google y Facebook.
    ///
    /// - Parameter app: La instancia de la aplicación.
    /// - Parameter url: La URL que se ha recibido.
    /// - Parameter options: Opciones adicionales para el manejo de la URL.
    /// - Returns: Un valor booleano que indica si alguna de las plataformas manejó la URL.
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Manejo de la URL para Google Sign-In
        let googleDidHandle = GIDSignIn.sharedInstance.handle(url)
        
        // Manejo de la URL para Facebook Login
        let facebookDidHandle = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation] as Any
        )
        
        return googleDidHandle || facebookDidHandle  // Retorna si alguna plataforma ha manejado la URL
    }
    
    // MARK: - Ciclo de Vida de las Sesiones de Escena (iOS 13+)
    
    /// Configuración para manejar las sesiones de escena en dispositivos con iOS 13 o posterior.
    ///
    /// - Parameter application: La instancia de la aplicación.
    /// - Parameter connectingSceneSession: La sesión de escena que está siendo conectada.
    /// - Parameter options: Opciones de conexión para la nueva sesión de escena.
    /// - Returns: Una configuración de escena que se utilizará para la conexión.
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    /// Método llamado cuando se descartan las sesiones de escena.
    ///
    /// - Parameter application: La instancia de la aplicación.
    /// - Parameter sceneSessions: Conjunto de sesiones de escena que fueron descartadas.
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Core Data Stack
    
    /// El contenedor persistente de Core Data, que gestiona el almacenamiento de datos de la aplicación.
    ///
    /// El contenedor `NSPersistentContainer` gestiona el contexto de la vista y las operaciones de carga y guardado de datos.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmallFriends")  // Nombre del modelo de datos
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Si ocurre un error al cargar el contenedor, la aplicación se cerrará con un error fatal.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Soporte para Guardar Contexto de Core Data
    
    /// Método para guardar los cambios en el contexto de Core Data.
    ///
    /// Si el contexto de vista tiene cambios pendientes, este método intenta guardarlos. Si ocurre un error, la aplicación se cerrará.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()  // Intenta guardar los cambios en el contexto
            } catch {
                // Si ocurre un error, la aplicación se cerrará con un error fatal.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Notificaciones en Primer Plano

/// Extensión para manejar notificaciones locales cuando la aplicación está en primer plano.
/// Se configura para mostrar banners, listas y sonidos para notificaciones mientras la app está abierta.
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Configura las opciones de presentación de notificaciones: banner, lista y sonido
        completionHandler([.banner, .list, .sound])
    }
}
