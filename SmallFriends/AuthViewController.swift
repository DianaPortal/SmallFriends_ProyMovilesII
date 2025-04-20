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
        if let email = defaults.string(forKey: "email"),
           let provider = defaults.string(forKey: "provider") {
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
        if let email = correoTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                self.showHome(result: result, error: error, provider: .basic)
            }
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
        if let result = result, error == nil {
            // Guardar datos
            let defaults = UserDefaults.standard
            defaults.set(result.user.email, forKey: "email")
            defaults.set(provider.rawValue, forKey: "provider")

            // Redirigir al TabBarController
            goToMainTabBar()
        } else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Se ha producido un error de autenticación mediante \(provider.rawValue)",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Función para ir al TabBarController principal

    
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        } else {
            print("No se pudo acceder al AppDelegate o al window.")
        }
    }

}
