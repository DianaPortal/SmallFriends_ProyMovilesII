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
    
    @IBOutlet weak var buscarUISearchBar: UISearchBar!
    
    
    
    var eventos: [Eventos] = []
    var eventosFiltrados: [Eventos] = []
    var estaBuscando: Bool = false

        
        override func viewDidLoad() {
            super.viewDidLoad()
            buscarUISearchBar.delegate = self
            buscarUISearchBar.showsCancelButton = true
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
    
    
    
    @IBAction func buscarTapped(_ sender: UIButton) {
        
    }
    
}

    
    



extension ListaEventosAPIViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estaBuscando ? eventosFiltrados.count : eventos.count
    }
    
    
}


extension ListaEventosAPIViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener el evento seleccionado
        let eventoSeleccionado = estaBuscando ? eventosFiltrados[indexPath.row] : eventos[indexPath.row]
               
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

extension ListaEventosAPIViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            estaBuscando = false
            tablaEventos.reloadData()
        } else {
            estaBuscando = true
            eventosFiltrados = eventos.filter { evento in
                return evento.titulo.lowercased().contains(searchText.lowercased()) ||
                       evento.fecha.lowercased().contains(searchText.lowercased())
            }
            tablaEventos.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        estaBuscando = false
        tablaEventos.reloadData()
        searchBar.resignFirstResponder()
    }
}

