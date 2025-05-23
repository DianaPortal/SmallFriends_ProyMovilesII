//
//  DetalleMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class DetalleMascotaViewController: UIViewController {
    
    @IBOutlet weak var mascotaStackView: UIStackView!
    @IBOutlet weak var fotoMascotaIV: UIImageView!
    @IBOutlet weak var nombreMascotaLB: UILabel!
    @IBOutlet weak var edadMascotaTF: UILabel!
    @IBOutlet weak var tipoMascotaTF: UILabel!
    @IBOutlet weak var pesoMascotaTF: UILabel!
    @IBOutlet weak var razaMascotaTF: UILabel!
    @IBOutlet weak var dniMascotaTF: UILabel!
    
    var mascota: Mascota?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Estilizar stack
        mascotaStackView.layer.cornerRadius = 16
        mascotaStackView.layer.borderWidth = 0.5
        mascotaStackView.layer.borderColor = UIColor.systemGray4.cgColor
        mascotaStackView.layer.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7).cgColor
        mascotaStackView.layer.shadowColor = UIColor.black.cgColor
        mascotaStackView.layer.shadowOpacity = 0.1
        mascotaStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mascotaStackView.layer.shadowRadius = 4
        
        mascotaStackView.isLayoutMarginsRelativeArrangement = true
        mascotaStackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 16)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mascotaStackView.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.mascotaStackView.alpha = 1
        }, completion: nil)
        // Verificamos si la propiedad 'mascota' tiene valor
        guard let mascota = mascota else {
            print("La mascota no está asignada")
            return
        }
        if let datosFoto = mascota.foto {
            fotoMascotaIV.image = UIImage(data: datosFoto)
        } else {
            fotoMascotaIV.image = UIImage(named: "perfil_default")
        }
        // RODEAR EL NOMBRE CON 🐶 SI ES PERRO, SINO CON 🐱
        let nombre = mascota.nombre ?? "Sin nombre"
        let tipo = mascota.tipo?.lowercased() ?? ""
        
        if tipo == "perro" {
            nombreMascotaLB.text = "🐶 \(nombre) 🐶"
        } else if tipo == "gato" {
            nombreMascotaLB.text = "🐱 \(nombre) 🐱"
        } else {
            nombreMascotaLB.text = nombre
        }
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
    
    @IBAction func botonActualizarTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mantenerMascotaVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaVC") as? MantenerMascotaViewController {
            
            mantenerMascotaVC.mascotaAEditar = self.mascota
            
            let backItem = UIBarButtonItem()
            backItem.title = "Detalle"
            navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(mantenerMascotaVC, animated: true)
        }
    }
    
}
