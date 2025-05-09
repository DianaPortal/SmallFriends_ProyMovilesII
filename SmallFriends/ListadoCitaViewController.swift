//
//  ListadoCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseFirestore

/// Esta clase es responsable de mostrar una lista de citas para el usuario, cargando los datos desde CoreData y Firestore.
/// Permite ver, registrar y cancelar citas, y sincroniza los datos con Firestore para asegurar que se mantengan actualizados en ambos lugares.

class ListadoCitaViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// La tabla que muestra las citas registradas para el usuario.
    @IBOutlet weak var tablaCitas: UITableView!
    
    /// Lista que almacena las citas que se mostrarán en la tabla.
    var citas: [CitasCD] = []
    
    /// Contexto de CoreData para interactuar con la base de datos local.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /// Instancia de Firestore para interactuar con la base de datos de Firebase.
    let db = Firestore.firestore() // Firebase Firestore
    
    // MARK: - Ciclo de vida de la vista
    
    /// Método que se llama cuando la vista ha sido cargada. Se configura la tabla y se realiza un log para indicar que la vista está cargada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaCitas.dataSource = self
        tablaCitas.delegate = self
        
        print("Pantalla de listado de citas cargada")
    }
    
    /// Método que se llama cada vez que la vista está por aparecer en pantalla. Se recargan las citas al volver a la vista.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas() // Recargar citas al volver a la vista
    }
    
    // MARK: - Acciones
    
    /// Acción que se ejecuta cuando el usuario toca el botón de registrar una nueva cita. Navega a la vista de mantenimiento de citas.
    @IBAction func botonRegistrarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mantenerCitaVC = storyboard.instantiateViewController(withIdentifier: "showMantenerCita") as? MantenerCitaViewController {
            
            // SE PASA UN NULO PARA QUE LA VISTA "MANTENER" ENTIENDA QUE ES UN REGISTRO
            mantenerCitaVC.citaAActualizar = nil
            
            // BOTON BACK
            let backItem = UIBarButtonItem()
            backItem.title = "Citas"
            navigationItem.backBarButtonItem = backItem
            
            // NAVEGACION A LA VISTA
            self.navigationController?.pushViewController(mantenerCitaVC, animated: true)
        }
    }
    
    // MARK: - Funciones auxiliares
    
    /// Función que carga las citas asociadas al usuario logueado desde CoreData y sincroniza con Firestore.
    func cargarCitas() {
        guard let usuario = obtenerUsuarioLogueado() else {
            print("No hay usuario logueado.")
            citas = []
            tablaCitas.reloadData()
            return
        }
        
        // Usamos fetchCitasDelUsuario para cargar las citas asociadas al usuario
        citas = CoreDataManager.shared.fetchCitasDelUsuario(usuario)
        
        tablaCitas.reloadData()
        
        if citas.isEmpty {
            tablaCitas.setEmptyMessage("No hay citas registradas")
        } else {
            tablaCitas.restore()
        }
    }
    
    /// Función para actualizar el estado de la cita en Firestore y CoreData.
    func actualizarEstadoCitaEnFirestore(cita: CitasCD, nuevoEstado: String) {
        guard let citaID = cita.id else { return }
        
        db.collection("citas").document(citaID).updateData([
            "estadoCita": nuevoEstado
        ]) { error in
            if let error = error {
                print("Error al actualizar el estado de la cita en Firestore: \(error.localizedDescription)")
            } else {
                print("Estado de la cita actualizado correctamente en Firestore")
                
                // Después de actualizar Firestore, también actualiza el estado en CoreData
                cita.estadoCita = nuevoEstado
                
                // Guardar cambios en CoreData
                do {
                    try CoreDataManager.shared.context.save()
                    // Recargar citas después de la actualización
                    self.cargarCitas() // Esto debería actualizar la vista
                } catch {
                    print("Error al actualizar el estado de la cita en CoreData: \(error)")
                }
            }
        }
    }
    
    /// Función para obtener el usuario logueado desde CoreData.
    func obtenerUsuarioLogueado() -> Usuario? {
        guard let correo = UserDefaults.standard.string(forKey: "email") else { return nil }
        
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", correo)
        
        do {
            return try CoreDataManager.shared.context.fetch(request).first
        } catch {
            print("Error al obtener usuario logueado: \(error)")
            return nil
        }
    }
}

// MARK: - UITableViewDataSource
extension ListadoCitaViewController: UITableViewDataSource {
    
    /// Método que devuelve el número de filas en la tabla (cantidad de citas).
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citas.count
    }
    
    /// Método que configura cada celda en la tabla para mostrar los datos de una cita.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaMostrarCitas", for: indexPath) as! CitasTableViewCell
        
        let cita = citas[indexPath.row]
        
        let mascotaNombre = cita.mascota?.nombre ?? "Mascota desconocida"
        
        // Asumiendo que tu modelo de Cita tiene las propiedades `nombre`, `detalle` y `fecha`
        cell.citaLabel.text = cita.tipoCita
        cell.detalleCita.text = "\(formatearFecha(cita.fechaCita ?? Date()))\n\(mascotaNombre)"
        cell.prepararAnimacion()
        return cell
    }
    
    /// Método que formatea la fecha de la cita para mostrarla en un formato legible.
    func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES") // Español
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy '|' hh:mm a"
        return formatter.string(from: fecha)
    }
}

// MARK: - UITableViewDelegate
extension ListadoCitaViewController: UITableViewDelegate {
    
    /// Método que se llama cuando se selecciona una celda en la tabla. Navega a la vista de detalle de la cita.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener la cita seleccionada
        let citaSeleccionada = citas[indexPath.row]
        
        // Navegar al DetalleCitaViewController
        let detalleCitaVC = storyboard?.instantiateViewController(withIdentifier: "detalleCita") as! DetalleCitaViewController
        
        // Pasar la información de la cita seleccionada
        detalleCitaVC.cita = citaSeleccionada
        
        // Realizar la navegación
        navigationController?.pushViewController(detalleCitaVC, animated: true)
        
        // BOTON BACK PERSONALIZADO
        let backItem = UIBarButtonItem()
        backItem.title = "Citas"
        navigationItem.backBarButtonItem = backItem
    }
    
    /// Función para cancelar una cita (eliminación lógica) con una alerta de confirmación.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let citaAEliminar = citas[indexPath.row]
            
            let alerta = UIAlertController(
                title: "Cancelar Cita",
                message: "¿Estás seguro de que deseas cancelar esta cita?",
                preferredStyle: .alert
            )
            
            let confirmar = UIAlertAction(title: "Cancelar Cita", style: .destructive) { _ in
                citaAEliminar.estadoCita = "Cancelada"
                
                do {
                    try CoreDataManager.shared.context.save()
                    
                    if citaAEliminar.id != nil { // Actualizamos Firestore también
                        self.actualizarEstadoCitaEnFirestore(cita: citaAEliminar, nuevoEstado: "Cancelada")
                    }
                    // Eliminar la cita de la lista
                    self.citas.remove(at: indexPath.row)
                    self.tablaCitas.deleteRows(at: [indexPath], with: .automatic)
                } catch {
                    print("Error al cancelar la cita: \(error)")
                }
            }
            
            let cancelar = UIAlertAction(title: "Mantener", style: .cancel, handler: nil)
            
            alerta.addAction(confirmar)
            alerta.addAction(cancelar)
            
            present(alerta, animated: true, completion: nil)
        }
    }
    
    /// Cambia el nombre del botón de confirmación de eliminación a "Cancelar".
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancelar"
    }
}
