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

enum ProviderType: String{
    case basic
    case google
    case facebook
}

class UserViewController: UIViewController {
    
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!    
    @IBOutlet weak var closeSessionButton: UIButton!
    
    var email: String?
    var provider: ProviderType?
    
    // Este inicializador será utilizado cuando se carga desde el Storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // logica
    }
    
    //
    init(email: String, provider: ProviderType) {
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio"
        navigationItem.setHidesBackButton(true, animated: false)
        
        
                
        // Mostrar datos
        correoLabel.text = email
        providerLabel.text = provider?.rawValue

        
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
            
        // Redirigir al login
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
/***/
