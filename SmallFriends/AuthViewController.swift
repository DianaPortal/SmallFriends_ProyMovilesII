//
//  AuthViewController.swift
//  SmallFriends
//
//  Created by DAMII on 13/04/25.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth

class AuthViewController: UIViewController {
    
    
    
    @IBOutlet weak var correoTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Autenticación"
        correoTextField.isSecureTextEntry = false
        // Do any additional setup after loading the view.
        //Analytics Event
        Analytics.logEvent("InitScreen", parameters: ["message":"Integración de Firebase complete"])
    }

    //Acciones
    
    @IBAction func logInButtonAction(_ sender: UIButton) {
        if let email = correoTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password){
                (result, error) in
                
                if let result = result, error == nil {
                    
                    self.navigationController? .pushViewController(HomeViewController(email: result.user.email!, provider: .basic), animated: true)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Se ha producido un error registrando el usuario", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton) {
        if let email = correoTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password){
                (result, error) in
                
                if let result = result, error == nil {
                    
                    self.navigationController? .pushViewController(HomeViewController(email: result.user.email!, provider: .basic), animated: true)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Se ha producido un error registrando el usuario", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
}


