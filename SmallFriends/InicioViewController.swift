//
//  InicioViewController.swift
//  SmallFriends
//
//  Created by DAMII on 19/04/25.
//

import UIKit
import FirebaseAuth
import CoreData

class InicioViewController: UIViewController {

    @IBOutlet weak var tituloLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // title = "Inicio"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Obtener el UID actual
        guard let uid = Auth.auth().currentUser?.uid else {
            tituloLabel.text = "¡Hola!"
            return
        }

        // Acceder al contexto de Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            tituloLabel.text = "¡Hola!"
            return
        }
        
        let contexto = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "idUsuario == %@", uid)

        do {
            if let usuario = try contexto.fetch(request).first {
                let nombre = usuario.nombre?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !nombre.isEmpty {
                    tituloLabel.text = "¡Hola \(nombre.capitalizedFirstLetter)!"
                } else {
                    tituloLabel.text = "¡Hola!"
                }
            } else {
                tituloLabel.text = "¡Hola!"
            }
        } catch {
            print("Error al obtener nombre del usuario: \(error.localizedDescription)")
            tituloLabel.text = "¡Hola!"
        }
    }


    @IBAction func perfilTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let userVC = storyboard.instantiateViewController(withIdentifier: "userVC") as? UserViewController {
                
                // Recuperar los datos desde UserDefaults
                let defaults = UserDefaults.standard
                if let email = defaults.string(forKey: "email"),
                   let providerString = defaults.string(forKey: "provider"),
                   let provider = ProviderType(rawValue: providerString) {
                    userVC.email = email
                    userVC.provider = provider
                }

                // Si estás usando un NavigationController:
                self.navigationController?.pushViewController(userVC, animated: true)
                
                // BOTON BACK
                let backItem = UIBarButtonItem()
                backItem.title = "Inicio"
                navigationItem.backBarButtonItem = backItem
            }
    }
    
    @IBAction func mascotasTapped(_ sender: UIButton) {
        guard let tabBarController = self.tabBarController else {
            print("TabBarController es nil")
            return
        }

        // Si ya estamos en la pestaña de "Mascotas", no hacer nada
        if tabBarController.selectedIndex == 1 {
            if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
                // Verificamos si ListadoViewController ya está en el stack de navegación
                if let listadoMascotasVC = navigationController.viewControllers.first(where: { $0 is ListadoViewController }) {
                    // Si ya estamos en el Listado de Mascotas, no hacemos nada
                    print("Ya estamos en el Listado de Mascotas")
                } else {
                    // Si no está en el Listado de Mascotas, empujamos el controlador adecuado
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let listadoMascotasVC = storyboard.instantiateViewController(withIdentifier: "mascotaVC") as? ListadoViewController {
                        navigationController.pushViewController(listadoMascotasVC, animated: false)
                    } else {
                        print("No se pudo instanciar ListadoViewController desde el storyboard")
                    }
                }
            }
            return
        }

        // Crear snapshot de la vista actual (sin afectar el tab bar)
        guard let currentView = tabBarController.selectedViewController?.view,
              let containerView = tabBarController.view else {
            print("No se puede obtener currentView o containerView")
            return
        }
        let snapshot = currentView.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.bounds
        containerView.addSubview(snapshot!)

        // Cambiar la pestaña seleccionada sin animación
        tabBarController.selectedIndex = 1

        // Obtener la vista de destino (ya visible por selectedIndex)
        guard let targetVC = tabBarController.viewControllers?[1],
              let newView = targetVC.view else {
            print("No se puede obtener la vista de destino")
            return
        }

        newView.alpha = 0

        // Animar el fade
        UIView.animate(withDuration: 0.3, animations: {
            newView.alpha = 1
            snapshot?.alpha = 0
        }, completion: { _ in
            snapshot?.removeFromSuperview()
        })

        // Verificamos si ya estamos en el Listado de Mascotas
        if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
            // Verificamos si ListadoViewController ya está en el stack
            if let listadoMascotasVC = navigationController.viewControllers.first(where: { $0 is ListadoViewController }) {
                print("Ya estamos en el Listado de Mascotas")
            } else {
                // Si no está en el Listado de Mascotas, empujamos el controlador adecuado
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let listadoMascotasVC = storyboard.instantiateViewController(withIdentifier: "mascotaVC") as? ListadoViewController {
                    navigationController.pushViewController(listadoMascotasVC, animated: false)
                } else {
                    print("No se pudo instanciar ListadoViewController desde el storyboard")
                }
            }
        }

        // Reiniciar el stack de navegación si es necesario
        if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }

    
    @IBAction func citasTapped(_ sender: UIButton) {
        guard let tabBarController = self.tabBarController else {
            print("TabBarController es nil")
            return
        }

        // Si ya estamos en la pestaña de "Citas", no hacer nada
        if tabBarController.selectedIndex == 2 {
            if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                // Verificamos si Listado de Citas ya está en el stack de navegación
                if let citasVC = navigationController.viewControllers.first(where: { $0 is ListadoCitaViewController }) {
                    // Si ya estamos en el Listado de Citas, no hacemos nada
                    print("Ya estamos en el Listado de Citas")
                } else {
                    // Si no está en el Listado de Citas, empujamos el controlador adecuado
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let citasVC = storyboard.instantiateViewController(withIdentifier: "citasVC") as? ListadoCitaViewController {
                        navigationController.pushViewController(citasVC, animated: false)
                    } else {
                        print("No se pudo instanciar CitasViewController desde el storyboard")
                    }
                }
            }
            return
        }

        // Crear snapshot de la vista actual (sin afectar el tab bar)
        guard let currentView = tabBarController.selectedViewController?.view,
              let containerView = tabBarController.view else {
            print("No se puede obtener currentView o containerView")
            return
        }
        let snapshot = currentView.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.bounds
        containerView.addSubview(snapshot!)

        // Cambiar la pestaña seleccionada sin animación
        tabBarController.selectedIndex = 2

        // Obtener la vista de destino (ya visible por selectedIndex)
        guard let targetVC = tabBarController.viewControllers?[2],
              let newView = targetVC.view else {
            print("No se puede obtener la vista de destino")
            return
        }

        newView.alpha = 0

        // Animar el fade
        UIView.animate(withDuration: 0.3, animations: {
            newView.alpha = 1
            snapshot?.alpha = 0
        }, completion: { _ in
            snapshot?.removeFromSuperview()
        })

        // Verificamos si ya estamos en el Listado de Citas
        if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
            // Verificamos si CitasViewController ya está en el stack
            if let citasVC = navigationController.viewControllers.first(where: { $0 is ListadoCitaViewController }) {
                print("Ya estamos en el Listado de Citas")
            } else {
                // Si no está en el Listado de Citas, empujamos el controlador adecuado
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let citasVC = storyboard.instantiateViewController(withIdentifier: "citasVC") as? ListadoCitaViewController {
                    navigationController.pushViewController(citasVC, animated: false)
                } else {
                    print("No se pudo instanciar CitasViewController desde el storyboard")
                }
            }
        }

        // Reiniciar el stack de navegación si es necesario
        if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }

    
    @IBAction func eventosTapped(_ sender: UIButton) {
        guard let tabBarController = self.tabBarController else {
            print("TabBarController es nil")
            return
        }

        // Si ya estamos en la pestaña de "Eventos", no hacemos nada
        if tabBarController.selectedIndex == 3 {
            if let navigationController = tabBarController.viewControllers?[3] as? UINavigationController {
                // Verificamos si el Listado de Eventos ya está en el stack de navegación
                if let eventosVC = navigationController.viewControllers.first(where: { $0 is ListaEventosAPIViewController }) {
                    // Si ya estamos en el Listado de Eventos, no hacemos nada
                    print("Ya estamos en el Listado de Eventos")
                } else {
                    // Si no está en el Listado de Eventos, empujamos el controlador adecuado
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let eventosVC = storyboard.instantiateViewController(withIdentifier: "eventosVC") as? ListaEventosAPIViewController {
                        navigationController.pushViewController(eventosVC, animated: false)
                    } else {
                        print("No se pudo instanciar EventosViewController desde el storyboard")
                    }
                }
            }
            return
        }

        // Crear snapshot de la vista actual (sin afectar el tab bar)
        guard let currentView = tabBarController.selectedViewController?.view,
              let containerView = tabBarController.view else {
            print("No se puede obtener currentView o containerView")
            return
        }
        let snapshot = currentView.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.bounds
        containerView.addSubview(snapshot!)

        // Cambiar la pestaña seleccionada sin animación
        tabBarController.selectedIndex = 3

        // Obtener la vista de destino (ya visible por selectedIndex)
        guard let targetVC = tabBarController.viewControllers?[3],
              let newView = targetVC.view else {
            print("No se puede obtener la vista de destino")
            return
        }

        newView.alpha = 0

        // Animar el fade
        UIView.animate(withDuration: 0.3, animations: {
            newView.alpha = 1
            snapshot?.alpha = 0
        }, completion: { _ in
            snapshot?.removeFromSuperview()
        })

        // Verificamos si ya estamos en el Listado de Eventos
        if let navigationController = tabBarController.viewControllers?[3] as? UINavigationController {
            // Verificamos si EventosViewController ya está en el stack
            if let eventosVC = navigationController.viewControllers.first(where: { $0 is ListaEventosAPIViewController }) {
                print("Ya estamos en el Listado de Eventos")
            } else {
                // Si no está en el Listado de Eventos, empujamos el controlador adecuado
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let eventosVC = storyboard.instantiateViewController(withIdentifier: "eventosVC") as? ListaEventosAPIViewController {
                    navigationController.pushViewController(eventosVC, animated: false)
                } else {
                    print("No se pudo instanciar EventosViewController desde el storyboard")
                }
            }
        }

        // Reiniciar el stack de navegación si es necesario
        if let navigationController = tabBarController.viewControllers?[3] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }

    
    @IBAction func notificacionesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let notificacionesVC = storyboard.instantiateViewController(withIdentifier: "notificacionesVC") as? ListNotificacionesViewController {

                // Si estás usando un NavigationController:
                self.navigationController?.pushViewController(notificacionesVC, animated: true)
                
                // BOTON BACK
                let backItem = UIBarButtonItem()
                backItem.title = "Inicio"
                navigationItem.backBarButtonItem = backItem
            }
    }
}
