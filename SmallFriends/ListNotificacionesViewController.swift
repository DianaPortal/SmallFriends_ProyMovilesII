import UIKit
import CoreData
import FirebaseAuth

/// Controlador de vista para gestionar y mostrar las notificaciones programadas del usuario.
class ListNotificacionesViewController: UIViewController {
    
    // MARK: - Propiedades
    
    /// Tabla para mostrar las notificaciones programadas.
    @IBOutlet var tableNotificacionesTableView: UITableView!
    
    /// Arreglo que contiene las notificaciones programadas a mostrar.
    var notificacionesProgramadas: [NotificacionCD] = []
    
    // MARK: - Ciclo de vida de la vista
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notificaciones ‼️"
        
        // Configura el delegado y el origen de datos para la tabla
        tableNotificacionesTableView.delegate = self
        tableNotificacionesTableView.dataSource = self
        
        // Actualizar el listado de notificaciones cuando se reciba la notificación correspondiente
        NotificationCenter.default.addObserver(self, selector: #selector(recargarNotificaciones), name: Notification.Name("ActualizarListadoNotificaciones"), object: nil)
    }
    
    deinit {
        // Elimina el observer cuando la vista se destruye
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ActualizarListadoNotificaciones"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cargar las notificaciones programadas cuando la vista va a aparecer
        cargarNotificacionesProgramadas()
    }
    
    // MARK: - Métodos
    
    /// Navega a la vista de detalles de las notificaciones.
    @IBAction func notificaciones(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let id = "NotificacionesViewController"
        let backItem = UIBarButtonItem()
        backItem.title = "Notificaciones"
        navigationItem.backBarButtonItem = backItem
        
        guard let notificacionesVC = storyboard.instantiateViewController(withIdentifier: id) as? NotificacionesViewController else {
            print("No se pudo instanciar NotificacionesViewController. Verifica el Storyboard ID.")
            return
        }
        
        self.navigationController?.pushViewController(notificacionesVC, animated: true)
    }
    
    /// Carga las notificaciones programadas del usuario autenticado desde Core Data.
    func cargarNotificacionesProgramadas() {
        guard let usuarioID = Auth.auth().currentUser?.uid else {
            print("No se pudo obtener el ID del usuario logueado.")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No se pudo acceder al AppDelegate.")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NotificacionCD> = NotificacionCD.fetchRequest()
        
        // Filtra las notificaciones para obtener solo las futuras del usuario
        let predicate = NSPredicate(format: "idUsuario == %@ AND fechaProgramada > %@", usuarioID, Date() as NSDate)
        fetchRequest.predicate = predicate
        
        // Ordena las notificaciones por fecha
        let sort = NSSortDescriptor(key: "fechaProgramada", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            context.reset()
            
            let notifs = try context.fetch(fetchRequest)
            self.notificacionesProgramadas = notifs
            self.tableNotificacionesTableView.reloadData()
        } catch {
            print("Error al cargar notificaciones: \(error.localizedDescription)")
        }
        
        // Si no hay notificaciones programadas, mostrar un mensaje
        if notificacionesProgramadas.isEmpty {
            tableNotificacionesTableView.setEmptyMessage("No hay notificaciones registradas")
        } else {
            tableNotificacionesTableView.restore()
        }
    }
    
    /// Formatea una fecha para mostrarla en la celda de la tabla.
    func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "hh:mm a 'del' d 'de' MMMM 'de' yyyy"
        return formatter.string(from: fecha)
    }
    
    /// Método que recarga la lista de notificaciones cuando se recibe una notificación correspondiente.
    @objc func recargarNotificaciones() {
        cargarNotificacionesProgramadas()
    }
}

// MARK: - UITableViewDataSource

/// Extensión para conformarse al protocolo `UITableViewDataSource` y manejar los datos de la tabla de notificaciones.
extension ListNotificacionesViewController: UITableViewDataSource {
    
    /// Retorna el número de filas en la tabla (el número de notificaciones programadas).
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificacionesProgramadas.count
    }
    
    /// Configura y devuelve la celda para una fila específica.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "celdaNotificacion", for: indexPath) as? ListNotificacionesTableViewCell else {
            fatalError("No se pudo dequeuar la celda NotificacionTableViewCell")
        }
        
        let notif = notificacionesProgramadas[indexPath.row]
        cell.tituloLabel.text = "📅 \(notif.titulo ?? "Sin titulo")"
        cell.fechaLabel.text = formatearFecha(notif.fechaProgramada ?? Date())
        
        return cell
    }
}

// MARK: - UITableViewDelegate

/// Extensión para conformarse al protocolo `UITableViewDelegate` y manejar la interacción con las celdas de la tabla.
extension ListNotificacionesViewController: UITableViewDelegate {
    
    /// Maneja la selección de una fila en la tabla.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notif = notificacionesProgramadas[indexPath.row]
        print("Notificación seleccionada: \(notif.titulo ?? "Sin título")")
    }
    
    /// Permite eliminar una notificación deslizando hacia la izquierda en una fila.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alerta = UIAlertController(
                title: "Eliminar Notificación",
                message: "¿Estás seguro de que deseas eliminar esta notificación?",
                preferredStyle: .alert
            )
            
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            alerta.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { _ in
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                
                let notificacionAEliminar = self.notificacionesProgramadas[indexPath.row]
                
                // Elimina las notificaciones pendientes y entregadas
                if let id = notificacionAEliminar.idNotificacion {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                    print("🗑️ Eliminadas notificación pendiente y entregada con ID: \(id)")
                }
                
                // Elimina la notificación de Core Data
                context.delete(notificacionAEliminar)
                do {
                    try context.save()
                    self.notificacionesProgramadas.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("Notificación eliminada de Core Data y UI")
                } catch {
                    print("Error al eliminar de Core Data: \(error.localizedDescription)")
                }
            }))
            
            self.present(alerta, animated: true)
        }
    }
}
