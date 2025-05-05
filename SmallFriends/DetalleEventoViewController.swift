//
//  DetalleEventoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import WebKit
import UserNotifications
import FirebaseAuth
import CoreData


class DetalleEventoViewController: UIViewController {
    var eventoID: Int?
    var mapaWKWebView: WKWebView!
    @IBOutlet weak var tituloEventoLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var fechaEventoLabel: UILabel!
    @IBOutlet weak var horaEventoLabel: UILabel!
    @IBOutlet weak var lugarEventoLabel: UILabel!
    @IBOutlet weak var recuerdameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarWebView()
        
        animarElementos()
        
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
                    self.animarMapa()
                }
            } catch {
                print("Error al decodificar: \(error)")
            }
        }
        task.resume()
        
    }
    
    func actualizarUIConEvento(evento: DetalleEvento) {
        
        tituloEventoLabel.text = "📅\(evento.titulo)🐾"
        descripcionLabel.text = evento.descripcion
        descripcionLabel.sizeToFit()
        fechaEventoLabel.text = "Fecha: \(evento.fecha)"
        horaEventoLabel.text = "Hora: \(evento.hora)"
        lugarEventoLabel.text = "Lugar: 📍 \(evento.ubicacion)"
        
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
                #recenter {
                    position: absolute;
                    top: 10px;
                    right: 10px;
                    background-color: white;
                    border: none;
                    border-radius: 5px;
                    padding: 10px;
                    font-weight: bold;
                    cursor: pointer;
                    z-index: 1;
                    box-shadow: 0 0 10px rgba(0,0,0,0.2);
                }
            </style>
            <script src='https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.js'></script>
            <link href='https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.css' rel='stylesheet' />
        </head>
        <body>
            <button id="recenter">📍</button>
            <div id='map'></div>
            <script>
                mapboxgl.accessToken = 'pk.eyJ1IjoiZGlhbmFwb3J0YWwiLCJhIjoiY21hODd2NTd6MWVjODJrb281bmJrczNhMSJ9.kn30nowhR02vxckw71iTWg';
                const center = [\(lng), \(lat)];
        
                const map = new mapboxgl.Map({
                    container: 'map',
                    style: 'mapbox://styles/mapbox/streets-v12',
                    center: center,
                    zoom: 14
                });
        
                new mapboxgl.Marker().setLngLat(center).addTo(map);
        
                document.getElementById('recenter').addEventListener('click', function() {
                    map.flyTo({ center: center, zoom: 14 });
                });
            </script>
        </body>
        </html>
        """
        
        mapaWKWebView.loadHTMLString(html, baseURL: nil)
    }
    //GERAB
    
    @IBAction func recuerdame(_ sender: UIButton) {
        print("Botón presionado")
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                guard let usuarioID = Auth.auth().currentUser?.uid else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Inicia sesión para poder programar recordatorios.")
                    return
                }
                
                guard let titulo = self.tituloEventoLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let mensaje = self.descripcionLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let fechaTexto = self.fechaEventoLabel.text,
                      let horaTexto = self.horaEventoLabel.text else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Faltan datos del evento.")
                    return
                }
                
                let fechaFinal = self.combinarFechaYHora(fecha: fechaTexto, hora: horaTexto)
                
                guard let fecha = fechaFinal, fecha > Date() else {
                    self.mostrarAlerta(titulo: "Fecha inválida", mensaje: "La fecha del evento ya pasó o no es válida.")
                    return
                }
                
                if settings.authorizationStatus == .authorized {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        let context = appDelegate.persistentContainer.viewContext
                        
                        let fetchRequest: NSFetchRequest<NotificacionCD> = NotificacionCD.fetchRequest()
                        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                            NSPredicate(format: "titulo == %@", titulo),
                            NSPredicate(format: "idUsuario == %@", usuarioID)
                        ])
                        
                        do {
                            let resultados = try context.fetch(fetchRequest)
                            if resultados.count > 0 {
                                self.mostrarAlerta(titulo: "Ya registrado", mensaje: "Este evento ya ha sido agendado anteriormente.")
                                return
                            }
                            
                            sender.backgroundColor = .systemGreen
                            
                            let content = UNMutableNotificationContent()
                            content.title = titulo
                            content.body = mensaje
                            content.sound = .default
                            
                            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if let error = error {
                                    print("Error al programar notificación: \(error.localizedDescription)")
                                }
                            }
                            
                            let nuevaNotif = NotificacionCD(context: context)
                            nuevaNotif.titulo = titulo
                            nuevaNotif.cuerpo = mensaje
                            nuevaNotif.fechaProgramada = fecha
                            nuevaNotif.idUsuario = usuarioID
                            
                            try context.save()
                            print("Notificación guardada en Core Data")
                            
                            self.recuerdameButton.setTitle("Recordatorio guardado", for: .normal)
                            self.recuerdameButton.isEnabled = false
                            
                            self.mostrarAlerta(titulo: "Recordatorio programado", mensaje: "Se ha agendado el evento correctamente para el día \(self.formattedDate(date: fecha))")
                        } catch {
                            print("Error al guardar en Core Data: \(error.localizedDescription)")
                        }
                    }
                } else {
                    self.mostrarAlerta(titulo: "Permiso requerido", mensaje: "Activa las notificaciones en Configuración para usar esta función.")
                }
            }
        }
    }
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func combinarFechaYHora(fecha: String, hora: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let fechaLimpia = fecha.replacingOccurrences(of: "Fecha: ", with: "").trimmingCharacters(in: .whitespaces)
        let horaLimpia = hora.replacingOccurrences(of: "Hora: ", with: "").trimmingCharacters(in: .whitespaces)
        
        let combinada = "\(fechaLimpia) \(horaLimpia)"
        return formatter.date(from: combinada)
    }
    
    func animarElementos() {
        let delay: TimeInterval = 0.3
        
        // Animaciones
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.tituloEventoLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.tituloEventoLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.0, delay: delay, options: .curveEaseOut, animations: {
            self.descripcionLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.descripcionLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.0, delay: delay * 2, options: .curveEaseOut, animations: {
            self.fechaEventoLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.fechaEventoLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.0, delay: delay * 3, options: .curveEaseOut, animations: {
            self.horaEventoLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.horaEventoLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.0, delay: delay * 4, options: .curveEaseOut, animations: {
            self.lugarEventoLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.lugarEventoLabel.alpha = 1.0
        })
    }
    
    // Animación del mapa al cargar
    func animarMapa() {
        mapaWKWebView.alpha = 0
        UIView.animate(withDuration: 1.0) {
            self.mapaWKWebView.alpha = 1
        }
    }
}
