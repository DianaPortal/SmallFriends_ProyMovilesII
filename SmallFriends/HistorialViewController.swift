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
        HistorialDatos(fecha: "10 de febrero, 2025", tipo: "Consulta", diagnostico: "Sin datos", sede: "Clinica", tratamiento: "Sin tratamiento")
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
    @IBAction func agregarHistorialTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nuevo registro", message: nil, preferredStyle: .alert)
        alert.addTextField{
            textFile in textFile.placeholder = "Fecha";
        }
        alert.addTextField{
            textFile in textFile.placeholder = "Tipo";
        }
        alert.addTextField{
            textFile in textFile.placeholder = "Diagnostico";
        }
        alert.addTextField{
            textFile in textFile.placeholder = "Sede";
        }
        alert.addTextField{
            textFile in textFile.placeholder = "Tratamiento";
        }
        alert.addAction(UIAlertAction(title: "Agregar", style: .default) {
            _ in guard let fecha = alert.textFields?.first?.text,!fecha.isEmpty else {return}
            let nuevoRegistro = HistorialDatos(fecha: fecha, tipo: "tipo", diagnostico: "diag", sede: "se", tratamiento: "tra")
            self.datos.append(nuevoRegistro)
            self.tablaHistorial.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
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
