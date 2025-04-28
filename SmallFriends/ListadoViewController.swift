//
//  ListadoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegistrarMascota",
           let destino = segue.destination as? MantenerMascotaViewController {
            destino.mascotaAEditar = nil // Para registrar una nueva mascota
            let backItem = UIBarButtonItem()
            backItem.title = "Listado"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    func cargarMascotas() {
        mascotas = CoreDataManager.shared.fetchMascotas()
        mascotasTableView.reloadData()
        
        if mascotas.isEmpty {
            mascotasTableView.setEmptyMessage("No hay mascotas registradas")
        } else {
            mascotasTableView.restore()
        }
    }
    
    @IBAction func crearMascota(_ sender: Any) {
        let registroVC = MantenerMascotaViewController()
        navigationController?.pushViewController(registroVC, animated: true)
    }
    
}

extension ListadoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaMascota", for: indexPath) as! MascotaTableViewCell
        let mascota = mascotas[indexPath.row]
        celda.nombreMascotaLabel.text = mascota.nombre
        celda.razaMascotaLabel.text = "Raza: \(mascota.raza ?? "Sin raza")"
        
        // Mostrar foto o imagen por defecto
            if let datosFoto = mascota.foto {
                celda.fotoMascotaIV.image = UIImage(data: datosFoto)
            } else {
                celda.fotoMascotaIV.image = UIImage(named: "Mascotaswelcome") // Asegúrate que esté en Assets
            }
        return celda
    }
}

extension ListadoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mascotaAEliminar = mascotas[indexPath.row]
                CoreDataManager.shared.deleteMascota(mascotaAEliminar)
                cargarMascotas()
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
