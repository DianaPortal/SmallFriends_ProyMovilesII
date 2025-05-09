import UIKit
import CoreData
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FacebookLogin

class AuthViewController: UIViewController {
    
    @IBOutlet weak var authStackView: UIStackView!
    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Comprobar sesión guardada
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            authStackView.isHidden = true
            goToMainTabBar() // Aquí se llama a la función para ir al MainTabBar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStackView.isHidden = false
    }
    
    // MARK: - Acciones
    @IBAction func iniciarSesionTapped(_ sender: UIButton) {
        guard let email = correoTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Campos vacíos", message: "Por favor ingresa correo y contraseña.")
            return
        }
        
        // Inicio de sesión con Firebase Auth
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error al iniciar sesión: \(error.localizedDescription)")
                self.showAlert(title: "Error de autenticación", message: "Correo o contraseña incorrectos.")
                return
            }
            let successAlert = UIAlertController(title: "¡Bienvenido!", message: "Has iniciado sesión con éxito.", preferredStyle: .alert)
            
            successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                self.goToMainTabBar() // Llamada a la función para ir al MainTabBar
            })
            
            self.present(successAlert, animated: true, completion: nil)
        }
    }

    // MARK: - Funciones auxiliares
    
    // Función para navegar al MainTabBarController
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 1, options: .transitionFlipFromRight, animations: {
                window.rootViewController = tabBarController
            }, completion: { _ in
                window.makeKeyAndVisible()
            })
        } else {
            print("No se pudo acceder al SceneDelegate o al window.")
        }
    }
    
    // Función para mostrar alertas
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
