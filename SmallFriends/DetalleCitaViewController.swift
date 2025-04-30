//
//  DetalleCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class DetalleCitaViewController: UIViewController {

    @IBOutlet weak var fechaCitaLabel: UILabel!
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
    
    // Preparar la transición a MantenerCitaViewController
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMantenerCita" {
            if let destinationVC = segue.destination as? MantenerCitaViewController {
            // Pasamos la cita seleccionada para que se pueda editar
                destinationVC.citaAActualizar = cita
            }
        }
       }
    
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
}
