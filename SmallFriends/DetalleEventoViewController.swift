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
    //ID del evento que se va a mostrar
    var eventoID: Int?
    //mapaWKWebView -- mostrar el mapa con mapbox
    var mapaWKWebView: WKWebView!
    // Outlets conectados al storyboard
    @IBOutlet weak var tituloEventoLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var fechaEventoLabel: UILabel!
    @IBOutlet weak var horaEventoLabel: UILabel!
    @IBOutlet weak var lugarEventoLabel: UILabel!
    @IBOutlet weak var recuerdameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configurar el webView para el mapa
        configurarWebView()
        
        
        animarElementos()
        
        //si existe un id evento válido -- obtener detalle del evento
        if let id = eventoID {
            obtenerDetalleEvento(id: id)
        }
    }
    
    //Configurar y posicionar el WKWebView para mostrar el mapa
    func configurarWebView() {
        mapaWKWebView = WKWebView()
        mapaWKWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapaWKWebView)
        
        //Constraints para ubicar el mapa debajo del label de la ubicación
        NSLayoutConstraint.activate([
            mapaWKWebView.topAnchor.constraint(equalTo: lugarEventoLabel.bottomAnchor, constant: 16),
            mapaWKWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapaWKWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapaWKWebView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    //Función para obtener el detalle del evento desde la API
    func obtenerDetalleEvento(id: Int) {
        guard let url = URL(string: "https://apieventos-17cx.onrender.com/api/eventos/\(id)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            //Manejo de errores
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            //Verifica que la respuesta sea válida y con código 200
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Respuesta no válida o error en la solicitud.")
                return
            }
            
            //Verifica que se haya recibido la data
            guard let data = data else {
                print("No se recibió data")
                return
            }
            
            //Decodificar el json recibido en un objeto
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
    //Muestra la información del evento
    func actualizarUIConEvento(evento: DetalleEvento) {
        
        tituloEventoLabel.text = "📅\(evento.titulo)🐾"
        descripcionLabel.text = evento.descripcion
        descripcionLabel.sizeToFit()
        fechaEventoLabel.text = "Fecha: \(evento.fecha)"
        horaEventoLabel.text = "Hora: \(evento.hora)"
        lugarEventoLabel.text = "Lugar: 📍 \(evento.ubicacion)"
        
        //Carga el mapa centrado en la ubicación del evento
        mostrarMapaConMapbox(lat: evento.latitud, lng: evento.longitud)
    }
    
    //Gernera y carga un mapa html usando MapBox con marcador y botón para centrar
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
    
    //Acción del botón "Recuerdame" (Agregar a las notificaciones el evento)
    @IBAction func recuerdame(_ sender: UIButton) {
        print("Botón presionado")
        
        //Verifica permisos de notificación
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                //Confirma que el usuario esté autenticado
                guard let usuarioID = Auth.auth().currentUser?.uid else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Inicia sesión para poder programar recordatorios.")
                    return
                }
                
                //Verifica que existan los datos del evento
                guard let titulo = self.tituloEventoLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let mensaje = self.descripcionLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let fechaTexto = self.fechaEventoLabel.text,
                      let horaTexto = self.horaEventoLabel.text else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Faltan datos del evento.")
                    return
                }
                
                //Combina la fecha y hora en un objeto Date
                let fechaFinal = self.combinarFechaYHora(fecha: fechaTexto, hora: horaTexto)
                
                // Valida que la fecha sea futura
                guard let fecha = fechaFinal, fecha > Date() else {
                    self.mostrarAlerta(titulo: "Fecha inválida", mensaje: "La fecha del evento ya pasó o no es válida.")
                    return
                }
                
                // Si las notificaciones están permitidas
                if settings.authorizationStatus == .authorized {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        let context = appDelegate.persistentContainer.viewContext
                        
                        // Verifica si ya existe la notificación agendada para ese evento
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
                            
                            // Cambia el color del botón como confirmación
                            sender.backgroundColor = .systemGreen
                            // Crea y programa la notificación local
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
                            
                            // Guarda la notificación en Core Data
                            let nuevaNotif = NotificacionCD(context: context)
                            nuevaNotif.titulo = titulo
                            nuevaNotif.cuerpo = mensaje
                            nuevaNotif.fechaProgramada = fecha
                            nuevaNotif.idUsuario = usuarioID
                            
                            try context.save()
                            print("Notificación guardada en Core Data")
                            // Desactiva el botón para evitar duplicados
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
    //Función para - un mensaje emergente (alerta)
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    // Función para formatear una fecha para mostrarla al usuario
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Función para convertir cadenas de fecha y hora a un objeto Date
    func combinarFechaYHora(fecha: String, hora: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let fechaLimpia = fecha.replacingOccurrences(of: "Fecha: ", with: "").trimmingCharacters(in: .whitespaces)
        let horaLimpia = hora.replacingOccurrences(of: "Hora: ", with: "").trimmingCharacters(in: .whitespaces)
        
        let combinada = "\(fechaLimpia) \(horaLimpia)"
        return formatter.date(from: combinada)
    }
    
    // Función para animar la aparición secuencial de los labels
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
