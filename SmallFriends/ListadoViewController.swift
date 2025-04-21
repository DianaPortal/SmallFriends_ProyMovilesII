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
        return celda
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registroVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaViewController") as! MantenerMascotaViewController
        registroVC.mascotaAEditar = mascotas[indexPath.row]
        navigationController?.pushViewController(registroVC, animated: true)
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
