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
    
    
    
    var cita: CitasCD?  // Aquí se almacenará la cita seleccionada
    
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
        guard let cita = cita, let fecha = cita.fechaCita else {
            print("Cita inválida")
            return
        }
        
        if fecha <= Date() {
            let alerta = UIAlertController(title: "Fecha inválida", message: "La cita ya ocurrió.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de cita: \(cita.tipoCita ?? "Sin tipo")"
        content.body = "Lugar: \(cita.lugarCita ?? "No especificado"). Descripción: \(cita.descripcionCita ?? "")."
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error al programar la notificación: \(error.localizedDescription)")
                    let alerta = UIAlertController(title: "Error", message: "No se pudo programar la notificación.", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alerta, animated: true)
                } else {
                    // Guardar en Core Data
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let context = appDelegate.persistentContainer.viewContext
                    let nuevaNotif = NotificacionCD(context: context)
                    
                    nuevaNotif.id = UUID()
                    nuevaNotif.titulo = content.title
                    nuevaNotif.cuerpo = content.body
                    nuevaNotif.fechaProgramada = fecha
                    nuevaNotif.idUsuario = Auth.auth().currentUser?.uid
                    
                    do {
                        try context.save()
                        print("Notificación guardada en Core Data.")
                    } catch {
                        print("Error al guardar la notificación: \(error.localizedDescription)")
                    }
                    
                    let alerta = UIAlertController(title: "Notificación programada", message: "La notificación ha sido agendada.", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alerta, animated: true)
                }
            }
        }
    }
}
