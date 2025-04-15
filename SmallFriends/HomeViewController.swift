//
//  HomeViewController.swift
//  SmallFriends
//
//  Created by Diana on 14/04/25.
//

import UIKit
import FirebaseAuth

enum ProviderType: String{
    case basic
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
        
        //Valores que llegan del constructor
        
        correoLabel.text = email
        providerLabel.text = provider.rawValue
    }


    @IBAction func closeSessionButtonAction(_ sender: UIButton) {
        
        switch provider {
            
        case .basic:
            do {
                try Auth.auth().signOut()
                            navigationController?.popViewController(animated: true) } catch {
                                
                //se ha producido un error
                
            }
        }
    }
    
}
/***/
