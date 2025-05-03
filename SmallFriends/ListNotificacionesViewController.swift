//
//  ListNotificacionesViewController.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//

import UIKit
import CoreData
import FirebaseAuth
class ListNotificacionesViewController: UIViewController {

   
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

    // MARK: - UICollectionViewDataSource
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
}
   
