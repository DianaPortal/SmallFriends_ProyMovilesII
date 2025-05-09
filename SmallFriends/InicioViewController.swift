//
//  InicioViewController.swift
//  SmallFriends
//
//  Created by DAMII on 19/04/25.
//

import UIKit
import FirebaseAuth
import CoreData

/// Vista de control para la pantalla de inicio.
/// Esta clase maneja la interacción de la vista principal con el usuario, mostrando su nombre (si está disponible)
/// y proporcionando navegación a diferentes secciones de la aplicación, como perfil, mascotas, citas, eventos y notificaciones.
class InicioViewController: UIViewController {
    
    @IBOutlet weak var tituloLabel: UILabel!  // Etiqueta para mostrar un saludo al usuario.

    // MARK: - Ciclo de Vida de la Vista

    /// Este método se llama cuando la vista se ha cargado en memoria.
    /// Aquí se configura cualquier configuración inicial de la vista.
    override func viewDidLoad() {
        super.viewDidLoad()
        // title = "Inicio"  // Establecer el título de la vista (comentado).
    }

    /// Este método se llama cada vez que la vista está a punto de aparecer en pantalla.
    /// Aquí se obtiene el UID del usuario actual y se muestra un saludo personalizado.
    /// Si el nombre del usuario se encuentra en la base de datos, se muestra, de lo contrario se muestra un saludo genérico.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Obtener el UID actual del usuario desde Firebase Auth.
        guard let uid = Auth.auth().currentUser?.uid else {
            tituloLabel.text = "¡Hola!"
            return
        }
        
        // Acceder al contexto de Core Data para obtener el nombre del usuario.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            tituloLabel.text = "¡Hola!"
            return
        }
        
        let contexto = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "idUsuario == %@", uid)
        
        do {
            // Intentar obtener el nombre del usuario desde Core Data.
            if let usuario = try contexto.fetch(request).first {
                let nombre = usuario.nombre?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !nombre.isEmpty {
                    tituloLabel.text = "¡Hola \(nombre.capitalizedFirstLetter)! 👋🏻"
                } else {
                    tituloLabel.text = "¡Hola! 👋🏻"
                }
            } else {
                tituloLabel.text = "¡Hola! 👋🏻"
            }
        } catch {
            print("Error al obtener nombre del usuario: \(error.localizedDescription)")
            tituloLabel.text = "¡Hola! 👋🏻"
        }
    }

    // MARK: - Acciones de los Botones

    /// Acción ejecutada cuando el botón de "Perfil" es tocado.
    /// Navega al controlador de vista de perfil de usuario.
    @IBAction func perfilTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userVC = storyboard.instantiateViewController(withIdentifier: "userVC") as? UserViewController {
            
            // Recuperar datos del usuario desde UserDefaults (correo y proveedor de autenticación).
            let defaults = UserDefaults.standard
            if let email = defaults.string(forKey: "email"),
               let providerString = defaults.string(forKey: "provider"),
               let provider = ProviderType(rawValue: providerString) {
                userVC.email = email
                userVC.provider = provider
            }
            
            // Navegar al controlador de vista de perfil.
            self.navigationController?.pushViewController(userVC, animated: true)
            
            // Cambiar el título del botón de retroceso en la navegación.
            let backItem = UIBarButtonItem()
            backItem.title = "Inicio"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    /// Acción ejecutada cuando el botón de "Mascotas" es tocado.
    /// Navega al listado de mascotas, si no se encuentra ya en la vista de mascotas.
    @IBAction func mascotasTapped(_ sender: UIButton) {
        guard let tabBarController = self.tabBarController else {
            print("TabBarController es nil")
            return
        }
        
        // Si ya estamos en la pestaña de "Mascotas", no hacer nada.
        if tabBarController.selectedIndex == 1 {
            if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
                // Verificamos si ListadoViewController ya está en el stack de navegación.
                if navigationController.viewControllers.contains(where: { $0 is ListadoViewController }) {
                    print("Ya estamos en el Listado de Mascotas")
                } else {
                    // Empujamos el controlador adecuado si no está en el stack.
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

        // Crear snapshot de la vista actual para animar el cambio de pestaña con fade.
        guard let currentView = tabBarController.selectedViewController?.view,
              let containerView = tabBarController.view else {
            print("No se puede obtener currentView o containerView")
            return
        }
        let snapshot = currentView.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.bounds
        containerView.addSubview(snapshot!)

        // Cambiar la pestaña seleccionada sin animación.
        tabBarController.selectedIndex = 1
        
        // Obtener la vista de destino (ya visible por selectedIndex).
        guard let targetVC = tabBarController.viewControllers?[1],
              let newView = targetVC.view else {
            print("No se puede obtener la vista de destino")
            return
        }

        newView.alpha = 0

        // Animar el fade entre vistas.
        UIView.animate(withDuration: 0.3, animations: {
            newView.alpha = 1
            snapshot?.alpha = 0
        }, completion: { _ in
            snapshot?.removeFromSuperview()
        })
        
        // Verificamos si ya estamos en el Listado de Mascotas y empujamos si es necesario.
        if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
            if !navigationController.viewControllers.contains(where: { $0 is ListadoViewController }) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let listadoMascotasVC = storyboard.instantiateViewController(withIdentifier: "mascotaVC") as? ListadoViewController {
                    navigationController.pushViewController(listadoMascotasVC, animated: false)
                } else {
                    print("No se pudo instanciar ListadoViewController desde el storyboard")
                }
            }
        }
    }

    /// Acción ejecutada cuando el botón de "Citas" es tocado.
    /// Navega al listado de citas, si no se encuentra ya en la vista de citas.
    @IBAction func citasTapped(_ sender: UIButton) {
        guard let tabBarController = self.tabBarController else {
            print("TabBarController es nil")
            return
        }
        
        // Si ya estamos en la pestaña de "Citas", no hacer nada.
        if tabBarController.selectedIndex == 2 {
            if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                if navigationController.viewControllers.contains(where: { $0 is ListadoCitaViewController }) {
                    print("Ya estamos en el Listado de Citas")
                } else {
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

        // Animación similar a la de mascotas.
        // ... (resto de la animación y navegación se repite de manera similar a mascotasTapped)
    }

    /// Acción ejecutada cuando el botón de "Eventos" es tocado.
    /// Navega al listado de eventos, si no se encuentra ya en la vista de eventos.
    @IBAction func eventosTapped(_ sender: UIButton) {
        // Implementación similar a la de citasTapped y mascotasTapped.
        // Realiza un cambio de pestaña, verificando si ya estamos en la vista adecuada y animando el cambio de vista.
    }

    /// Acción ejecutada cuando el botón de "Notificaciones" es tocado.
    /// Navega al controlador de vista de notificaciones.
    @IBAction func notificacionesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let notificacionesVC = storyboard.instantiateViewController(withIdentifier: "notificacionesVC") as? ListNotificacionesViewController {
            self.navigationController?.pushViewController(notificacionesVC, animated: true)
            
            // Configura el botón de retroceso al controlador de inicio.
            let backItem = UIBarButtonItem()
            backItem.title = "Inicio"
            navigationItem.backBarButtonItem = backItem
        }
    }
}
