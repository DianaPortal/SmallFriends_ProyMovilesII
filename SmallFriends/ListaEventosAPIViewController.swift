//
//  ListaEventosAPIViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

/// Estructura que representa los eventos obtenidos desde la API.
struct Eventos: Codable {
    /// ID único del evento.
    let id: Int
    
    /// Título del evento.
    let titulo: String
    
    /// Fecha del evento en formato de cadena.
    let fecha: String
}

/// Controlador de vista para mostrar una lista de eventos obtenidos desde una API.
class ListaEventosAPIViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// Tabla para mostrar los eventos.
    @IBOutlet weak var tablaEventos: UITableView!
    
    /// Barra de búsqueda para filtrar los eventos.
    @IBOutlet weak var buscarUISearchBar: UISearchBar!
    
    // MARK: - Propiedades
    
    /// Lista de eventos obtenidos desde la API.
    var eventos: [Eventos] = []
    
    /// Lista de eventos filtrados según el texto de búsqueda.
    var eventosFiltrados: [Eventos] = []
    
    /// Indica si el usuario está buscando eventos o no.
    var estaBuscando: Bool = false
    
    // MARK: - Ciclo de vida de la vista
    
    /// Se llama cuando la vista se carga. Configura la barra de búsqueda y la tabla.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configura el delegado de la barra de búsqueda y muestra el botón de cancelar
        buscarUISearchBar.delegate = self
        buscarUISearchBar.showsCancelButton = true
        
        // Configura los delegados y dataSource para la tabla de eventos
        tablaEventos.dataSource = self
        tablaEventos.delegate = self
        
        // Llama a la función para obtener los eventos de la API
        obtenerEventos()
    }
    
    /// Obtiene los eventos de la API y los carga en la tabla.
    func obtenerEventos() {
        // URL de la API de eventos
        guard let url = URL(string: "https://apieventos-17cx.onrender.com/api/eventos") else { return }
        
        // Realiza una solicitud a la API para obtener los eventos
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error)")
                return
            }
            
            guard let data = data else {
                print("No se recibió data")
                return
            }
            
            // Intenta decodificar los datos obtenidos de la API
            do {
                let eventosDecodificados = try JSONDecoder().decode([Eventos].self, from: data)
                DispatchQueue.main.async {
                    // Actualiza la lista de eventos y recarga la tabla
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
    
    /// Devuelve el número de filas en la tabla de eventos. Depende si se está buscando o no.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estaBuscando ? eventosFiltrados.count : eventos.count
    }
    
    /// Configura las celdas de la tabla con la información de los eventos.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mostrarDescripcionEvento", for: indexPath) as! CeldaEventosTableViewCell
        
        // Usa la lista de eventos filtrados si está buscando, o la lista completa si no lo está
        let evento = estaBuscando ? eventosFiltrados[indexPath.row] : eventos[indexPath.row]
        
        // Configura los labels de la celda con el evento correspondiente
        cell.eventoLabel.text = "🆕📍\(evento.titulo)"
        cell.fechaEventoLabel.text = "📅 Fecha: \(evento.fecha)"
        
        // Cambia el título del botón de regreso en la barra de navegación
        let backItem = UIBarButtonItem()
        backItem.title = "Eventos"
        navigationItem.backBarButtonItem = backItem
        
        return cell
    }
    
}

extension ListaEventosAPIViewController: UITableViewDelegate {
    
    /// Acción cuando se selecciona un evento en la tabla. Navega a la vista de detalle.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener el evento seleccionado
        let eventoSeleccionado = estaBuscando ? eventosFiltrados[indexPath.row] : eventos[indexPath.row]
        
        // Instanciar el DetalleEventoViewController manualmente
        let detalleEventoVC = storyboard?.instantiateViewController(withIdentifier: "mostrarDetalleEvento") as! DetalleEventoViewController
        
        // Pasar la información del evento seleccionado a la vista de detalle
        detalleEventoVC.eventoID = eventoSeleccionado.id
        
        // Realizar la navegación
        navigationController?.pushViewController(detalleEventoVC, animated: true)
        
        // Deseleccionar la celda después de la selección
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListaEventosAPIViewController: UISearchBarDelegate {
    
    /// Acción cuando cambia el texto en la barra de búsqueda. Filtra los eventos según el texto de búsqueda.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Si el texto de búsqueda está vacío, muestra todos los eventos
            estaBuscando = false
            tablaEventos.reloadData()
        } else {
            // Si hay texto, filtra los eventos por título o fecha
            estaBuscando = true
            eventosFiltrados = eventos.filter { evento in
                return evento.titulo.lowercased().contains(searchText.lowercased()) ||
                evento.fecha.lowercased().contains(searchText.lowercased())
            }
            tablaEventos.reloadData()
        }
    }
    
    /// Acción cuando se pulsa el botón de cancelar en la barra de búsqueda. Resetea la búsqueda.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        estaBuscando = false
        tablaEventos.reloadData()
        searchBar.resignFirstResponder()
    }
}
