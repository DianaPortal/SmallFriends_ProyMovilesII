//
//  InicioViewController.swift
//  SmallFriends
//
//  Created by DAMII on 19/04/25.
//

import UIKit

class InicioViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio"
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserViewController" {
            if let userVC = segue.destination as? UserViewController {
                // Recuperar los datos desde UserDefaults
                let defaults = UserDefaults.standard
                if let email = defaults.string(forKey: "email"),
                   let providerString = defaults.string(forKey: "provider"),
                   let provider = ProviderType(rawValue: providerString) {
                    // Pasar los datos al UserViewController
                    userVC.email = email
                    userVC.provider = provider
                }
            }
        }
    }


    @IBAction func perfilTapped(_ sender: UIButton) {
        
    }
}
