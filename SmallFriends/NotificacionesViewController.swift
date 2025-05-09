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

/// Vista que permite programar notificaciones para el usuario.
class NotificacionesViewController: UIViewController, UITextViewDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Outlets
    
    /// Controlador para seleccionar la fecha y hora de la notificación.
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /// Campo de texto para ingresar el título de la notificación.
    @IBOutlet weak var titulo: UITextField!
    
    /// Área de texto para ingresar el mensaje de la notificación.
    @IBOutlet weak var mensaje: UITextView!
    
    // MARK: - Propiedades
    
    /// Instancia del centro de notificaciones para gestionar las notificaciones locales.
    let notificacionesCenter = UNUserNotificationCenter.current()
    
    /// Reproductor de audio para reproducir sonidos al recibir una notificación.
    var reproductor: AVAudioPlayer?
    
    // MARK: - Métodos del Ciclo de Vida
    
    /// Método llamado cuando la vista es cargada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración inicial del campo de mensaje
        mensaje.delegate = self
        mensaje.text = "Escribe tu mensaje aquí..."
        mensaje.textColor = .lightGray
        
        // Solicitar permisos para enviar notificaciones
        notificacionesCenter.requestAuthorization(options: [.alert, .sound]) { permiso, error in
            if (!permiso) {
                DispatchQueue.main.sync {
                    self.habilitarNotificaciones()
                }
            }
        }
    }
    
    // MARK: - Métodos de Notificaciones
    
    /// Método que se ejecuta cuando una notificación está por presentarse mientras la aplicación está en primer plano.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Muestra la notificación con un banner, en la lista y con sonido
        completionHandler([.banner, .list, .sound])
    }
    
    // MARK: - Métodos de UITextViewDelegate
    
    /// Se llama cuando el usuario comienza a editar el mensaje en el UITextView.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if mensaje.textColor == .lightGray {
            mensaje.text = ""
            mensaje.textColor = .black
        }
    }
    
    /// Se llama cuando el usuario toca fuera del UITextView para ocultar el teclado.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Funcionalidad de Notificaciones
    
    /// Muestra una alerta para permitir al usuario habilitar las notificaciones si no han sido activadas.
    func habilitarNotificaciones() {
        let ac = UIAlertController(title: "¿Habilitar las notificaciones?",
                                   message: "Para poder utilizar esta característica, deberás de permitir las notificaciones.",
                                   preferredStyle: .alert)
        
        // Acción para abrir la configuración del dispositivo
        let abrirConfiguracion = UIAlertAction(title: "Ir a la configuración", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if (UIApplication.shared.canOpenURL(settingsURL)) {
                UIApplication.shared.open(settingsURL) { _ in }
            }
        }
        
        // Acción para cancelar
        ac.addAction(abrirConfiguracion)
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        self.present(ac, animated: true)
    }
    
    // MARK: - Acciones
    
    /// Acción para programar la notificación cuando el usuario hace clic en el botón "Programar".
    @IBAction func programarButton(_ sender: UIButton) {
        // Verifica la configuración de notificaciones
        notificacionesCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                
                // Verifica si el usuario está autenticado
                guard let usuarioID = Auth.auth().currentUser?.uid else {
                    let alerta = UIAlertController(title: "Error",
                                                   message: "No hay usuario autenticado. Inicia sesión para programar una notificación.",
                                                   preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alerta, animated: true)
                    return
                }
                
                // Recupera el título, mensaje y fecha programada
                let title = self.titulo.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let message = self.mensaje.text.trimmingCharacters(in: .whitespacesAndNewlines)
                let date = self.datePicker.date
                
                // Verifica que el título y mensaje no estén vacíos
                guard !title.isEmpty, !message.isEmpty else {
                    let alerta = UIAlertController(title: "Campos vacíos",
                                                   message: "Por favor, completa el título y el mensaje.",
                                                   preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alerta, animated: true)
                    return
                }
                
                // Verifica que la fecha seleccionada sea futura
                if date <= Date() {
                    let alerta = UIAlertController(title: "Fecha inválida",
                                                   message: "Selecciona una fecha y hora futura.",
                                                   preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alerta, animated: true)
                    return
                }
                
                // Si el usuario ha autorizado las notificaciones, programa la notificación
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.sound = UNNotificationSound.default
                    
                    let identificador = UUID().uuidString
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: identificador, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                    
                    // Guarda la notificación en Core Data
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        let context = appDelegate.persistentContainer.viewContext
                        let nuevaNotificacion = NotificacionCD(context: context)
                        nuevaNotificacion.titulo = title.capitalizedFirstLetter
                        nuevaNotificacion.cuerpo = message.capitalizedFirstLetter
                        nuevaNotificacion.fechaProgramada = date
                        nuevaNotificacion.idUsuario = usuarioID
                        nuevaNotificacion.idNotificacion = identificador
                        
                        do {
                            try context.save()
                            print("Notificación guardada en Core Data")
                        } catch {
                            print("Error al guardar en Core Data: \(error.localizedDescription)")
                        }
                    }
                    
                    // Muestra una alerta confirmando que la notificación fue programada
                    let ac = UIAlertController(
                        title: "Notificación Programada",
                        message: "Para el día: \(self.formattedDate(date: date))",
                        preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // Restablece los campos
                        self.titulo.text = ""
                        self.mensaje.text = "Escribe tu mensaje aquí..."
                        self.mensaje.textColor = .lightGray
                        self.datePicker.date = Date()
                        
                        // Vuelve a la vista anterior
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(ac, animated: true)
                    
                } else {
                    // Si no se han habilitado las notificaciones, pide al usuario habilitarlas
                    self.habilitarNotificaciones()
                }
            }
        }
    }
    
    // MARK: - Métodos de Utilidad
    
    /// Formatea la fecha para mostrarla en un formato legible.
    func formattedDate(date: Date) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
}
