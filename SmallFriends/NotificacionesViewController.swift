//
//  NotificacionesViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import AVFoundation
import UserNotifications

class NotificacionesViewController: UIViewController {
    
    
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var mensaje: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let notificacionesCenter = UNUserNotificationCenter.current()
    var reproductor: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensaje.delegate = self
        
        notificacionesCenter.requestAuthorization(options: [.alert, .sound]) { permiso, error in
            if (!permiso){
                DispatchQueue.main.sync {
                    self.habilitarNotificaciones()
                }
            }
        }
        
    }
    
    func habilitarNotificaciones(){
        let ac = UIAlertController(title: "¿Habilitar las notificaciones.", preferredStyle: .alert)
        let abrirConfiguracion = UIAlertAction(title: "Ir a la configuracion", style: .default) { _ in guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            
            if (UIApplication.shared.canOpenURL(settingsURL)){
                UIApplication.shared.open(settingsURL) {
                    
                }
            }
        }
    }
    
    
    @IBAction func programarButton(_ sender: UIButton) {
    }
    
    

}
