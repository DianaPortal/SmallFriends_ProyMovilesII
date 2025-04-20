import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FacebookLogin

class AuthViewController: UIViewController {

    @IBOutlet weak var authStackView: UIStackView!
    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Autenticación"
        correoTextField.isSecureTextEntry = false

        // Analytics Event
        Analytics.logEvent("InitScreen", parameters: ["message": "Integración de Firebase complete"])

        // Comprobar sesión guardada
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            authStackView.isHidden = true
            goToMainTabBar()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Mostrar login si no hay sesión
        authStackView.isHidden = false
    }

    // MARK: - Acciones

    @IBAction func logInButtonAction(_ sender: UIButton) {
        guard let email = correoTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Campos vacíos", message: "Por favor ingresa correo y contraseña.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error al iniciar sesión: \(error.localizedDescription)")
                self.showAlert(title: "Error de autenticación", message: "Correo o contraseña incorrectos.")
            }

            // Aquí sí validamos bien el resultado
            self.showHome(result: result, error: error, provider: .basic)
        }
                 
    }

    @IBAction func signUpButtonAction(_ sender: UIButton) {
        if let email = correoTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }

    @IBAction func googleButtonAction(_ sender: UIButton) {
        let presentingVC = self.presentingViewController ?? self.navigationController ?? self

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Error en SignIn de Google: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("No se pudo obtener el ID Token de Google.")
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                self.showHome(result: result, error: error, provider: .google)
            }
        }
    }

    @IBAction func facebookButtonAction(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut() // Cierra sesión previa

        loginManager.logIn(permissions: ["email"], from: self) { result, error in
            if let error = error {
                print("Error en login de Facebook: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled,
                  let token = AccessToken.current?.tokenString else {
                print("Inicio de sesión con Facebook cancelado o sin token.")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: token)

            Auth.auth().signIn(with: credential) { result, error in
                self.showHome(result: result, error: error, provider: .facebook)
            }
        }
    }

    // MARK: - Función de manejo post login

    private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType) {
        if let error = error as NSError? {
            print("Error al autenticar con \(provider.rawValue): \(error.localizedDescription)")
            
            let message: String
            switch AuthErrorCode(rawValue: error.code) {
            
            case .wrongPassword:
                message = "La contraseña es incorrecta. Intenta nuevamente."
            case .invalidEmail:
                message = "El correo electrónico no tiene un formato válido."
            case .userNotFound:
                message = "No se encontró ninguna cuenta con ese correo."
            case .userDisabled:
                message = "Tu cuenta ha sido deshabilitada. Contacta soporte."
            case .networkError:
                message = "Parece que no tienes conexión a internet."
            default:
                message = "Ha ocurrido un error. Intenta de nuevo."
            }

            showAlert(title: "Error de autenticación", message: message)
            return
        }

        // Autenticación exitosa
        guard let result = result else {
            showAlert(title: "Error", message: "No se pudo iniciar sesión. Intenta más tarde.")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(result.user.email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        
        authStackView.isHidden = true
        goToMainTabBar()
    }


    // MARK: - Función para ir al TabBarController principal

    
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }
        
        // Usamos SceneDelegate para cambiar el rootViewController
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        } else {
            print("No se pudo acceder al SceneDelegate o al window.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}
