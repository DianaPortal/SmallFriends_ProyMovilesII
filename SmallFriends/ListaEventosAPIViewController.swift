//
//  ListaEventosAPIViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

struct Eventos: Codable{
    
        let titulo: String
        let fecha: String
   
}

class ListaEventosAPIViewController: UIViewController {

    
    @IBOutlet weak var tablaEventos: UITableView!
    
    var eventos: [Eventos] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tablaEventos.dataSource = self
            tablaEventos.dataSource = self
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
        cell.eventoLabel.text = eventos.titulo
        cell.fechaEventoLabel.text = eventos.fecha
        return cell
    }
}
