//
//  SceneDelegate.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//
//  Este archivo define la clase SceneDelegate, que es responsable de manejar
//  las escenas (ventanas) en las aplicaciones que soportan múltiples escenas
//  en iOS 13 o posterior. Aquí se gestiona la inicialización de la interfaz
//  de usuario en función de si el usuario está autenticado o no.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // La ventana principal de la escena.
    var window: UIWindow?
    
    /// Método llamado cuando una escena se conecta a la aplicación.
    /// Aquí se decide qué vista inicial mostrar dependiendo del estado de autenticación del usuario.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Se asegura de que la escena sea un tipo de UIWindowScene.
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Crear una nueva ventana para esta escena.
        let window = UIWindow(windowScene: windowScene)
        
        // Cargar el storyboard principal de la aplicación.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Verificar si el usuario está autenticado usando los valores almacenados en UserDefaults.
        let defaults = UserDefaults.standard
        let initialVC: UIViewController
        
        // Si el usuario está autenticado, se muestra el TabBarController como vista inicial.
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            initialVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            // Si el usuario no está autenticado, se muestra el controlador de vista de autenticación (AuthViewController).
            initialVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        }
        
        // Asignar el controlador inicial como rootViewController y hacer la ventana visible.
        window.rootViewController = initialVC
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // Métodos del ciclo de vida de la escena. Son llamados cuando la escena cambia de estado.
    
    /// Se llama cuando la escena se desconecta (cuando la escena deja de estar activa).
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    /// Se llama cuando la escena se vuelve activa (cuando la aplicación vuelve al primer plano).
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    /// Se llama cuando la escena va a dejar de ser activa (cuando la aplicación entra en segundo plano).
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    /// Se llama cuando la escena va a entrar en el primer plano (de segundo plano a primer plano).
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Aquí puedes hacer cosas para deshacer cambios realizados cuando la escena entró en segundo plano.
    }
    
    /// Se llama cuando la escena entra en segundo plano.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Guarda el contexto de Core Data cuando la aplicación entra en segundo plano.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
