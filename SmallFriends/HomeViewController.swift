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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!    
    @IBOutlet weak var closeSessionButton: UIButton!
    
    private let email: String
    private let provider: ProviderType
    
    init(email: String, provider: ProviderType){
        self.email = email
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio"
        
        navigationItem.setHidesBackButton(true, animated: false)
        //Valores que llegan del constructor
        
        correoLabel.text = email
        providerLabel.text = provider.rawValue
        //Guardamos los datos del usuario
        
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
    }


    @IBAction func closeSessionButtonAction(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        
        switch provider {
            
        case .basic:
            firebaseLogOut()
        case .google:
            GIDSignIn.sharedInstance.signOut()
            firebaseLogOut()
        case .facebook:
            LoginManager().logOut()
            firebaseLogOut()
        }
        
        navigationController?.popViewController(animated: true)
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
