//
//  NotificationViewController.swift
//  SmallFriends
//
//  Created by DAMII on 20/04/25.
//

import UIKit




class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tablaNotificaciones: UITableView!
    
    
    // Array de notificaciones o tareas pendientes
    var notifications = ["Tarea 1", "Tarea 2", "Tarea 3", "Tarea 4"]
    
    // Conectar la UITableView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la tabla
        tablaNotificaciones.delegate = self
        tablaNotificaciones.dataSource = self
    }
    
    // MARK: - UITableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        
        // Asignar el nombre de la tarea o notificación a la celda
        cell.textLabel?.text = notifications[indexPath.row]
        
        return cell
    }
    
    // MARK: - Acciones de Configuración (Botón de configuración)
    
    @IBAction func configureNotificationsTapped(_ sender: Any) {
        // Aquí podrías abrir una vista para configurar las notificaciones
        print("Configurando notificaciones...")
    }
}
