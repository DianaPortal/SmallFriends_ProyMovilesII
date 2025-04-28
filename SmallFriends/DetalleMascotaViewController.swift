//
//  DetalleMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class DetalleMascotaViewController: UIViewController {

    @IBOutlet weak var fotoMascotaIV: UIImageView!
    @IBOutlet weak var nombreMascotaLB: UILabel!
    @IBOutlet weak var edadMascotaTF: UILabel!
    @IBOutlet weak var tipoMascotaTF: UILabel!
    @IBOutlet weak var pesoMascotaTF: UILabel!
    @IBOutlet weak var razaMascotaTF: UILabel!
    @IBOutlet weak var dniMascotaTF: UILabel!
    
    var mascota: Mascota?
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Verificamos si la propiedad 'mascota' tiene valor
            guard let mascota = mascota else {
                print("La mascota no está asignada.")
                return
            }
            if let datosFoto = mascota.foto {
                fotoMascotaIV.image = UIImage(data: datosFoto)
            } else {
                fotoMascotaIV.image = UIImage(named: "Mascotaswelcome")
            }
            nombreMascotaLB.text = "🐶 \(mascota.nombre ?? "Sin nombre") 🐶"
            // PRINT DE EDAD POR SI ES MAYOR A 1 ANIO
            let edad = mascota.edad
            if edad > 1 {
                edadMascotaTF.text = "\(edad) años"
            } else {
                edadMascotaTF.text = "\(edad) año"
            }
            tipoMascotaTF.text = mascota.tipo ?? "Tipo no disponible"
            if let peso = mascota.peso {
                pesoMascotaTF.text = "\(peso.stringValue) kg."
            } else {
                pesoMascotaTF.text = "Peso no disponible"
            }
            razaMascotaTF.text = mascota.raza ?? "Sin raza"
            dniMascotaTF.text = mascota.dni ?? "DNI no disponible"
            
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actualizarMascota",
           let destino = segue.destination as? MantenerMascotaViewController {
            destino.mascotaAEditar = mascota
            let backItem = UIBarButtonItem()
                    backItem.title = "Detalle"
                    navigationItem.backBarButtonItem = backItem
        }
    }

}
