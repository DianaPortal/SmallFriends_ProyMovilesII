//
//  ListadoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

class ListadoViewController: UIViewController {
    
    @IBOutlet weak var mascotasTableView: UITableView!
    
    var mascotas: [Mascota] = []
    var mascotaSeleccionada: Mascota?
    let db = Firestore.firestore()  // Conexión con Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mascotasTableView.dataSource = self
        mascotasTableView.delegate = self
        
        print("Pantalla de listado de mascotas cargada")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Si hay un usuario logueado, sincroniza mascotas
        if let uid = Auth.auth().currentUser?.uid {
            sincronizarMascotasDesdeFirestore(uidUsuario: uid)
        } else {
            cargarMascotas() // Si no hay UID, solo carga lo que haya localmente
        }
    }
    
    @IBAction func botonRegistrarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mantenerMascotaVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaVC") as? MantenerMascotaViewController {
            
            // SE PASA UN NULO PARA QUE LA VISTA "MANTENER" ENTIENDA QUE ES UN REGISTRO
            mantenerMascotaVC.mascotaAEditar = nil
            
            // BOTON BACK
            let backItem = UIBarButtonItem()
            backItem.title = "Mascotas"
            navigationItem.backBarButtonItem = backItem
            
            // NAVEGACION A LA VISTA
            self.navigationController?.pushViewController(mantenerMascotaVC, animated: true)
        }
    }
    
    func cargarMascotas() {
        // VERIFICA SI EL USUARIO ESTA LOGUEADO
        guard let usuario = obtenerUsuarioLogueado() else {
            print("No hay usuario logueado.")
            mascotas = []
            mascotasTableView.reloadData()
            return
        }
        
        mascotas = CoreDataManager.shared.fetchMascotasDelUsuario(usuario)
        mascotasTableView.reloadData()
        
        if mascotas.isEmpty {
            mascotasTableView.setEmptyMessage("No hay mascotas registradas")
        } else {
            mascotasTableView.restore()
        }
    }
    
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
    
    // Nueva función para actualizar el estado de la mascota en Firestore
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
    
    func sincronizarMascotasDesdeFirestore(uidUsuario: String) {
        db.collection("mascotas")
            .whereField("uidUsuario", isEqualTo: uidUsuario)
            .whereField("estadoMascota", isEqualTo: "Activa")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener mascotas desde Firestore: \(error.localizedDescription)")
                    return
                }
                
                guard let documentos = snapshot?.documents else {
                    print("No se encontraron mascotas.")
                    return
                }

                guard let usuario = self.obtenerUsuarioLogueado() else {
                    print("No se pudo encontrar el usuario logueado en Core Data.")
                    return
                }

                for doc in documentos {
                    let data = doc.data()
                    let nombre = data["nombre"] as? String ?? "Sin nombre"
                    let raza = data["raza"] as? String ?? "Sin raza"
                    let edad = data["edad"] as? Int16 ?? 0
                    let estado = data["estadoMascota"] as? String ?? "Activa"
                    let id = doc.documentID
                    
                    // Evitar duplicados
                    if !CoreDataManager.shared.existeMascotaConID(id) {
                        let nuevaMascota = Mascota(context: CoreDataManager.shared.context)
                        nuevaMascota.nombre = nombre
                        nuevaMascota.raza = raza
                        nuevaMascota.edad = edad
                        nuevaMascota.estadoMascota = estado
                        nuevaMascota.id = id
                        nuevaMascota.usuario = usuario
                    }
                }
                
                do {
                    try CoreDataManager.shared.context.save()
                    print("Mascotas sincronizadas con éxito desde Firestore.")
                    self.cargarMascotas()
                } catch {
                    print("Error al guardar mascotas en Core Data: \(error.localizedDescription)")
                }
            }
    }

}

extension ListadoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaMascota", for: indexPath) as! MascotaTableViewCell
        let mascota = mascotas[indexPath.row]
        
        // MARK: ESTRUCTURACION DEL DETALLE DE MASCOTA EN EL LISTADO
        
        // DIVIDE EL DETALLE EN PARTES
        let nombre = mascota.nombre ?? "Sin nombre"
        let edadTexto = "Edad: \(mascota.edad) \(mascota.edad == 1 ? "año" : "años")"
        let razaTexto = "Raza: \(mascota.raza ?? "Sin raza")"
        
        // ESTRUCTURA EL DETALLE JUNTANDO LAS PARTES
        let textoCompleto = "\(nombre)\n\(edadTexto)\n\(razaTexto)"
        
        // CREA NSMutableAttributedString PARA ESTILIZAR PARTES ESPECIFICAS DEL DETALLE
        let textoAtributado = NSMutableAttributedString(string: textoCompleto)
        
        // DEFINE RANGO PARA ESTILIZAR
        let rangoNombre = (textoCompleto as NSString).range(of: nombre)
        
        // APLICA ESTILO ITALIC A TODO MENOS AL NOMBRE
        let fuenteNormal = UIFont.italicSystemFont(ofSize: 16)
        textoAtributado.addAttribute(.font, value: fuenteNormal, range: NSMakeRange(0, textoCompleto.count))
        
        // APLICA ESTILO BOLD AL NOMBRE
        textoAtributado.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: rangoNombre)
        
        // ASIGNA EL TEXTO ESTILIZADO AL LABEL
        celda.detalleMascotaLabel.attributedText = textoAtributado
        
        // MOSTRAR FOTO O IMAGEN POR DEFECTO
        if let datosFoto = mascota.foto {
            celda.fotoMascotaIV.image = UIImage(data: datosFoto)
        } else {
            celda.fotoMascotaIV.image = UIImage(named: "Mascotaswelcome")
        }
        return celda
    }
}

extension ListadoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let cancelarAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            completionHandler(false)
            let mascotaAEliminar = self.mascotas[indexPath.row]
            
            let alerta = UIAlertController(
                title: "Eliminar Mascota",
                message: "¿Estás seguro de que deseas eliminar de tus mascotas a \"\(mascotaAEliminar.nombre ?? "esta mascota")\"?",
                preferredStyle: .alert
            )
            
            let confirmar = UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                // Cambiar estado en Core Data
                mascotaAEliminar.estadoMascota = "Inactiva"
                
                // Guardar cambios en Core Data
                do {
                    try CoreDataManager.shared.context.save()
                    
                    // Verificar si la mascota tiene un documentID en Firestore y actualizarlo
                    if let mascotaID = mascotaAEliminar.id {
                        self.actualizarEstadoEnFirestore(mascotaID: mascotaID, nuevoEstado: "Inactiva")
                    }
                    
                    // Eliminar la mascota de la lista
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mascotaSeleccionada = mascotas[indexPath.row]
        let detalleMascotaVC = storyboard?.instantiateViewController(withIdentifier: "detalleMascota") as! DetalleMascotaViewController
        detalleMascotaVC.mascota = mascotaSeleccionada
        navigationController?.pushViewController(detalleMascotaVC, animated: true)
        // BOTON BACK PERSONALIZADO
        
        let backItem = UIBarButtonItem()
        backItem.title = "Mascotas"
        navigationItem.backBarButtonItem = backItem
    }
}

extension UITableView {
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
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
