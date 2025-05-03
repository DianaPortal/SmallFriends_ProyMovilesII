//
//  HomeViewController.swift
//  SmallFriends
//
//  Created by Diana on 14/04/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import CoreData

enum ProviderType: String{
    case basic
    case google
    case facebook
}

class UserViewController: UIViewController {
    
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!    
    @IBOutlet weak var closeSessionButton: UIButton!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var ApellidosLabel: UILabel!
    
    
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
        title = "USER"
        
        // Mostrar datos del usuario logueado
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
                ApellidosLabel.text = usuario.apellidos
                nombreLabel.text = usuario.nombre
                correoLabel.text = usuario.email
                providerLabel.text = usuario.provider
                //uidLabel.text = usuario.idUsuario
                print("Usuario cargado desde Core Data: \(usuario.email ?? "")")
            } else {
                print("Usuario no encontrado en Core Data")
            }
        } catch {
            print("Error al cargar usuario de Core Data: \(error.localizedDescription)")
        }
    }


    @IBAction func closeSessionButtonAction(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "email")
            defaults.removeObject(forKey: "provider")
            defaults.synchronize()
            
            // Asegurarnos de que provider no sea nil
            switch provider {
            case .basic:
                firebaseLogOut()
            case .google:
                GIDSignIn.sharedInstance.signOut()
                firebaseLogOut()
            case .facebook:
                LoginManager().logOut()
                firebaseLogOut()
            case .none:
                // En caso de que provider sea nil, no hacer nada o gestionar algún comportamiento
                print("No provider, no se puede hacer log out.")
            }
            
        // Redirigir al login al cerrar sesion
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let nav = UINavigationController(rootViewController: authVC)
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
    
    //
    private func  firebaseLogOut() {
        do {
            try Auth.auth().signOut()
        } catch {
                            
            //se ha producido un error
            
        }
    }
}

