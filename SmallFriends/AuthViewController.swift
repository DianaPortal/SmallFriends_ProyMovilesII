import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore
import FacebookLogin

/// `AuthViewController` es un controlador de vista encargado de gestionar el proceso de autenticación del usuario en la aplicación.
/// Permite la autenticación con correo y contraseña, Google y Facebook, además de la opción de recuperar la contraseña y registrar un nuevo usuario.
class AuthViewController: UIViewController {
    
    @IBOutlet weak var authStackView: UIStackView! // Vista de pila que contiene los elementos de autenticación.
    @IBOutlet weak var correoTextField: UITextField! // Campo de texto para el correo electrónico.
    @IBOutlet weak var passwordTextField: UITextField! // Campo de texto para la contraseña.
    
    /// Método que se llama cuando la vista ha cargado.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verifica si hay sesión guardada en UserDefaults.
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            authStackView.isHidden = true
            goToMainTabBar() // Si la sesión está activa, redirige al usuario al MainTabBar.
        }
    }
    
    /// Método que se llama cuando la vista va a aparecer en pantalla.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStackView.isHidden = false // Muestra la vista de autenticación si no hay sesión activa.
    }
    
    // MARK: - Acciones
    
    /// Acción para iniciar sesión con correo y contraseña.
    @IBAction func iniciarSesionTapped(_ sender: UIButton) {
        guard let email = correoTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Campos vacíos", message: "Por favor ingresa correo y contraseña.")
            return
        }
        
        // Intento de inicio de sesión con Firebase Auth.
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error al iniciar sesión: \(error.localizedDescription)")
                self.showAlert(title: "Error de autenticación", message: "Correo o contraseña incorrectos.")
                return
            }
            let successAlert = UIAlertController(title: "¡Bienvenido!", message: "Has iniciado sesión con éxito.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                self.goToMainTabBar()
                self.showHome(result: result, error: error, provider: .basic)
            })
            self.present(successAlert, animated: true, completion: nil)
        }
    }
    
    /// Acción para la recuperación de contraseña.
    @IBAction func olvidastePasswordTapped(_ sender: UIButton) {
        // Muestra un alert para que el usuario ingrese su correo electrónico.
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
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                self.showAlert(title: "Enlace Enviado", message: "Revisa tu correo para restablecer tu contraseña.")
            }
        }
        
        alert.addAction(resetAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Acción para registrar un nuevo usuario.
    @IBAction func registrarseTapped(_ sender: UIButton) {
        // Muestra un alert para que el usuario ingrese los datos requeridos para el registro.
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
            guard let email = alert.textFields?[0].text, !email.isEmpty,
                  let password = alert.textFields?[1].text, !password.isEmpty,
                  let nombre = alert.textFields?[2].text, !nombre.isEmpty,
                  let apellidos = alert.textFields?[3].text, !apellidos.isEmpty else {
                self.showAlert(title: "Campos vacíos", message: "Por favor ingresa todos los datos.")
                return
            }
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email) {
                self.showAlert(title: "Correo inválido", message: "Ingresa un correo electrónico válido.")
                return
            }
            
            if password.count < 6 {
                self.showAlert(title: "Contraseña débil", message: "La contraseña debe tener al menos 6 caracteres.")
                return
            }
            
            let nombreCapitalizado = nombre.capitalizedFirstLetter
            let apellidosCapitalizados = apellidos.capitalizedFirstLetter
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error al registrar usuario: \(error.localizedDescription)")
                    self.showAlert(title: "Error de registro", message: "Hubo un problema al registrar el usuario.")
                    return
                }
                
                let uid = result?.user.uid ?? ""
                
                // Guardar datos en Firestore
                self.guardarUsuarioEnFirestore(uid: uid, email: email, nombre: nombreCapitalizado, apellidos: apellidosCapitalizados)
                
                // Guarda en CoreData
                self.guardarUsuarioEnCoreData(uid: uid, email: email, provider: .basic, nombre: nombreCapitalizado, apellidos: apellidosCapitalizados)
                
                let successAlert = UIAlertController(title: "¡Registro exitoso!", message: "Bienvenid@, \(nombreCapitalizado).", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                    self.showHome(result: result, error: error, provider: .basic)
                })
                self.present(successAlert, animated: true, completion: nil)
            }
        }
        
        alert.addAction(registerAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    private func guardarUsuarioEnFirestore(uid: String, email: String, nombre: String, apellidos: String) {
        let db = Firestore.firestore()
        
        // Referencia al documento del usuario en la colección "usuarios"
        let usuarioRef = db.collection("usuarios").document(uid)
        
        // Datos que deseas guardar
        let datosUsuario: [String: Any] = [
            "email": email,
            "nombre": nombre,
            "apellidos": apellidos,
            "uid": uid,
            "fechaRegistro": Timestamp()
        ]
        
        // Guardar los datos
        usuarioRef.setData(datosUsuario) { error in
            if let error = error {
                print("Error al guardar en Firestore: \(error.localizedDescription)")
            } else {
                print("Usuario guardado en Firestore")
            }
        }
    }

    
    /// Acción para la autenticación con Google.
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
            
            // Autenticarse en Firebase con Google
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error al autenticar con Firebase: \(error.localizedDescription)")
                    return
                }
                
                // Extraer la información del usuario
                let fullName = user.profile?.name ?? "Sin nombre"
                let nameComponents = fullName.split(separator: " ", maxSplits: 1).map { String($0) }
                let nombre = nameComponents.first ?? "Sin nombre"
                let apellidos = nameComponents.count > 1 ? nameComponents[1] : "Sin apellidos"
                
                // Guardar el usuario en Firestore
                if let uid = result?.user.uid {
                    self.guardarUsuarioEnFirestore(uid: uid, email: result?.user.email ?? "", nombre: nombre, apellidos: apellidos)
                    
                    // Guardar en Core Data
                    self.guardarUsuarioEnCoreData(uid: uid, email: result?.user.email, provider: .google, nombre: nombre, apellidos: apellidos)
                }
                
                // Mostrar una alerta de bienvenida
                let nombreCapitalizado = nombre.capitalized
                let successAlert = UIAlertController(title: "¡SmallFriends!", message: "Bienvenid@, \(nombreCapitalizado).", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                    self.showHome(result: result, error: error, provider: .google)
                })
                
                self.present(successAlert, animated: true, completion: nil)
            }
        }
    }

    
    /// Acción para la autenticación con Facebook.
    @IBAction func facebookTapped(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut() // Cierra sesión previa.
        
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
                let nombreCompleto = result?.user.displayName ?? "Sin nombre"
                let components = nombreCompleto.split(separator: " ", maxSplits: 1).map { String($0) }
                let nombre = components.first ?? "Sin nombre"
                let apellidos = components.count > 1 ? components[1] : "Sin apellidos"
                
                if let uid = result?.user.uid {
                    self.guardarUsuarioEnCoreData(uid: uid, email: result?.user.email, provider: .facebook, nombre: nombre, apellidos: apellidos)
                }
                self.showHome(result: result, error: error, provider: .facebook)
            }
        }
    }
    
    // MARK: - Funciones auxiliares
    
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
        
        guard let result = result else {
            showAlert(title: "Error", message: "No se pudo iniciar sesión. Intenta más tarde.")
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(result.user.email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        
        imprimirDatosGuardados(uid: result.user.uid)
        authStackView.isHidden = true
        goToMainTabBar()
    }
    
    /// Método que redirige al usuario al controlador de TabBar principal.
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            UIView.transition(with: window,
                              duration: 1,
                              options: .transitionFlipFromRight,
                              animations: {
                window.rootViewController = tabBarController
            }, completion: { _ in
                window.makeKeyAndVisible()
            })
        } else {
            print("No se pudo acceder al SceneDelegate o al window.")
        }
    }
    
    /// Método para mostrar alertas simples.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    /// Función para guardar el usuario en Core Data si no existe.
    private func guardarUsuarioEnCoreData(uid: String, email: String?, provider: ProviderType, nombre: String = "Sin nombre", apellidos: String = "Sin apellidos") {
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
    
    /// Imprimir en consola los datos guardados.
    private func imprimirDatosGuardados(uid: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let contexto = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idUsuario == %@", uid)
        
        do {
            let resultados = try contexto.fetch(fetchRequest)
            
            if let usuarioGuardado = resultados.first {
                print("Datos guardados en Core Data: ")
                print("UID: \(usuarioGuardado.idUsuario ?? "No UID")")
                print("Correo: \(usuarioGuardado.email ?? "No correo")")
                print("Proveedor: \(usuarioGuardado.provider ?? "No proveedor")")
                print("Nombre: \(usuarioGuardado.nombre ?? "No nombre")")
                print("Apellidos: \(usuarioGuardado.apellidos ?? "No apellidos")")
            } else {
                print("No se encontró el usuario con UID: \(uid)")
            }
        } catch {
            print("Error al recuperar datos de Core Data: \(error.localizedDescription)")
        }
    }
}
