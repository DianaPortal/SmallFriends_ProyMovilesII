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
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
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
    }
    
    
    
    //Acciones
    @IBAction func actualizarTapped(_ sender: UIButton) {
    // Cuando se toque el botón "Actualizar", navegar a MantenerCitaViewController
        performSegue(withIdentifier: "showMantenerCita", sender: self)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short  // Puedes cambiar a .long, .medium según prefieras
        dateFormatter.timeStyle = .none  // O puedes configurar la hora si lo necesitas
        return dateFormatter.string(from: fecha)
    }
  
}
