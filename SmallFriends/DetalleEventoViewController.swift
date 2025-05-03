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
    var mapaWKWebView: WKWebView!
    @IBOutlet weak var tituloEventoLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var fechaEventoLabel: UILabel!
    @IBOutlet weak var horaEventoLabel: UILabel!
    @IBOutlet weak var lugarEventoLabel: UILabel!
    
   
    override func viewDidLoad() {
           super.viewDidLoad()
           configurarWebView()

           if let id = eventoID {
               obtenerDetalleEvento(id: id)
           }
       }

       func configurarWebView() {
           mapaWKWebView = WKWebView()
           mapaWKWebView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(mapaWKWebView)

           NSLayoutConstraint.activate([
               mapaWKWebView.topAnchor.constraint(equalTo: lugarEventoLabel.bottomAnchor, constant: 16),
               mapaWKWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
               mapaWKWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
               mapaWKWebView.heightAnchor.constraint(equalToConstant: 250)
           ])
       }

       func obtenerDetalleEvento(id: Int) {
           guard let url = URL(string: "https://apieventos-17cx.onrender.com/api/eventos/\(id)") else { return }

           let task = URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error: \(error)")
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   print("Error: Respuesta no válida o error en la solicitud.")
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
           print("ID: \(evento.id)")
               print("Título: \(evento.titulo)")
               print("Descripción: \(evento.descripcion)")
               print("Fecha: \(evento.fecha)")
               print("Hora: \(evento.hora)")
               print("Ubicación: \(evento.ubicacion)")
               print("Latitud: \(evento.latitud)")
               print("Longitud: \(evento.longitud)")
           tituloEventoLabel.text = evento.titulo
           descripcionLabel.text = evento.descripcion
           fechaEventoLabel.text = evento.fecha
           horaEventoLabel.text = evento.hora
           lugarEventoLabel.text = evento.ubicacion

           mostrarMapaConMapbox(lat: evento.latitud, lng: evento.longitud)
       }

       func mostrarMapaConMapbox(lat: Double, lng: Double) {
           let html = """
           <!DOCTYPE html>
           <html>
           <head>
               <meta name='viewport' content='initial-scale=1.0, user-scalable=no' />
               <style>
                   body, html { height: 100%; margin: 0; padding: 0; }
                   #map { position:absolute; top:0; bottom:0; width:100%; }
               </style>
               <script src='https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.js'></script>
               <link href='https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.css' rel='stylesheet' />
           </head>
           <body>
               <div id='map'></div>
               <script>
                   mapboxgl.accessToken = 'agregar el token';
                   const map = new mapboxgl.Map({
                       container: 'map',
                       style: 'mapbox://styles/mapbox/streets-v12',
                       center: [\(lng), \(lat)],
                       zoom: 14
                   });
                   new mapboxgl.Marker().setLngLat([\(lng), \(lat)]).addTo(map);
               </script>
           </body>
           </html>
           """

           mapaWKWebView.loadHTMLString(html, baseURL: nil)
       }
    
}
