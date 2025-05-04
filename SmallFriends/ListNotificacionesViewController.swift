import UIKit
import CoreData
import FirebaseAuth

class ListNotificacionesViewController: UIViewController {
   
    @IBAction func notificaciones(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let id = "NotificacionesViewController" // Asegúrate de que coincida con el Storyboard ID

        guard let notificacionesVC = storyboard.instantiateViewController(withIdentifier: id) as? NotificacionesViewController else {
            print("❌ No se pudo instanciar NotificacionesViewController. Verifica el Storyboard ID.")
            return
        }

        self.navigationController?.pushViewController(notificacionesVC, animated: true)
    }

    @IBOutlet var tableNotificacionesTableView: UITableView!
    
    var notificacionesProgramadas: [NotificacionCD] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableNotificacionesTableView.delegate = self
        tableNotificacionesTableView.dataSource = self

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
    }

    func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
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
        cell.descripcionLabel.text = notif.cuerpo
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
