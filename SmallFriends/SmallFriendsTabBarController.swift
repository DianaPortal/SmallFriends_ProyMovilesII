//
//  SmallFriendsTabBarController.swift
//  SmallFriends
//
//  Created by DAMII on 5/05/25.
//
//  Esta clase es una subclase de `UITabBarController` que gestiona la navegación entre pestañas dentro de la aplicación.
//  Se encarga de personalizar la transición entre pestañas y reiniciar el stack de navegación de cada vista cuando se cambia de pestaña.

import UIKit

class SmallFriendsTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    /// Se llama cuando la vista de la clase se ha cargado.
    /// Se establece el delegado del `UITabBarController` para manejar eventos de selección de pestañas.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // MARK: - Métodos del UITabBarControllerDelegate
    
    /// Se llama cuando el usuario selecciona una nueva pestaña.
    /// Permite realizar una transición personalizada entre las vistas seleccionadas.
    ///
    /// - Parameters:
    ///   - tabBarController: El `UITabBarController` que gestionará la transición.
    ///   - viewController: El `UIViewController` que será seleccionado.
    /// - Returns: Un valor booleano indicando si se debe permitir la selección de la pestaña.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Si la vista seleccionada es la misma que la actual, permitir la selección
        guard let fromView = selectedViewController?.view,
              let fromVC = selectedViewController,
              fromVC != viewController else {
            return true
        }
        
        // Crear un snapshot (captura visual) de la vista actual para una transición más suave
        guard let snapshot = fromView.snapshotView(afterScreenUpdates: false) else {
            // Si no se puede crear el snapshot, cambiar la vista seleccionada de inmediato
            selectedViewController = viewController
            return true
        }
        
        snapshot.frame = tabBarController.view.bounds
        tabBarController.view.addSubview(snapshot)
        
        // Cambiar la pestaña seleccionada inmediatamente
        selectedViewController = viewController
        
        // Ejecutar la animación de transición de la vista seleccionada
        DispatchQueue.main.async {
            guard let toView = viewController.view else { return }
            toView.alpha = 0
            tabBarController.view.bringSubviewToFront(toView)
            
            UIView.animate(withDuration: 0.3, animations: {
                // Animar la transición entre las vistas
                toView.alpha = 1
                snapshot.alpha = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
            
            // Reiniciar el stack de navegación después de que la nueva vista esté visible
            self.resetNavigationStack(for: viewController)
        }
        
        return false
    }
    
    // MARK: - Métodos adicionales
    
    /// Restablece el stack de navegación de un controlador de navegación cuando se cambia la pestaña.
    ///
    /// - Parameter viewController: El `UIViewController` cuyo stack de navegación se desea restablecer.
    private func resetNavigationStack(for viewController: UIViewController) {
        // Si el controlador seleccionado es un UINavigationController, se hace un pop al primer controlador
        if let navVC = viewController as? UINavigationController {
            // Solo hacer pop a la raíz si es un NavigationController
            navVC.popToRootViewController(animated: false)
        }
    }
}
