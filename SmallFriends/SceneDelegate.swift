//
//  SceneDelegate.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Crear una nueva ventana
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Verificar si hay una sesión guardada
        let defaults = UserDefaults.standard
        let initialVC: UIViewController
        
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            // Usuario autenticado → ir al TabBarController
            initialVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        } else {
            // No autenticado → ir al Login (AuthViewController)
            initialVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        }
        
        // Asignar el controlador inicial y mostrar la ventana
        window.rootViewController = initialVC
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

