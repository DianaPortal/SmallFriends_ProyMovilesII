//
//  SmallFriendsTabBarController.swift
//  SmallFriends
//
//  Created by DAMII on 5/05/25.
//

import UIKit

class SmallFriendsTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view,
              let fromVC = selectedViewController,
              fromVC != viewController else {
            return true
        }

        // Crear un snapshot de la vista actual
        guard let snapshot = fromView.snapshotView(afterScreenUpdates: false) else {
            // Si no se puede crear snapshot, cambiar directamente la vista seleccionada
            selectedViewController = viewController
            return true
        }

        snapshot.frame = tabBarController.view.bounds
        tabBarController.view.addSubview(snapshot)

        // Cambiar la pestaña seleccionada inmediatamente
        selectedViewController = viewController

        // Esperar al siguiente ciclo del run loop para que UIKit termine de insertar la vista
        DispatchQueue.main.async {
            guard let toView = viewController.view else { return }
            toView.alpha = 0
            tabBarController.view.bringSubviewToFront(toView)

            UIView.animate(withDuration: 0.3, animations: {
                toView.alpha = 1
                snapshot.alpha = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })

            // Reiniciar stack de navegación después de que la vista está visible
            self.resetNavigationStack(for: viewController)
        }

        return false
    }

    // Resetear el stack de navegación
    private func resetNavigationStack(for viewController: UIViewController) {
        // Si la vista seleccionada tiene un NavigationController, restablecer su stack
        if let navVC = viewController as? UINavigationController {
            // Realizar el popToRoot solo si es necesario (cuando es un NavigationController)
            navVC.popToRootViewController(animated: false)
        }
    }
}

