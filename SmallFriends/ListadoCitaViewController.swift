//
//  ListadoCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseFirestore

class ListadoCitaViewController: UIViewController {
    
    @IBOutlet weak var tablaCitas: UITableView!
    
    var citas: [CitasCD] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let db = Firestore.firestore() // Firebase Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaCitas.dataSource = self
        tablaCitas.delegate = self
        
        print("Pantalla de listado de citas cargada")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas() // Recargar citas al volver a la vista
    }
    
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
    
    // Función para cargar las citas desde CoreData (y también para sincronizar con Firestore)
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

    
    // Función para actualizar el estado de la cita en Firestore
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
    
    // Función para obtener el usuario logueado
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citas.count
    }
    
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
    
    func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES") // Español
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy '|' hh:mm a"
        return formatter.string(from: fecha)
    }
}

// MARK: - UITableViewDelegate
extension ListadoCitaViewController: UITableViewDelegate {
    // Método que se llama cuando se selecciona una celda
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
    
    // FUNCION PARA CANCELAR CITAS (ELIMINAR LOGICO)
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
                    
                    if citaAEliminar.id != nil {// Actualizamos Firestore también
                        self.actualizarEstadoCitaEnFirestore(cita: citaAEliminar, nuevoEstado: "Cancelada")
                    }
                    // Recargar las citas después de la cancelación
                    // self.cargarCitas()  // Recargar las citas desde CoreData
                    
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

    
    // CAMBIO DE NOMBRE DEL BOTON DELETE POR "CANCELAR"
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancelar"
    }
}

