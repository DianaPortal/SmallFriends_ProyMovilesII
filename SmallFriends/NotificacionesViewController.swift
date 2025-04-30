//
//  NotificacionesViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import AVFoundation
import UserNotifications

class NotificacionesViewController: UIViewController, UITextViewDelegate{
    
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var mensaje: UITextView!
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        mensaje.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func habilitarNotificaciones(){
        let ac = UIAlertController(title: "¿Habilitar las notificaciones.", message: "Para poder utilizar esta caracteristica, deberas de permitir las notificaciones", preferredStyle: .alert)
        let abrirConfiguracion = UIAlertAction(title: "Ir a la configuracion", style: .default) { _ in guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            
            if (UIApplication.shared.canOpenURL(settingsURL)){
                UIApplication.shared.open(settingsURL) { _ in
                    
                    
                }
            }
        }
        ac.addAction(abrirConfiguracion)
                     self.present(ac, animated: true)
    }
    
    
    @IBAction func programarButton(_ sender: UIButton) {
        notificacionesCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                let title = self.titulo.text ?? ""
                let message = self.mensaje.text ?? ""
                let date = self.datePicker.date
                
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from : date)
                    let triger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: triger)
                    
                    self.notificacionesCenter.add(request) {error in
                        if error != nil {
                            print("Error \(error!.localizedDescription)")
                            return
                        }
                    }
                    
                    let ac = UIAlertController(title: "Notificacion Programada", message: "Para el dia : \(self.formattedDate(date: date))", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.titulo.text = ""
                        self.mensaje.text = ""
                        self.datePicker.date = Date()
                    }))
                    self.present(ac, animated: true)
                } else {
                    self.habilitarNotificaciones()
                }
            }
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    

}
