//
//  HistorialViewController.swift
//  SmallFriends
//
//  Created by DAMII on 19/04/25.
//

import UIKit

class HistorialViewController: UIViewController {

    
    @IBOutlet weak var tablaHistorial: UITableView!
    
    var datos: [HistorialDatos] = [
        HistorialDatos(fecha: "10 de febrero, 2025", tipo: "Consulta"),
        HistorialDatos(fecha: "4 de diciembre, 2024", tipo: "Vacunacion")
    ]
    
    // MARK: Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()

        // Config tabla
        tablaHistorial.dataSource = self
        tablaHistorial.delegate = self
        
        print("Pantalla de historial cargada")
    }
    
    // MARK: Acciones
    @IBAction func volverTapped(_ sender: UIButton){
        // Regresar a la pantalla anterior
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension HistorialViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaRegistroHistorial", for: indexPath) as! HistorialTableViewCell
        let dato = datos[indexPath.row]
        celda.fechaRegistroLabel.text = dato.fecha
        celda.tipoHistorialLabel.text = dato.tipo
        
        return celda
    }
}

extension HistorialViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            datos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
