//
//  ListaEventosAPIViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

struct Eventos: Codable{
        let id: Int
        let titulo: String
        let fecha: String
   
}

class ListaEventosAPIViewController: UIViewController {

    
    @IBOutlet weak var tablaEventos: UITableView!
    
    var eventos: [Eventos] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tablaEventos.dataSource = self
            tablaEventos.delegate = self
            obtenerEventos()

    }
    

    func obtenerEventos(){
        guard let url = URL(string: "https://apieventos-17cx.onrender.com/api/eventos") else { return }

              let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error en la solicitud: \(error)")
                    return
                }

                guard let data = data else {
                    print("No se recibió data")
                    return
                }

                do {
                    let eventosDecodificados = try JSONDecoder().decode([Eventos].self, from: data)
                    DispatchQueue.main.async {
                        self.eventos = eventosDecodificados
                        self.tablaEventos.reloadData()
                    }
                } catch {
                    print("Error al decodificar JSON: \(error)")
                }
              }
              task.resume()
    }
}

    
    



extension ListaEventosAPIViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mostrarDescripcionEvento", for: indexPath) as! CeldaEventosTableViewCell
        let eventos = eventos[indexPath.row]
        cell.eventoLabel.text = "🆕📍\(eventos.titulo)"
        cell.fechaEventoLabel.text = "📅 Fecha: \(eventos.fecha)"
        return cell
    }
}


extension ListaEventosAPIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener el evento seleccionado
        let eventoSeleccionado = eventos[indexPath.row]
               
        // Instanciar el DetalleEventoViewController manualmente
        let detalleEventoVC = storyboard?.instantiateViewController(withIdentifier: "mostrarDetalleEvento") as! DetalleEventoViewController
               
        // Pasar la información del evento seleccionado
        detalleEventoVC.eventoID = eventoSeleccionado.id
               
        // Realizar la navegación
        navigationController?.pushViewController(detalleEventoVC, animated: true)
               
        // Deseleccionar la celda
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


