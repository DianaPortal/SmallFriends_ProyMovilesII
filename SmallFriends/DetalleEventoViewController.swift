//
//  DetalleEventoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import WebKit
class DetalleEventoViewController: UIViewController {
    var eventoID: Int?
    @IBOutlet weak var tituloEventoLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var fechaEventoLabel: UILabel!
    @IBOutlet weak var horaEventoLabel: UILabel!
    @IBOutlet weak var lugarEventoLabel: UILabel!
    @IBOutlet weak var mapaWKWebView: WKWebView!
    
   
    override func viewDidLoad() {
           super.viewDidLoad()
           if let id = eventoID {
               obtenerDetalleEvento(id: id)
        }
    }
    
    func obtenerDetalleEvento(id: Int) {
           guard let url = URL(string: "https://apieventos-17cx.onrender.com/api/eventos/\(id)") else { return }

           let task = URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error: \(error)")
                   return
               }

               guard let data = data else {
                   print("No se recibió data")
                   return
               }

               do {
                   let detalleEvento = try JSONDecoder().decode(DetalleEvento.self, from: data)
                   DispatchQueue.main.async {
                       self.actualizarUIConEvento(evento: detalleEvento)
                   }
               } catch {
                   print("Error al decodificar: \(error)")
               }
           }
           task.resume()
       }
    
    func actualizarUIConEvento(evento: DetalleEvento) {
        tituloEventoLabel.text = evento.titulo
        descripcionLabel.text = evento.descripcion
        fechaEventoLabel.text = "Fecha: \(evento.fecha)"
        horaEventoLabel.text = "Hora: \(evento.hora)"
        lugarEventoLabel.text = "Lugar: \(evento.ubicacion)"

        // Construir URL para Google Maps con coordenadas
        let urlString = "https://www.google.com/maps?q=\(evento.latitud),\(evento.longitud)"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            print(mapaWKWebView)
            mapaWKWebView.load(request)
        }
    }

    
}
