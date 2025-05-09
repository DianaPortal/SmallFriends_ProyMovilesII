//
//  ListadoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseFirestore

/// Vista que maneja la pantalla de listado de mascotas del usuario.
class ListadoViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mascotasTableView: UITableView!
    
    // MARK: - Propiedades
    var mascotas: [Mascota] = []  // Arreglo para almacenar las mascotas del usuario.
    var mascotaSeleccionada: Mascota?  // Mascota seleccionada en la tabla.
    let db = Firestore.firestore()  // Conexión a Firestore para actualización de datos en la base de datos.
    
    // MARK: - Métodos del ciclo de vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Asignación de los delegados de la tabla.
        mascotasTableView.dataSource = self
        mascotasTableView.delegate = self
        print("Pantalla de listado de mascotas cargada")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()  // Cargar las mascotas del usuario cuando la vista está por aparecer.
    }
    
    // MARK: - Acciones de UI
    
    /// Acción cuando el botón de registrar mascota es presionado.
    @IBAction func botonRegistrarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mantenerMascotaVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaVC") as? MantenerMascotaViewController {
            
            // Se pasa un valor nulo para indicar que esta vista está en modo registro.
            mantenerMascotaVC.mascotaAEditar = nil
            
            // Configuración del botón de retroceso.
            let backItem = UIBarButtonItem()
            backItem.title = "Mascotas"
            navigationItem.backBarButtonItem = backItem
            
            // Navegar a la vista de registro de mascota.
            self.navigationController?.pushViewController(mantenerMascotaVC, animated: true)
        }
    }
    
    // MARK: - Métodos de carga de datos
    
    /// Cargar las mascotas del usuario logueado.
    func cargarMascotas() {
        // Verifica si el usuario está logueado.
        guard let usuario = obtenerUsuarioLogueado() else {
            print("No hay usuario logueado.")
            mascotas = []
            mascotasTableView.reloadData()
            return
        }
        
        // Obtener las mascotas del usuario desde CoreData.
        mascotas = CoreDataManager.shared.fetchMascotasDelUsuario(usuario)
        mascotasTableView.reloadData()
        
        // Si no hay mascotas, se muestra un mensaje en la tabla.
        if mascotas.isEmpty {
            mascotasTableView.setEmptyMessage("No hay mascotas registradas")
        } else {
            mascotasTableView.restore()
        }
    }
    
    /// Obtener el usuario actualmente logueado desde UserDefaults.
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
    
    // MARK: - Métodos para Firestore
    
    /// Actualiza el estado de una mascota en Firestore.
    func actualizarEstadoEnFirestore(mascotaID: String, nuevoEstado: String) {
        db.collection("mascotas").document(mascotaID).updateData([
            "estadoMascota": nuevoEstado
        ]) { error in
            if let error = error {
                print("Error al actualizar el estado en Firestore: \(error.localizedDescription)")
            } else {
                print("Estado de la mascota actualizado correctamente en Firestore")
            }
        }
    }
}

// MARK: - Extensiones para UITableViewDataSource y UITableViewDelegate

extension ListadoViewController: UITableViewDataSource {
    
    /// Define el número de filas en la tabla (una fila por mascota).
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }
    
    /// Configura cada celda con los datos de una mascota.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaMascota", for: indexPath) as! MascotaTableViewCell
        let mascota = mascotas[indexPath.row]
        
        // Configuración del detalle de la mascota en la celda.
        let nombre = mascota.nombre ?? "Sin nombre"
        let edadTexto = "Edad: \(mascota.edad) \(mascota.edad == 1 ? "año" : "años")"
        let razaTexto = "Raza: \(mascota.raza ?? "Sin raza")"
        
        let textoCompleto = "\(nombre)\n\(edadTexto)\n\(razaTexto)"
        let textoAtributado = NSMutableAttributedString(string: textoCompleto)
        
        let rangoNombre = (textoCompleto as NSString).range(of: nombre)
        
        // Aplicación de estilos a partes específicas del texto.
        let fuenteNormal = UIFont.italicSystemFont(ofSize: 16)
        textoAtributado.addAttribute(.font, value: fuenteNormal, range: NSMakeRange(0, textoCompleto.count))
        textoAtributado.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: rangoNombre)
        
        // Asigna el texto estilizado a la celda.
        celda.detalleMascotaLabel.attributedText = textoAtributado
        
        // Mostrar la imagen de la mascota si existe, de lo contrario, mostrar imagen predeterminada.
        if let datosFoto = mascota.foto {
            celda.fotoMascotaIV.image = UIImage(data: datosFoto)
        } else {
            celda.fotoMascotaIV.image = UIImage(named: "Mascotaswelcome")
        }
        return celda
    }
}

extension ListadoViewController: UITableViewDelegate {
    
    /// Acción cuando se realiza un swipe para eliminar una mascota.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let cancelarAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            completionHandler(false)
            let mascotaAEliminar = self.mascotas[indexPath.row]
            
            // Alerta de confirmación para eliminar la mascota.
            let alerta = UIAlertController(
                title: "Eliminar Mascota",
                message: "¿Estás seguro de que deseas eliminar de tus mascotas a \"\(mascotaAEliminar.nombre ?? "esta mascota")\"?",
                preferredStyle: .alert
            )
            
            let confirmar = UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                // Cambiar estado de la mascota a "Inactiva" en Core Data y Firestore.
                mascotaAEliminar.estadoMascota = "Inactiva"
                do {
                    try CoreDataManager.shared.context.save()
                    if let mascotaID = mascotaAEliminar.id {
                        self.actualizarEstadoEnFirestore(mascotaID: mascotaID, nuevoEstado: "Inactiva")
                    }
                    // Eliminar la mascota de la lista.
                    self.mascotas.remove(at: indexPath.row)
                    self.mascotasTableView.deleteRows(at: [indexPath], with: .automatic)
                } catch {
                    print("Error al eliminar la mascota: \(error)")
                }
            }
            
            let cancelar = UIAlertAction(title: "Mantener", style: .cancel, handler: nil)
            alerta.addAction(confirmar)
            alerta.addAction(cancelar)
            
            self.present(alerta, animated: true, completion: nil)
        }
        
        cancelarAction.image = UIImage(systemName: "trash")
        cancelarAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [cancelarAction])
    }
    
    /// Acción cuando se selecciona una fila de la tabla para ver el detalle de la mascota.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mascotaSeleccionada = mascotas[indexPath.row]
        let detalleMascotaVC = storyboard?.instantiateViewController(withIdentifier: "detalleMascota") as! DetalleMascotaViewController
        detalleMascotaVC.mascota = mascotaSeleccionada
        navigationController?.pushViewController(detalleMascotaVC, animated: true)
        
        // Botón de retroceso personalizado.
        let backItem = UIBarButtonItem()
        backItem.title = "Mascotas"
        navigationItem.backBarButtonItem = backItem
    }
}

// MARK: - Extensiones de UITableView para mostrar un mensaje vacío

extension UITableView {
    /// Muestra un mensaje cuando la tabla está vacía.
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.italicSystemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    /// Restaura la tabla a su estado normal.
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
