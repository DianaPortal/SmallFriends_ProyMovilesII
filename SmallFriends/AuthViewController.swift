//
//  AuthViewController.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//

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
        //Analytics Event
        Analytics.logEvent("InitScreen", parameters: ["message":"Integración de Firebase complete"])
        
        //Comprobar la sesión del usuer autenticado
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String,
           let provider = defaults.value(forKey: "provider") as? String {
            
            //ocultar si ya se incio sesion
            authStackView.isHidden = true
            //Si ya esta logueado navega al controlador que indica que  el usuario ya esta logueado
            navigationController?.pushViewController(HomeViewController(email: email, provider: ProviderType.init(rawValue: provider)!), animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //mostrar login al cerrar sesión
        authStackView.isHidden = false
    }

    //Acciones
    
    @IBAction func logInButtonAction(_ sender: UIButton) {
        if let email = correoTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password){
                (result, error) in
                
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        if let email = correoTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password){
                (result, error) in
                
                self.showHome(result: result, error: error, provider: .basic)
            }
        }
    }
    
    
    @IBAction func googleButtonAction(_ sender: UIButton) {
        // Verifica el controlador desde el cual se presenta la vista
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

                // Acceso directo porque tokenString no es opcional
                let accessToken = user.accessToken.tokenString

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )

                Auth.auth().signIn(with: credential) { result, error in
                    self.showHome(result: result, error: error, provider: .google)
                }
            }
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton){
        let loginManager = LoginManager()
            loginManager.logOut() // Asegura sesión limpia

            loginManager.logIn(permissions: ["email"], from: self) { result, error in
                if let error = error {
                    print("Error en login de Facebook: \(error.localizedDescription)")
                    return
                }

                guard let result = result, !result.isCancelled else {
                    print("Inicio de sesión con Facebook cancelado por el usuario.")
                    return
                }

                guard let token = AccessToken.current?.tokenString else {
                    print("No se pudo obtener el token de acceso de Facebook.")
                    return
                }

                let credential = FacebookAuthProvider.credential(withAccessToken: token)

                Auth.auth().signIn(with: credential) { result, error in
                    self.showHome(result: result, error: error, provider: .facebook)
                }
            }
    }
    //funcion para login
    
    private func showHome(result: AuthDataResult?, error: Error?, provider: ProviderType) {
        if let result = result, error == nil {
            
            self.navigationController? .pushViewController(HomeViewController(email: result.user.email!, provider: provider), animated: true)
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "Se ha producido un error de autenticación mediante \(provider.rawValue)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    
}



