//  DetalleCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import FirebaseAuth
import CoreData
import UserNotifications

/// Controlador de vista para mostrar los detalles de una cita.
class DetalleCitaViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// Etiqueta que muestra la fecha de la cita.
    @IBOutlet weak var fechaCitaLabel: UILabel!
    
    /// Etiqueta que muestra el nombre de la mascota.
    @IBOutlet weak var mascotaLabel: UILabel!
    
    /// Etiqueta que muestra el lugar de la cita.
    @IBOutlet weak var lugarCitaLabel: UILabel!
    
    /// Etiqueta que muestra el tipo de cita.
    @IBOutlet weak var tipoCitaLabel: UILabel!
    
    /// Etiqueta que muestra la descripción de la cita.
    @IBOutlet weak var descripCitaLabel: UILabel!
    
    /// Vista stack que contiene los detalles de la cita.
    @IBOutlet weak var citaStackView: UIStackView!
    
    // MARK: - Propiedades
    
    /// La cita a mostrar en la vista.
    var cita: CitasCD?
    
    // MARK: - Ciclo de vida de la vista
    
    /// Configura la interfaz cuando la vista se carga.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Estilo visual del contenedor principal
        citaStackView.layer.cornerRadius = 16
        citaStackView.layer.borderWidth = 0.5
        citaStackView.layer.borderColor = UIColor.systemGray4.cgColor
        citaStackView.layer.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7).cgColor
        citaStackView.layer.shadowColor = UIColor.black.cgColor
        citaStackView.layer.shadowOpacity = 0.1
        citaStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        citaStackView.layer.shadowRadius = 4
        
        // Margen interno para el contenido del stack
        citaStackView.isLayoutMarginsRelativeArrangement = true
        citaStackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 16)
    }
    
    /// Se llama antes de que la vista aparezca en pantalla. Carga los detalles de la cita si existe.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Verifica que haya una cita asignada
        guard let cita = cita else {
            print("La cita no está asignada")
            return
        }
        
        // Carga los datos de la cita en las etiquetas
        if let fecha = cita.fechaCita {
            fechaCitaLabel.text = formatearFecha(fecha)
        }
        mascotaLabel.text = cita.mascota?.nombre
        lugarCitaLabel.text = cita.lugarCita
        tipoCitaLabel.text = cita.tipoCita
        descripCitaLabel.text = cita.descripcionCita
    }
    
    // MARK: - Acciones
    
    /// Acción cuando se pulsa el botón "Actualizar".
    /// Navega a la vista de mantenimiento de la cita con los datos de la cita actual.
    @IBAction func botonActualizarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Intenta cargar la vista de mantenimiento de la cita
        if let mantenerCitaVC = storyboard.instantiateViewController(withIdentifier: "showMantenerCita") as? MantenerCitaViewController {
            
            // Pasa la cita actual al nuevo controlador
            mantenerCitaVC.citaAActualizar = self.cita
            
            // Cambia el texto del botón de retroceso en la barra de navegación
            let backItem = UIBarButtonItem()
            backItem.title = "Detalle"
            navigationItem.backBarButtonItem = backItem
            
            // Navega hacia la pantalla de mantenimiento de la cita
            self.navigationController?.pushViewController(mantenerCitaVC, animated: true)
        }
    }
    
    /// Formatea una fecha para mostrarla en un formato específico.
    ///
    /// - Parameter fecha: La fecha que se va a formatear.
    /// - Returns: Una cadena de texto con la fecha y hora formateadas.
    func formatearFecha(_ fecha: Date) -> String {
        let formatterFecha = DateFormatter()
        formatterFecha.locale = Locale(identifier: "es_ES")
        formatterFecha.dateFormat = "d 'de' MMMM 'de' yyyy"
        
        let formatterHora = DateFormatter()
        formatterHora.locale = Locale(identifier: "es_ES")
        formatterHora.dateFormat = "hh:mm a"
        
        let fechaFormateada = formatterFecha.string(from: fecha)
        let horaFormateada = formatterHora.string(from: fecha)
        
        return "\(fechaFormateada) | \(horaFormateada)"
    }
    
    /// Acción cuando se pulsa el botón "Programar Notificación".
    /// Se encarga de verificar los permisos y programar la notificación.
    @IBAction func programarNotifTapped(_ sender: UIButton) {
        print("Botón presionado")
        
        // Verifica el estado de permisos de notificaciones
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                guard let cita = self.cita,
                      let fecha = cita.fechaCita,
                      let tipo = cita.tipoCita,
                      let lugar = cita.lugarCita,
                      let descripcion = cita.descripcionCita,
                      let usuarioID = Auth.auth().currentUser?.uid else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Faltan datos o no has iniciado sesión.")
                    return
                }
                
                // Verifica que la fecha no sea pasada
                if fecha <= Date() {
                    self.mostrarAlerta(titulo: "Fecha inválida", mensaje: "La fecha ya pasó.")
                    return
                }
                
                // Si las notificaciones están autorizadas
                if settings.authorizationStatus == .authorized {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        let context = appDelegate.persistentContainer.viewContext
                        
                        // Consulta para evitar notificaciones duplicadas
                        let fetchRequest: NSFetchRequest<NotificacionCD> = NotificacionCD.fetchRequest()
                        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                            NSPredicate(format: "titulo == %@", "Recordatorio de cita: \(tipo)"),
                            NSPredicate(format: "idUsuario == %@", usuarioID),
                            NSPredicate(format: "fechaProgramada == %@", fecha as NSDate)
                        ])
                        
                        do {
                            let resultados = try context.fetch(fetchRequest)
                            if resultados.count > 0 {
                                self.mostrarAlerta(titulo: "Ya registrado", mensaje: "Esta notificación ya fue programada.")
                                return
                            }
                            
                            // Cambia la apariencia del botón
                            sender.backgroundColor = .systemGreen
                            
                            // Crea el contenido de la notificación
                            let content = UNMutableNotificationContent()
                            content.title = "Recordatorio de cita: \(tipo)"
                            content.body = "Lugar: \(lugar). Descripción: \(descripcion)."
                            content.sound = .default
                            
                            // Define cuándo se disparará la notificación
                            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                            let idNotificacion = UUID().uuidString
                            let request = UNNotificationRequest(identifier: idNotificacion, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if let error = error {
                                    print("Error al programar notificación: \(error.localizedDescription)")
                                }
                            }
                            
                            // Guarda la notificación en Core Data
                            let nuevaNotif = NotificacionCD(context: context)
                            nuevaNotif.titulo = content.title
                            nuevaNotif.cuerpo = content.body
                            nuevaNotif.fechaProgramada = fecha
                            nuevaNotif.idUsuario = usuarioID
                            nuevaNotif.idNotificacion = idNotificacion
                            
                            try context.save()
                            print("Notificación guardada en Core Data")
                            
                            sender.setTitle("Recordatorio guardado", for: .normal)
                            sender.isEnabled = false
                            
                            self.mostrarAlerta(titulo: "Notificación programada", mensaje: "Se ha agendado la cita para \(self.formattedDate(date: fecha))")
                        } catch {
                            print("Error al guardar en Core Data: \(error.localizedDescription)")
                        }
                    }
                } else {
                    // Si el usuario no ha dado permiso para notificaciones
                    self.mostrarAlerta(titulo: "Permiso requerido", mensaje: "Activa las notificaciones en Configuración para usar esta función.")
                }
            }
        }
    }
    
    /// Muestra una alerta con el título y mensaje especificado.
    ///
    /// - Parameters:
    ///   - titulo: El título de la alerta.
    ///   - mensaje: El mensaje de la alerta.
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    /// Formatea una fecha con un estilo corto (para alertas).
    ///
    /// - Parameter date: La fecha a formatear.
    /// - Returns: Una cadena de texto con la fecha formateada en estilo corto.
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}
