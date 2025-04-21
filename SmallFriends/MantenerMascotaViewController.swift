//
//  MantenerMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class MantenerMascotaViewController: UIViewController {

    var mascotaAEditar: Mascota?
    
    @IBOutlet weak var nombreField: UITextField!
    
    @IBOutlet weak var edadField: UITextField!
    
    @IBOutlet weak var tipoField: UITextField!
    
    @IBOutlet weak var pesoField: UITextField!
    
    @IBOutlet weak var razaField: UITextField!
    
    @IBOutlet weak var dniField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = mascotaAEditar == nil ? "Registrar Mascota" : "Editar Mascota"
        
        cargarDatosParaEditar()
    }
    
    @IBAction func botonGuardarTapped(_ sender: UIButton) {
        guardarMascota()
    }
    
    func cargarDatosParaEditar() {
            guard let mascota = mascotaAEditar else { return }
            nombreField.text = mascota.nombre
            edadField.text = "\(mascota.edad)"
            tipoField.text = mascota.tipo
            pesoField.text = mascota.peso?.stringValue
            razaField.text = mascota.raza
            dniField.text = mascota.dni
        }
    
    @objc func guardarMascota() {
        guard let nombre = nombreField.text, !nombre.isEmpty,
                  let edadTexto = edadField.text, let edad = Int16(edadTexto),
                  let tipo = tipoField.text, !tipo.isEmpty,
                  let pesoTexto = pesoField.text, !pesoTexto.isEmpty,
                  let raza = razaField.text,
                  let dni = dniField.text else {
                return
            }

            let pesoDecimal = NSDecimalNumber(string: pesoTexto)
            guard pesoDecimal != NSDecimalNumber.notANumber else {
                print("Peso inválido")
                return
            }
        
        if let mascota = mascotaAEditar {
            // EDITAR
            mascota.nombre = nombre
            mascota.edad = edad
            mascota.tipo = tipo
            mascota.peso = pesoDecimal
            mascota.raza = raza
            mascota.dni = dni
        } else {
            let nuevaMascota = Mascota(context: CoreDataManager.shared.context)
            nuevaMascota.nombre = nombre
            nuevaMascota.edad = edad
            nuevaMascota.tipo = tipo
            nuevaMascota.peso = pesoDecimal
            nuevaMascota.raza = raza
            nuevaMascota.dni = dni
        }
        
        CoreDataManager.shared.saveContext()
        navigationController?.popViewController(animated: true)
    }
    

}
