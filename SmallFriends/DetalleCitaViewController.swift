//
//  DetalleCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import FirebaseAuth
import CoreData
import UserNotifications

class DetalleCitaViewController: UIViewController {

    @IBOutlet weak var fechaCitaLabel: UILabel!
    @IBOutlet weak var mascotaLabel: UILabel!
    @IBOutlet weak var lugarCitaLabel: UILabel!
    @IBOutlet weak var tipoCitaLabel: UILabel!
    @IBOutlet weak var descripCitaLabel: UILabel!
    @IBOutlet weak var citaStackView: UIStackView!
    
    
    
    var cita: CitasCD?  // Aquí se almacenará la cita seleccionada
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Estilizar stack
        citaStackView.layer.cornerRadius = 16
        citaStackView.layer.borderWidth = 0.5
        citaStackView.layer.borderColor = UIColor.systemGray4.cgColor
        citaStackView.layer.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7).cgColor
        citaStackView.layer.shadowColor = UIColor.black.cgColor
        citaStackView.layer.shadowOpacity = 0.1
        citaStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        citaStackView.layer.shadowRadius = 4

        citaStackView.isLayoutMarginsRelativeArrangement = true
        citaStackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 16)
    }
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        // Asegurarse de que la cita esté disponible
        if let cita = cita {
        // Asignar los valores de la cita a los UILabels correspondientes
            if let fecha = cita.fechaCita {
                fechaCitaLabel.text = formatearFecha(fecha)
            }
            lugarCitaLabel.text = cita.lugarCita
            tipoCitaLabel.text = cita.tipoCita
            descripCitaLabel.text = cita.descripcionCita
        }
        */
        guard let cita = cita else {
            print("La cita no está asignada")
            return
        }
        if let fecha = cita.fechaCita {
            fechaCitaLabel.text = formatearFecha(fecha)
        }
        lugarCitaLabel.text = cita.lugarCita
        tipoCitaLabel.text = cita.tipoCita
        descripCitaLabel.text = cita.descripcionCita
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
        // Asegurarse de que la cita esté disponible
        if let cita = cita {
        // Asignar los valores de la cita a los UILabels correspondientes
            if let fecha = cita.fechaCita {
                fechaCitaLabel.text = formatearFecha(fecha)
            }
            lugarCitaLabel.text = cita.lugarCita
            tipoCitaLabel.text = cita.tipoCita
            descripCitaLabel.text = cita.descripcionCita
        }
        */
        guard let cita = cita else {
            print("La cita no está asignada")
            return
        }
        if let fecha = cita.fechaCita {
            fechaCitaLabel.text = formatearFecha(fecha)
        }
        mascotaLabel.text = cita.mascota?.nombre
        lugarCitaLabel.text = cita.lugarCita
        tipoCitaLabel.text = cita.tipoCita
        descripCitaLabel.text = cita.descripcionCita
    }
    
    
    
    //Acciones
    /*
    @IBAction func actualizarTapped(_ sender: UIButton) {
    // Cuando se toque el botón "Actualizar", navegar a MantenerCitaViewController
        performSegue(withIdentifier: "showMantenerCita", sender: self)
    }
    */
    
    @IBAction func botonActualizarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mantenerCitaVC = storyboard.instantiateViewController(withIdentifier: "showMantenerCita") as? MantenerCitaViewController {
                
                // Pasar la mascota
                mantenerCitaVC.citaAActualizar = self.cita

                // Opcional: cambiar título del botón de back
                let backItem = UIBarButtonItem()
                backItem.title = "Detalle"
                navigationItem.backBarButtonItem = backItem

                // Mostrar la vista (usando navigationController)
                self.navigationController?.pushViewController(mantenerCitaVC, animated: true)
            }
    }
    
    /*
    // Preparar la transición a MantenerCitaViewController
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMantenerCita" {
            if let destinationVC = segue.destination as? MantenerCitaViewController {
            // Pasamos la cita seleccionada para que se pueda editar
                destinationVC.citaAActualizar = cita
            }
        }
    }
    */
    
    func formatearFecha(_ fecha: Date) -> String {
        let formatterFecha = DateFormatter()
            formatterFecha.locale = Locale(identifier: "es_ES") // Español
            formatterFecha.dateFormat = "d 'de' MMMM 'de' yyyy" // Ej: 27 de abril de 2025

            let formatterHora = DateFormatter()
            formatterHora.locale = Locale(identifier: "es_ES")
            formatterHora.dateFormat = "hh:mm a" // Ej: 12:01 p. m.

            let fechaFormateada = formatterFecha.string(from: fecha)
            let horaFormateada = formatterHora.string(from: fecha)

            return "\(fechaFormateada) | \(horaFormateada)"
    }
    
    @IBAction func programarNotifTapped(_ sender: UIButton) {
        print("✅ Botón presionado")

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

                       if fecha <= Date() {
                           self.mostrarAlerta(titulo: "Fecha inválida", mensaje: "La fecha ya pasó.")
                           return
                       }

                       if settings.authorizationStatus == .authorized {
                           if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                               let context = appDelegate.persistentContainer.viewContext

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

                                   sender.backgroundColor = .systemGreen

                                   let content = UNMutableNotificationContent()
                                   content.title = "Recordatorio de cita: \(tipo)"
                                   content.body = "Lugar: \(lugar). Descripción: \(descripcion)."
                                   content.sound = .default

                                   let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
                                   let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                                   let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                   UNUserNotificationCenter.current().add(request) { error in
                                       if let error = error {
                                           print("❌ Error al programar notificación: \(error.localizedDescription)")
                                       }
                                   }

                                   let nuevaNotif = NotificacionCD(context: context)
                                   nuevaNotif.titulo = content.title
                                   nuevaNotif.cuerpo = content.body
                                   nuevaNotif.fechaProgramada = fecha
                                   nuevaNotif.idUsuario = usuarioID

                                   try context.save()
                                   print("✅ Notificación guardada en Core Data")

                                   sender.setTitle("✅ Recordatorio guardado", for: .normal)
                                   sender.isEnabled = false

                                   self.mostrarAlerta(titulo: "Notificación programada", mensaje: "Se ha agendado la cita para \(self.formattedDate(date: fecha))")
                               } catch {
                                   print("❌ Error al guardar en Core Data: \(error.localizedDescription)")
                               }
                           }
                       } else {
                           self.mostrarAlerta(titulo: "Permiso requerido", mensaje: "Activa las notificaciones en Configuración para usar esta función.")
                       }
                   }
               }
           }

           func mostrarAlerta(titulo: String, mensaje: String) {
               let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true)
           }

           func formattedDate(date: Date) -> String {
               let formatter = DateFormatter()
               formatter.locale = Locale(identifier: "es_ES")
               formatter.dateStyle = .medium
               formatter.timeStyle = .short
               return formatter.string(from: date)
           }
       }


