//
//  ListadoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class ListadoViewController: UIViewController {

    var mascotas: [Mascota] = []
    
    @IBOutlet weak var mascotasTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Listado de Mascotas"
        
        mascotasTableView.dataSource = self
        mascotasTableView.delegate = self
        
        print("Pantalla de listado de mascotas cargada")
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotas()
    }
    */
    
    func cargarMascotas() {
        mascotas = CoreDataManager.shared.fetchMascotas()
        mascotasTableView.reloadData()
    }
    
    @IBAction func crearMascota(_ sender: Any) {
        let registroVC = MantenerMascotaViewController()
        navigationController?.pushViewController(registroVC, animated: true)
    }
}

extension ListadoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mascotas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaMascota", for: indexPath) as! MascotaTableViewCell
        let mascota = mascotas[indexPath.row]
        celda.nombreMascotaLabel.text = mascota.nombre
        celda.razaMascotaLabel.text = "Raza: \(mascota.raza ?? "")"
        return celda
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let registroVC = MantenerMascotaViewController()
        registroVC.mascotaAEditar = mascotas[indexPath.row]
        navigationController?.pushViewController(registroVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataManager.shared.deleteMascota(mascotas[indexPath.row])
            cargarMascotas()
        }
    }
}
