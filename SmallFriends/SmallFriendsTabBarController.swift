//  SmallFriendsTabBarController.swift
//  SmallFriends
//
//  Created by DAMII on 5/05/25.
//

import UIKit

// Controlador de barra de pestañas que maneja la transición de vistas
class SmallFriendsTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // Método que se llama cuando la vista del controlador se ha cargado
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establece el delegado del TabBarController a sí mismo
        self.delegate = self
    }
    
    // Método delegado que determina si se debe cambiar la vista seleccionada
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // Comprobar si se está intentando seleccionar la misma vista que la actual
        guard let fromView = selectedViewController?.view,
              let fromVC = selectedViewController,
              fromVC != viewController else {
            return true // Si es la misma vista, permitir la selección
        }
        
        // Crear un snapshot (captura) de la vista actual para simular una animación de transición
        guard let snapshot = fromView.snapshotView(afterScreenUpdates: false) else {
            // Si no se puede crear el snapshot, cambiar directamente la vista seleccionada
            selectedViewController = viewController
            return true
        }
        
        // Ajustar el tamaño del snapshot para que cubra toda la pantalla
        snapshot.frame = tabBarController.view.bounds
        tabBarController.view.addSubview(snapshot)
        
        // Cambiar la vista seleccionada inmediatamente
        selectedViewController = viewController
        
        // Esperar al siguiente ciclo del run loop para que UIKit termine de insertar la vista seleccionada
        DispatchQueue.main.async {
            guard let toView = viewController.view else { return }
            
            // Hacer la vista de destino completamente invisible al principio
            toView.alpha = 0
            tabBarController.view.bringSubviewToFront(toView)
            
            // Animación de transición con desvanecimiento
            UIView.animate(withDuration: 0.3, animations: {
                toView.alpha = 1 // Hacer la vista de destino visible
                snapshot.alpha = 0 // Hacer que el snapshot desaparezca
            }, completion: { _ in
                // Eliminar el snapshot una vez finalizada la animación
                snapshot.removeFromSuperview()
            })
            
            // Restablecer el stack de navegación después de que la vista se haga visible
            self.resetNavigationStack(for: viewController)
        }
        
        // Retornar false para evitar la acción predeterminada de selección, que será manejada manualmente
        return false
    }
    
    // Método privado para restablecer el stack de navegación del controlador de vista seleccionado
    private func resetNavigationStack(for viewController: UIViewController) {
        // Si la vista seleccionada es un NavigationController, restablecer su stack de navegación
        if let navVC = viewController as? UINavigationController {
            // Realizar el popToRoot solo si es un NavigationController y resetear su stack
            navVC.popToRootViewController(animated: false)
        }
    }
}
