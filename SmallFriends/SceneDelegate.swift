//
//  SceneDelegate.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//
//  Este archivo contiene la implementación de la clase `SceneDelegate` para la aplicación SmallFriends. `SceneDelegate`
//  maneja el ciclo de vida de la escena de la aplicación en dispositivos con iOS 13 o superior. En iOS 13+, la gestión de
//  las interfaces de usuario se maneja por escenas, lo que permite que una aplicación tenga múltiples ventanas o escenas
//  activas al mismo tiempo. Esta clase se encarga de gestionar la creación y la configuración inicial de la interfaz de usuario,
//  dependiendo del estado de autenticación del usuario.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - Ciclo de Vida de la Escena
    
    /// Método llamado cuando la escena se está conectando. Este método se utiliza para configurar la ventana principal
    /// de la aplicación y establecer el controlador de vista inicial según el estado de autenticación del usuario.
    ///
    /// - Parameter scene: La escena que se está conectando.
    /// - Parameter session: La sesión de escena que se está conectando.
    /// - Parameter connectionOptions: Opciones de conexión para la escena.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Crear una nueva ventana con la escena proporcionada
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Verificar si el usuario está autenticado, basándonos en la existencia de un correo electrónico y un proveedor guardados en UserDefaults
        let defaults = UserDefaults.standard
        let initialVC: UIViewController
        
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            // Si el usuario está autenticado, establecer el TabBarController como controlador principal
            initialVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            // Si el usuario no está autenticado, dirigir a la pantalla de Login (AuthViewController)
            initialVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        }
        
        // Establecer el controlador inicial y hacer visible la ventana
        window.rootViewController = initialVC
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // MARK: - Métodos del Ciclo de Vida de la Escena (Opcionales)
    
    /// Método llamado cuando la escena se desconecta. Este método es llamado cuando la escena se elimina.
    ///
    /// - Parameter scene: La escena que se desconectó.
    func sceneDidDisconnect(_ scene: UIScene) {
        // Aquí se pueden liberar recursos cuando la escena ya no está activa.
    }
    
    /// Método llamado cuando la escena se vuelve activa, después de haber estado en segundo plano.
    ///
    /// - Parameter scene: La escena que ha pasado a ser activa.
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Este método puede ser utilizado para reiniciar tareas que estaban pausadas cuando la escena estaba inactiva.
    }
    
    /// Método llamado cuando la escena va a pasar a un estado inactivo.
    ///
    /// - Parameter scene: La escena que va a volverse inactiva.
    func sceneWillResignActive(_ scene: UIScene) {
        // Este método puede ser utilizado para pausar tareas o procesos que no deben ejecutarse mientras la escena está inactiva.
    }
    
    /// Método llamado cuando la escena entra en primer plano, después de haber estado en segundo plano.
    ///
    /// - Parameter scene: La escena que está entrando en primer plano.
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Este método puede usarse para deshacer cambios hechos cuando la escena entró en segundo plano.
    }
    
    /// Método llamado cuando la escena entra en segundo plano.
    ///
    /// - Parameter scene: La escena que ha entrado en segundo plano.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Este método se llama cuando la escena entra en segundo plano.
        // Aquí se pueden guardar datos, liberar recursos o almacenar el estado de la escena.
        
        // Guardar cambios en el contexto de Core Data cuando la aplicación se va a segundo plano
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
