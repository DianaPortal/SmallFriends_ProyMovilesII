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
        // title = "Autenticación"
        
        // Comprobar sesión guardada
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "email"),
           let _ = defaults.string(forKey: "provider") {
            authStackView.isHidden = true
            // Si hay sesión, va directamente al inicio
            goToMainTabBar()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Mostrar login si no hay sesión activa
        authStackView.isHidden = false
    }
    
    // MARK: - Acciones
    // Btn Iniciar sesión con correo y contraseña
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
            
            // Mostrar alerta de éxito y bienvenida al iniciar sesión
            successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                // Aquí sí validamos bien el resultado
                self.goToMainTabBar()
                self.showHome(result: result, error: error, provider: .basic)
            })
            
            self.present(successAlert, animated: true, completion: nil)
            
        }
        
    }
    // Botón ¿Olvidaste tu contraseña?
    @IBAction func olvidastePasswordTapped(_ sender: UIButton) {
        // Mostrar un alert para que el usuario ingrese su correo electrónico
        let alert = UIAlertController(title: "Recuperar Contraseña", message: "Ingresa tu correo para enviar un enlace de recuperación.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Correo electrónico"
            textField.keyboardType = .emailAddress
        }
        // Acción para enviar el enlace de recuperación
        let resetAction = UIAlertAction(title: "Enviar enlace", style: .default) { _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else {
                self.showAlert(title: "Campo vacío", message: "Por favor ingresa un correo electrónico.")
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    // Si hay un error al enviar el enlace
                    self.showAlert(title: "Error", message: error.localizedDescription)
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
    
    
    // Botón para registrar un nuevo usuario
    @IBAction func registrarseTapped(_ sender: UIButton) {
        //Mostrar alerta para registrar Usuario
        let alert = UIAlertController(title: "Registro Usuario", message: "Ingresa tus datos", preferredStyle: .alert)
        // Campos: correo, contraseña, nombre y apellidos
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
            
            // Validación de correo electrónico
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email) {
                self.showAlert(title: "Correo inválido", message: "Ingresa un correo electrónico válido.")
                return
            }
            
            // Validación de longitud de contraseña
            if password.count < 6 {
                self.showAlert(title: "Contraseña débil", message: "La contraseña debe tener al menos 6 caracteres.")
                return
            }
            
            // Capitalizar nombre y apellido
            let nombreCapitalizado = nombre.capitalizedFirstLetter
            let apellidosCapitalizados = apellidos.capitalizedFirstLetter
            
            // Crear usuario en Firebase Auth
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error al registrar usuario: \(error.localizedDescription)")
                    self.showAlert(title: "Error de registro", message: "Hubo un problema al registrar el usuario.")
                    return
                }
                
                // Guardar el usuario en Core Data
                let uid = result?.user.uid ?? ""
                self.guardarUsuarioEnCoreData(uid: uid, email: email, provider: .basic, nombre: nombreCapitalizado, apellidos: apellidosCapitalizados)
                
                // Mostrar alerta de éxito antes de redirigir
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
    
    // Botón para autenticación con Google
    @IBAction func googleTapped(_ sender: UIButton) {
        let presentingVC = self.presentingViewController ?? self.navigationController ?? self
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Error en SignIn de Google: \(error.localizedDescription)")
                return
            }
            
            // Obtener credenciales de Google
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("No se pudo obtener el ID Token de Google.")
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            // Autenticación con Firebase
            Auth.auth().signIn(with: credential) { result, error in
                // Obtener nombre y apellidos desde Google
                let fullName = user.profile?.name ?? "Sin nombre"
                let nameComponents = fullName.split(separator: " ", maxSplits: 1).map { String($0) }
                let nombre = nameComponents.first ?? "Sin nombre"
                let apellidos = nameComponents.count > 1 ? nameComponents[1] : "Sin apellidos"
                
                if let uid = result?.user.uid {
                    self.guardarUsuarioEnCoreData(uid: uid, email: result?.user.email, provider: .google, nombre: nombre, apellidos: apellidos)
                }
                // Capitalizar nombre y apellidos
                let nombreCapitalizado = nombre.capitalized
                
                let successAlert = UIAlertController(title: "¡SmallFriends!", message: "Bienvenid@, \(nombreCapitalizado).", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Ir al inicio", style: .default) { _ in
                    self.showHome(result: result, error: error, provider: .google)
                })
                
                self.present(successAlert, animated: true, completion: nil)
            }
        }
    }
    
    // Botón para autenticación con Facebook
    @IBAction func facebookTapped(_ sender: UIButton) {
        let loginManager = LoginManager()
        // Cierra sesión previa
        loginManager.logOut()
        
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
                // Obtener nombre desde el usuario autenticado
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
    
    // Función principal que maneja post-autenticación y redirección
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
        
        // Autenticación
        guard let result = result else {
            showAlert(title: "Error", message: "No se pudo iniciar sesión. Intenta más tarde.")
            return
        }
        // Guarda la sesión en UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(result.user.email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        
        imprimirDatosGuardados(uid: result.user.uid)
        
        //Redigir al MainTabBarController después de iniciar sesión correctamente
        authStackView.isHidden = true
        goToMainTabBar()
    }
    
    
    // MARK: - Navegación hacia TabBar principal
    
    private func goToMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("No se pudo instanciar MainTabBarController")
            return
        }
        
        // - SceneDelegate para cambiar el rootViewController
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            // Animación de transición (fade)
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
    
    
    
    // MARK: - Funciones auxiliares
    // Mostrar alertas simples
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // Función para guardar el usuario en Core Data si no existe
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
    
    // Imprimir en consola los datos guardados
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
