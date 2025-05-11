//
//  HomeViewController.swift
//  SmallFriends
//
//  Created by Diana on 14/04/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin
import CoreData

enum ProviderType: String {
    case basic
    case google
    case facebook
}

class UserViewController: UIViewController {
    
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var closeSessionButton: UIButton!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var ApellidosLabel: UILabel!
    @IBOutlet weak var usuarioStackView: UIStackView!
    
    var email: String?
    var provider: ProviderType?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(email: String, provider: ProviderType) {
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Informacion del Usuario"
        cargarUsuarioDesdeCoreData()
        
        // Estilizar stack
        usuarioStackView.layer.cornerRadius = 16
        usuarioStackView.layer.borderWidth = 0.5
        usuarioStackView.layer.borderColor = UIColor.systemGray4.cgColor
        usuarioStackView.layer.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7).cgColor
        usuarioStackView.layer.shadowColor = UIColor.black.cgColor
        usuarioStackView.layer.shadowOpacity = 0.1
        usuarioStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        usuarioStackView.layer.shadowRadius = 4
        
        usuarioStackView.isLayoutMarginsRelativeArrangement = true
        usuarioStackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarUsuarioDesdeCoreData()
    }
    
    private func cargarUsuarioDesdeCoreData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let contexto = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "idUsuario == %@", uid)
        
        do {
            if let usuario = try contexto.fetch(request).first {
                let nombre = usuario.nombre ?? "Sin nombre"
                let apellidos = usuario.apellidos ?? "Vacio"
                let correo = usuario.email ?? "Sin correo"
                
                nombreLabel.attributedText = formatearTextoEnNegrita(titulo: " Nombre: ", valor: nombre)
                ApellidosLabel.attributedText = formatearTextoEnNegrita(titulo: " Apellidos: ", valor: apellidos)
                correoLabel.attributedText = formatearTextoEnNegrita(titulo: " Correo: ", valor: correo)
                
                print("Usuario cargado desde Core Data: \(usuario.email ?? "")")
            } else {
                print("Usuario no encontrado en Core Data")
            }
        } catch {
            print("Error al cargar usuario de Core Data: \(error.localizedDescription)")
        }
    }
    
    private func formatearTextoEnNegrita(titulo: String, valor: String) -> NSAttributedString {
        let textoCompleto = NSMutableAttributedString()
        
        let negrita = NSAttributedString(string: titulo, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 19)
        ])
        let normal = NSAttributedString(string: valor, attributes: [
            .font: UIFont.systemFont(ofSize: 17)
        ])
        
        textoCompleto.append(negrita)
        textoCompleto.append(normal)
        return textoCompleto
    }
    //Acciones
    @IBAction func closeSessionButtonAction(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "¿Cerrar sesión?",
            message: "¿Estás segur@ de que deseas cerrar sesión?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive, handler: { _ in
            // Elimina la sesión guardada
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "provider")
            defaults.synchronize()
            
            // Cancelar notificaciones pendientes
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Cerrar sesión en Firebase y proveedor
            switch self.provider {
            case .basic:
                self.firebaseLogOut()
            case .google:
                GIDSignIn.sharedInstance.signOut()
                self.firebaseLogOut()
            case .facebook:
                LoginManager().logOut()
                self.firebaseLogOut()
            case .none:
                print("No provider, no se puede hacer log out.")
            }
            
            // Navegar al AuthViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    let nav = UINavigationController(rootViewController: authVC)
                    
                    // Agregamos animación de transición
                    UIView.transition(with: window,
                                      duration: 1,
                                      options: .transitionFlipFromLeft,
                                      animations: {
                        window.rootViewController = nav
                    },
                                      completion: nil)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func actualizarTapped(_ sender: UIButton) {
        // Crear un UIAlertController para que el usuario ingrese los nuevos valores
        let alert = UIAlertController(title: "Actualizar datos", message: "Modifica tu nombre y apellido", preferredStyle: .alert)
        
        // Agregar el campo de texto para el nombre
        alert.addTextField { textField in
            textField.placeholder = "Nombre"
            // Rellenar el campo con el valor actual del nombre
            textField.text = self.nombreLabel.text?.replacingOccurrences(of: "Nombre: ", with: "")
        }
        
        // Agregar el campo de texto para el apellido
        alert.addTextField { textField in
            textField.placeholder = "Apellidos"
            // Rellenar el campo con el valor actual del apellido
            textField.text = self.ApellidosLabel.text?.replacingOccurrences(of: "Apellidos: ", with: "")
        }
        
        // Acción para guardar los cambios
        let guardarAction = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard let nuevoNombre = alert.textFields?[0].text,
                  let nuevosApellidos = alert.textFields?[1].text,
                  let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            // Guardar los nuevos valores en Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let contexto = appDelegate.persistentContainer.viewContext
            let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
            request.predicate = NSPredicate(format: "idUsuario == %@", uid)
            
            do {
                if let usuario = try contexto.fetch(request).first {
                    usuario.nombre = nuevoNombre.trimmingCharacters(in: .whitespacesAndNewlines).capitalizedFirstLetter
                    usuario.apellidos = nuevosApellidos.trimmingCharacters(in: .whitespacesAndNewlines).capitalizedFirstLetter
                    try contexto.save()
                    
                    // Actualizar las etiquetas en la interfaz
                    let nombreFormateado = nuevoNombre.trimmingCharacters(in: .whitespacesAndNewlines).capitalizedFirstLetter
                    let apellidosFormateado = nuevosApellidos.trimmingCharacters(in: .whitespacesAndNewlines).capitalizedFirstLetter
                    
                    self.nombreLabel.attributedText = self.formatearTextoEnNegrita(titulo: "Nombre: ", valor: nombreFormateado)
                    self.ApellidosLabel.attributedText = self.formatearTextoEnNegrita(titulo: "Apellidos: ", valor: apellidosFormateado)
                    
                    print("Usuario actualizado correctamente")
                    
                    // Ahora actualizar Firestore
                    self.actualizarUsuarioEnFirebase(nombre: nuevoNombre, apellidos: nuevosApellidos, uid: uid)
                }
            } catch {
                print("Error al actualizar el usuario: \(error.localizedDescription)")
            }
        }
        
        // Acción para cancelar la actualización
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        // Añadir las acciones al UIAlertController
        alert.addAction(guardarAction)
        alert.addAction(cancelarAction)
        
        // Presentar el UIAlertController
        present(alert, animated: true, completion: nil)
    }

    // Función para actualizar Firestore
    private func actualizarUsuarioEnFirebase(nombre: String, apellidos: String, uid: String) {
        let db = Firestore.firestore()
        let usuarioRef = db.collection("usuarios").document(uid)
        
        // Actualizar el nombre y apellido en Firestore
        usuarioRef.updateData([
            "nombre": nombre.capitalizedFirstLetter,
            "apellidos": apellidos.capitalizedFirstLetter
        ]) { error in
            if let error = error {
                print("Error al actualizar en Firestore: \(error.localizedDescription)")
            } else {
                print("Usuario actualizado en Firestore")
            }
        }
    }

    
    private func firebaseLogOut() {
        do {
            try Auth.auth().signOut()
            print("Cerró sesión correctamente.")
        } catch {
            print("Error al cerrar sesión en Firebase: \(error.localizedDescription)")
        }
    }
}

