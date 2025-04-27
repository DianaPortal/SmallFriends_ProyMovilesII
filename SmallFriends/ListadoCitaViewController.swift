//
//  ListadoCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
class ListadoCitaViewController: UIViewController {

    @IBOutlet weak var tablaCitas: UITableView!
    var citas: [CitasCD] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tablaCitas.dataSource = self
        tablaCitas.delegate = self
                
        cargarCitas()
    }
    
    // Función para cargar las citas desde CoreData
    func cargarCitas() {
        let request: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
        do {
            citas = try context.fetch(request)
            tablaCitas.reloadData()
        } catch {
            print("Error al cargar citas: \(error.localizedDescription)")
        }
    }
   
}


// MARK: - UITableViewDataSource
extension ListadoCitaViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaMostrarCitas", for: indexPath) as! CitasTableViewCell
        
        let cita = citas[indexPath.row]
        
        // Asumiendo que tu modelo de Cita tiene las propiedades `nombre`, `detalle` y `fecha`
        cell.citaLabel.text = cita.tipoCita
        cell.detalleCita.text = formatearFecha(cita.fechaCita)
        
        return cell
    }
    
    func formatearFecha(_ fecha: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm" // El formato que prefieras
        if let fecha = fecha {
            return dateFormatter.string(from: fecha)
        } else {
            return "Fecha no disponible"
        }
    }
}

// MARK: - UITableViewDelegate
extension ListadoCitaViewController: UITableViewDelegate {
    // Método que se llama cuando se selecciona una celda
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           // Obtener la cita seleccionada
           let citaSeleccionada = citas[indexPath.row]
           
           // Navegar al DetalleCitaViewController
           let detalleCitaVC = storyboard?.instantiateViewController(withIdentifier: "detalleCita") as! DetalleCitaViewController
           
           // Pasar la información de la cita seleccionada
           detalleCitaVC.cita = citaSeleccionada
           
           // Realizar la navegación
           navigationController?.pushViewController(detalleCitaVC, animated: true)
       }
}
