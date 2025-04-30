//
//  ListadoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData

class ListadoViewController: UIViewController {
    
    @IBOutlet weak var mascotasTableView: UITableView!

    var mascotas: [Mascota] = []
    var mascotaSeleccionada: Mascota?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Listado de Mascotas"
        
        mascotasTableView.dataSource = self
        mascotasTableView.delegate = self
        
        print("Pantalla de listado de mascotas cargada")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
    }
    
    @IBAction func botonRegistrarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mantenerMascotaVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaVC") as? MantenerMascotaViewController {
                
                // SE PASA UN NULO PARA QUE LA VISTA "MANTENER" ENTIENDA QUE ES UN REGISTRO
                mantenerMascotaVC.mascotaAEditar = nil

                // BOTON BACK
                let backItem = UIBarButtonItem()
                backItem.title = "Listado"
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                let mascotaAEliminar = mascotas[indexPath.row]
                
                let alerta = UIAlertController(title: "Eliminar Mascota", message: "¿Estás seguro de que deseas eliminar de tus mascotas a \"\(mascotaAEliminar.nombre ?? "esta mascota")\"?",
                                               preferredStyle: .alert)
                
                let confirmar = UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                    CoreDataManager.shared.deleteMascota(mascotaAEliminar)
                    self.cargarMascotas()
                }
                
                let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                
                alerta.addAction(confirmar)
                alerta.addAction(cancelar)
                
                present(alerta, animated: true, completion: nil)
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mascotaSeleccionada = mascotas[indexPath.row]
        let detalleMascotaVC = storyboard?.instantiateViewController(withIdentifier: "detalleMascota") as! DetalleMascotaViewController
        detalleMascotaVC.mascota = mascotaSeleccionada
        navigationController?.pushViewController(detalleMascotaVC, animated: true)
        let backItem = UIBarButtonItem()
        backItem.title = "Listado"
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
