import UIKit
import CoreData
import FirebaseAuth

class ListNotificacionesViewController: UIViewController {
    
    @IBOutlet var tableNotificacionesTableView: UITableView!
    
    var notificacionesProgramadas: [NotificacionCD] = []
    
    @IBAction func notificaciones(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let id = "NotificacionesViewController" // Asegúrate de que coincida con el Storyboard ID
        let backItem = UIBarButtonItem()
        backItem.title = "Listado"
        navigationItem.backBarButtonItem = backItem
        guard let notificacionesVC = storyboard.instantiateViewController(withIdentifier: id) as? NotificacionesViewController else {
            print("❌ No se pudo instanciar NotificacionesViewController. Verifica el Storyboard ID.")
            return
        }
        
        self.navigationController?.pushViewController(notificacionesVC, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNotificacionesTableView.delegate = self
        tableNotificacionesTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Cargar las citas programadas
        cargarNotificacionesProgramadas()
        
    }
    
    // Cargar citas programadas del usuario logueado
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
        let predicate = NSPredicate(format: "idUsuario == %@ AND fechaProgramada > %@", usuarioID, Date() as NSDate)
        fetchRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "fechaProgramada", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let notifs = try context.fetch(fetchRequest)
            self.notificacionesProgramadas = notifs
            self.tableNotificacionesTableView.reloadData()
        } catch {
            print("Error al cargar notificaciones: \(error.localizedDescription)")
        }
        
        if notificacionesProgramadas.isEmpty {
            tableNotificacionesTableView.setEmptyMessage("No hay notificaciones registradas")
        } else {
            tableNotificacionesTableView.restore()
        }
    }
    
    func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES") // Español
        formatter.dateFormat = "hh:mm a 'del' d 'de' MMMM 'de' yyyy" // Ej: 03:00 p. m. del 4 de mayo de 2025
        return formatter.string(from: fecha)
    }
}
// MARK: - UITableViewDataSource
extension ListNotificacionesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificacionesProgramadas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "celdaNotificacion", for: indexPath) as? ListNotificacionesTableViewCell else {
            fatalError("No se pudo dequeuar la celda NotificacionTableViewCell")
        }

        let notif = notificacionesProgramadas[indexPath.row]
        cell.tituloLabel.text = notif.titulo
        cell.fechaLabel.text = formatearFecha(notif.fechaProgramada ?? Date())

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListNotificacionesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notif = notificacionesProgramadas[indexPath.row]
        print("Notificación seleccionada: \(notif.titulo ?? "Sin título")")
    }

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
               let context = appDelegate.persistentContainer.viewContext

               let notificacionAEliminar = notificacionesProgramadas[indexPath.row]

               context.delete(notificacionAEliminar)

               do {
                   try context.save()
                   print("✅ Notificación eliminada de Core Data")
                   
                   notificacionesProgramadas.remove(at: indexPath.row)
                   tableView.deleteRows(at: [indexPath], with: .automatic)
               } catch {
                   print("❌ Error al eliminar notificación: \(error.localizedDescription)")
               }
           }
       }
   }
