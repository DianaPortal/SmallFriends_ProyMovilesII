//
//  ListadoCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
class ListadoCitaViewController: UIViewController {

    @IBOutlet weak var tablaCitas: UITableView!
    
    var citas: [CitasCD] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Listado de Citas"

        tablaCitas.dataSource = self
        tablaCitas.delegate = self
                
        print("Pantalla de listado de citas cargada")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarCitas()
    }
    
    
    @IBAction func botonRegistrarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mantenerCitaVC = storyboard.instantiateViewController(withIdentifier: "showMantenerCita") as? MantenerCitaViewController {
                
                // SE PASA UN NULO PARA QUE LA VISTA "MANTENER" ENTIENDA QUE ES UN REGISTRO
                mantenerCitaVC.citaAActualizar = nil

                // BOTON BACK
                let backItem = UIBarButtonItem()
                backItem.title = "Listado"
                navigationItem.backBarButtonItem = backItem

                // NAVEGACION A LA VISTA
                self.navigationController?.pushViewController(mantenerCitaVC, animated: true)
            }
    }
    
    // Función para cargar las citas desde CoreData (UPDATE - AHORA LA FUNCION BUSCA LAS CITAS FILTRANDO POR USUARIO LOGUEADO)
    func cargarCitas() {
        // VERIFICA SI EL USUARIO ESTA LOGUEADO
        guard let usuario = obtenerUsuarioLogueado() else {
                print("No hay usuario logueado.")
                citas = []
                tablaCitas.reloadData()
                return
            }
        
        citas = CoreDataManager.shared.fetchCitasDelUsuario(usuario)
        tablaCitas.reloadData()
        
        if citas.isEmpty {
            tablaCitas.setEmptyMessage("No hay citas registradas")
        } else {
            tablaCitas.restore()
        }
    }
   
    // BUSCAR USUARIO LOGUEADO
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
        
        // Asumiendo que tu modelo de Cita tiene las propiedades `nombre`, `detalle` y `fecha`
        cell.citaLabel.text = cita.tipoCita
        cell.detalleCita.text = formatearFecha(cita.fechaCita ?? Date())
        
        return cell
    }
    
    func formatearFecha(_ fecha: Date) -> String {
        let formatterFecha = DateFormatter()
            formatterFecha.locale = Locale(identifier: "es_ES") // Español
            formatterFecha.dateFormat = "d 'de' MMMM 'de' yyyy" // Ej: 27 de abril de 2025

            let formatterHora = DateFormatter()
            formatterHora.locale = Locale(identifier: "es_ES")
            formatterHora.dateFormat = "hh:mm a" // Ej: 12:01 p. m.

            let fechaFormateada = formatterFecha.string(from: fecha)
            let horaFormateada = formatterHora.string(from: fecha)

            return "\(fechaFormateada) | \(horaFormateada)"
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
    }
    
    // FUNCION PARA CANCELAR CITAS (ELIMINAR LOGICO)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
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
                    self.cargarCitas()
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
