//
//  NotificacionesViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import AVFoundation
import UserNotifications
import CoreData
import FirebaseAuth

class NotificacionesViewController: UIViewController, UITextViewDelegate, UNUserNotificationCenterDelegate{
    

    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titulo: UITextField!
    @IBOutlet weak var mensaje: UITextView!
    
    let notificacionesCenter = UNUserNotificationCenter.current()
    var reproductor: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensaje.delegate = self
        mensaje.text = "Escribe tu mensaje aquí..."
        mensaje.textColor = .lightGray
        
        
        notificacionesCenter.requestAuthorization(options: [.alert, .sound]) { permiso, error in
            if (!permiso){
                DispatchQueue.main.sync {
                    self.habilitarNotificaciones()
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Mostrar alerta y sonido incluso si la app está abierta
        completionHandler([.banner, .list, .sound])
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if mensaje.textColor == .lightGray {
            mensaje.text = ""
            mensaje.textColor = .black
        }
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
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                self.present(ac, animated: true)
    }
    
    
    @IBAction func programarButton(_ sender: UIButton) {
        notificacionesCenter.getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        
                        guard let usuarioID = Auth.auth().currentUser?.uid else {
                            let alerta = UIAlertController(title: "Error", message: "No hay usuario autenticado. Inicia sesión para programar una notificación.", preferredStyle: .alert)
                            alerta.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alerta, animated: true)
                            return
                        }
                        
                        let title = self.titulo.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        let message = self.mensaje.text.trimmingCharacters(in: .whitespacesAndNewlines)
                        let date = self.datePicker.date
                        
                        guard !title.isEmpty, !message.isEmpty else {
                            let alerta = UIAlertController(title: "Campos vacíos", message: "Por favor, completa el título y el mensaje.", preferredStyle: .alert)
                            alerta.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alerta, animated: true)
                            return
                        }
                        
                        if date <= Date() {
                            let alerta = UIAlertController(title: "Fecha inválida", message: "Selecciona una fecha y hora futura.", preferredStyle: .alert)
                            alerta.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alerta, animated: true)
                            return
                        }
                        
                        if settings.authorizationStatus == .authorized {
                            let content = UNMutableNotificationContent()
                            content.title = title
                            content.body = message
                            content.sound = UNNotificationSound.default
                            
                            let identificador = UUID().uuidString
                            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                            let request = UNNotificationRequest(identifier: identificador, content: content, trigger: trigger)

                            self.notificacionesCenter.add(request) { error in
                                if let error = error {
                                    print("Error al agregar notificación: \(error.localizedDescription)")
                                    return
                                }
                            }
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                let context = appDelegate.persistentContainer.viewContext
                                let nuevaNotificacion = NotificacionCD(context: context)
                                nuevaNotificacion.titulo = title
                                nuevaNotificacion.cuerpo = message
                                nuevaNotificacion.fechaProgramada = date
                                nuevaNotificacion.idUsuario = usuarioID
                                nuevaNotificacion.idNotificacion = identificador  // << GUARDAR IDENTIFICADOR

                                do {
                                    try context.save()
                                    print("✅ Notificación guardada en Core Data")
                                } catch {
                                    print("❌ Error al guardar en Core Data: \(error.localizedDescription)")
                                }
                            }
                            
                            let ac = UIAlertController(
                                title: "Notificación Programada",
                                message: "Para el día: \(self.formattedDate(date: date))",
                                preferredStyle: .alert
                            )
                            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                self.titulo.text = ""
                                self.mensaje.text = "Escribe tu mensaje aquí..."
                                self.mensaje.textColor = .lightGray
                                self.datePicker.date = Date()
                                
                                self.navigationController?.popViewController(animated: true)
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
