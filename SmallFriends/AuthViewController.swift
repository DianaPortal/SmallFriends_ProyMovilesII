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
        title = "Autenticación"  

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
    // Btn Iniciar sesión
    @IBAction func iniciarSesionTapped(_ sender: UIButton) {
        guard let email = correoTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Campos vacíos", message: "Por favor ingresa correo y contraseña.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                    print("Error al iniciar sesión: \(error.localizedDescription)")
                    self.showAlert(title: "Error de autenticación", message: "Correo o contraseña incorrectos.")
                    return
            }

            // Aquí sí validamos bien el resultado
           self.goToMainTabBar()
            self.showHome(result: result, error: error, provider: .basic)

        }
                 
    }
    
    @IBAction func olvidastePasswordTapped(_ sender: UIButton) {
        // Mostrar un alert para que el usuario ingrese su correo electrónico
          let alert = UIAlertController(title: "Recuperar Contraseña", message: "Ingresa tu correo para enviar un enlace de recuperación.", preferredStyle: .alert)
          
          alert.addTextField { textField in
              textField.placeholder = "Correo electrónico"
              textField.keyboardType = .emailAddress
          }
          
          let resetAction = UIAlertAction(title: "Enviar enlace", style: .default) { _ in
              guard let email = alert.textFields?.first?.text, !email.isEmpty else {
                  self.showAlert(title: "Campo vacío", message: "Por favor ingresa un correo electrónico.")
                  return
              }
              
              // Enviar enlace de restablecimiento de contraseña
              Auth.auth().sendPasswordReset(withEmail: email) { error in
                  if let error = error {
                      // Si hay un error al enviar el enlace
                      self.showAlert(title: "Error", message: "Hubo un problema al enviar el enlace. Verifica el correo o intenta más tarde.")
                      return
                  }
                  
                  // Si todo está bien, mostrar mensaje de éxito
                  self.showAlert(title: "Enlace Enviado", message: "Revisa tu correo para restablecer tu contraseña.")
              }
          }
          
          alert.addAction(resetAction)
          alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
          
          present(alert, animated: true, completion: nil)
                
    }	
    
    
    //Btn Registrar Usuario
    @IBAction func registrarseTapped(_ sender: UIButton) {
        //Mostrar alerta para registrar Usuario
        let alert = UIAlertController(title: "Registro Usuario", message: "Ingresa tus datos", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Correo electrónico"
            textField.keyboardType = .emailAddress
        }
        alert.addTextField { textField in
            textField.placeholder = "Contraseña"
            textField.isSecureTextEntry = true
        }
           
        alert.addTextField { textField in
            textField.placeholder = "Nombre"
        }
           
        alert.addTextField { textField in
            textField.placeholder = "Apellido"
        }
        
        let registerAction = UIAlertAction(title: "Registrar", style: .default) { _ in
        // Obtener datos de la alerta
            guard let email = alert.textFields?[0].text, !email.isEmpty,
                  let password = alert.textFields?[1].text, !password.isEmpty,
                  let nombre = alert.textFields?[2].text, !nombre.isEmpty,
                  let apellidos = alert.textFields?[3].text, !apellidos.isEmpty else {
                self.showAlert(title: "Campos vacíos", message: "Por favor ingresa todos los datos.")
                return
            }
            // Crear usuario en Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            print("Error al registrar usuario: \(error.localizedDescription)")
        self.showAlert(title: "Error de registro", message: "Hubo un problema al registrar el usuario.")
        return
        }
       // Guardar el usuario en Firebase y en Core Data
       self.showHome(result: result, error: error, provider: .basic)
        
        // Aquí puedes guardar en core data
            let uid = result?.user.uid
        self.guardarUsuarioEnCoreData(uid: uid ?? "", email: email, provider: .basic, nombre: nombre, apellidos: apellidos)
            }
        }
        alert.addAction(registerAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
        present(alert, animated: true, completion: nil)


    }
    
    //Autenticación con google
    @IBAction func googleTapped(_ sender: UIButton) {
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

    //Autenticación con facebook
    @IBAction func facebookTapped(_ sender: UIButton) {
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

    // Función de manejo de inciar sesión

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
        
        // OBTIENE USUARIO
        if let user = Auth.auth().currentUser {
            // Usuario autenticado
            let uid = user.uid
            // Proceder con operaciones que requieren el UID
        } else {
            // No hay usuario autenticado
            print("No hay usuario autenticado")
        }

        // Autenticación 
        guard let result = result else {
            showAlert(title: "Error", message: "No se pudo iniciar sesión. Intenta más tarde.")
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(result.user.email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        
        defaults.set(result.user.email, forKey: "correoUsuarioLogueado")
        
        verificarYGuardarUsuarioSiNoExiste(uid: result.user.uid, email: result.user.email, provider: provider)
       
        //Redigir al MainTabBarController después de iniciar sesión correctamente
        authStackView.isHidden = true
        goToMainTabBar()
    }


    // MARK: - Función para ir al TabBarController principal --> mostrar la pantalla de bienvenida
    
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }
        
        // - SceneDelegate para cambiar el rootViewController
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        } else {
            print("No se pudo acceder al SceneDelegate o al window.")
        }
    }
    
    // Func - Alertas
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // Función para guardar La sesió en core data
    private func guardarUsuarioEnCoreData(uid: String, email: String?, provider: ProviderType, nombre: String, apellidos: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let contexto = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idUsuario == %@", uid)

        do {
            let resultados = try contexto.fetch(fetchRequest)
            if resultados.isEmpty {
                let nuevoUsuario = Usuario(context: contexto)
                nuevoUsuario.idUsuario = uid
                nuevoUsuario.email = email
                nuevoUsuario.provider = provider.rawValue
                nuevoUsuario.nombre = nombre
                nuevoUsuario.apellidos = apellidos

                try contexto.save()
                print("Usuario guardado en Core Data")
            } else {
                print("Usuario ya estaba en Core Data")
            }
        } catch {
            print("Error al guardar en Core Data: \(error.localizedDescription)")
        }
    }

    private func verificarYGuardarUsuarioSiNoExiste(uid: String, email: String?, provider: ProviderType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let contexto = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idUsuario == %@", uid)

        do {
            let resultados = try contexto.fetch(fetchRequest)
            if resultados.isEmpty {
                let nuevoUsuario = Usuario(context: contexto)
                nuevoUsuario.idUsuario = uid
                nuevoUsuario.email = email
                nuevoUsuario.provider = provider.rawValue
                nuevoUsuario.nombre = "Sin nombre"
                nuevoUsuario.apellidos = "Sin apellidos"
                try contexto.save()
                print("Usuario guardado al iniciar sesión")
            } else {
                print("Usuario ya existe en Core Data")
            }
        } catch {
            print("Error al guardar usuario desde login: \(error.localizedDescription)")
        }
    }

}
