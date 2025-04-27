//
//  ListaEventosAPIViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

struct EventoCD: Codable {
    let descripcion: String
        let fecha: Date 
        let hora: String
        let id: Int
        let latitud: Double
        let longitud: Double
        let titulo: String
        let ubicacion: String
    /*let titulo: String?
    let fecha: Date*/
}

class ListaEventosAPIViewController: UIViewController {

    
    @IBOutlet weak var tablaEventos: UITableView!
    
    var eventos: [EventoCD] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaEventos.register(UINib(nibName: "CeldaEventoTableViewCell", bundle: nil), forCellReuseIdentifier: "mostrarDescripcionEvento")
        
        tablaEventos.dataSource = self
        tablaEventos.dataSource = self
        obtenerEventos()

    }
    

    func obtenerEventos(){
        let urlString = "https://apieventos-17cx.onrender.com/api/eventos"
        
        // Asegúrate de que la URL sea válida
            guard let url = URL(string: urlString) else {
                return
            }
            
            // Usamos URLSession para obtener los datos
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                // Verificamos si ocurrió un error
                if let error = error {
                    print("Error al obtener datos: \(error.localizedDescription)")
                    return
                }
                
                // Verificamos si tenemos datos
                guard let data = data else {
                    print("No se recibieron datos.")
                    return
                }
                
                // Intentamos decodificar el JSON en un arreglo de EventoCD
                let decodificador = JSONDecoder()
                decodificador.dateDecodingStrategy = .iso8601 // Si las fechas están en formato ISO 8601

                do {
                    let eventos = try decodificador.decode([EventoCD].self, from: data) // Decodificamos un arreglo de EventoCD
                    self.eventos = eventos
                    DispatchQueue.main.async {
                        self.tablaEventos.reloadData() // Recargamos la tabla en el hilo principal
                    }
                } catch {
                    print("Error al decodificar los datos: \(error.localizedDescription)")
                }
            }
            
            task.resume() // Iniciamos la solicitud
        }
        
        
        /*if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url){
                let decodificador = JSONDecoder()
                
                if let datosDecodificados = try? decodificador.decode(EventoCD.self, from: data){
                    //print("datosDecodificados: \(datosDecodificados.articles.count)")
                    
                    eventos = datosDecodificados.showEventos
                    
                    tablaEventos.reloadData()
                }
            }*/
        }
    



extension ListaEventosAPIViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaEventos.dequeueReusableCell(withIdentifier: "mostrarDescripcionEvento", for: indexPath)as! CeldaEventoTableViewCell
        //Asignar el nombre del evento
        celda.nombreEventoLabel.text = eventos[indexPath.row].titulo
        
        // Verificar el tipo de 'fecha' y convertirla si es necesario
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"  // Formato de fecha que prefieras
        celda.fechaEventoLabel.text = dateFormatter.string(from: eventos[indexPath.row].fecha)
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tablaEventos.deselectRow(at: indexPath, animated: true)
    }
    
}
