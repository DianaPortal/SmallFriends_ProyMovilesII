//
//  DetalleMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

/// Esta clase es responsable de mostrar los detalles de una mascota en una vista.
/// Permite mostrar la información relacionada con la mascota y actualizarla si es necesario.
/// La clase incluye un `UIStackView` que agrupa la información de la mascota, y maneja la interacción con el usuario para permitir la actualización de los datos de la mascota.

class DetalleMascotaViewController: UIViewController {
    
    // MARK: - Outlets

    /// StackView que contiene los elementos de la vista relacionados con la mascota.
    @IBOutlet weak var mascotaStackView: UIStackView!
    
    /// Imagen que muestra la foto de la mascota.
    @IBOutlet weak var fotoMascotaIV: UIImageView!
    
    /// Etiqueta que muestra el nombre de la mascota.
    @IBOutlet weak var nombreMascotaLB: UILabel!
    
    /// Etiqueta que muestra la edad de la mascota.
    @IBOutlet weak var edadMascotaTF: UILabel!
    
    /// Etiqueta que muestra el tipo de la mascota (por ejemplo, perro o gato).
    @IBOutlet weak var tipoMascotaTF: UILabel!
    
    /// Etiqueta que muestra el peso de la mascota.
    @IBOutlet weak var pesoMascotaTF: UILabel!
    
    /// Etiqueta que muestra la raza de la mascota.
    @IBOutlet weak var razaMascotaTF: UILabel!
    
    /// Etiqueta que muestra el DNI de la mascota.
    @IBOutlet weak var dniMascotaTF: UILabel!
    
    /// Objeto que contiene los datos de la mascota a mostrar en la vista.
    var mascota: Mascota?

    // MARK: - Ciclo de vida de la vista

    /// Método que se llama cuando la vista ha sido cargada. Se utiliza para inicializar elementos de la vista, como la estilización del `UIStackView`.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Estilización del UIStackView de la mascota.
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
    
    /// Método que se llama cada vez que la vista aparece en la pantalla. En este caso, se utiliza para animar la opacidad del `UIStackView` y cargar los datos de la mascota.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Animación de aparición suave del stack view.
        mascotaStackView.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.1, options: [.curveEaseInOut], animations: {
            self.mascotaStackView.alpha = 1
        }, completion: nil)
        
        // Verificación de que la propiedad 'mascota' tiene un valor asignado.
        guard let mascota = mascota else {
            print("La mascota no está asignada")
            return
        }
        
        // Configuración de la foto de la mascota.
        if let datosFoto = mascota.foto {
            fotoMascotaIV.image = UIImage(data: datosFoto)
        } else {
            fotoMascotaIV.image = UIImage(named: "perfil_default")
        }
        
        // Configuración del nombre de la mascota con un ícono apropiado según su tipo.
        let nombre = mascota.nombre ?? "Sin nombre"
        let tipo = mascota.tipo?.lowercased() ?? ""
        
        if tipo == "perro" {
            nombreMascotaLB.text = "🐶 \(nombre) 🐶"
        } else if tipo == "gato" {
            nombreMascotaLB.text = "🐱 \(nombre) 🐱"
        } else {
            nombreMascotaLB.text = nombre
        }
        
        // Configuración de la edad de la mascota.
        let edad = mascota.edad
        if edad > 1 {
            edadMascotaTF.text = "\(edad) años"
        } else {
            edadMascotaTF.text = "\(edad) año"
        }
        
        // Configuración del tipo de la mascota.
        tipoMascotaTF.text = mascota.tipo ?? "Tipo no disponible"
        
        // Configuración del peso de la mascota.
        if let peso = mascota.peso {
            pesoMascotaTF.text = "\(peso.stringValue) kg."
        } else {
            pesoMascotaTF.text = "Peso no disponible"
        }
        
        // Configuración de la raza de la mascota.
        razaMascotaTF.text = mascota.raza ?? "Sin raza"
        
        // Configuración del DNI de la mascota.
        dniMascotaTF.text = mascota.dni ?? "DNI no disponible"
    }
    
    // MARK: - Acciones

    /// Acción que se ejecuta cuando el usuario toca el botón para actualizar la mascota. Navega a la vista de mantenimiento de la mascota.
    @IBAction func botonActualizarTapped(_ sender: Any) {
        // Instanciamos el controlador de la vista para editar los datos de la mascota.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mantenerMascotaVC = storyboard.instantiateViewController(withIdentifier: "MantenerMascotaVC") as? MantenerMascotaViewController {
            
            // Pasamos la mascota actual para que se pueda editar.
            mantenerMascotaVC.mascotaAEditar = self.mascota
            
            // Modificamos el título del botón de retroceso.
            let backItem = UIBarButtonItem()
            backItem.title = "Detalle"
            navigationItem.backBarButtonItem = backItem
            
            // Navegamos hacia la vista de mantenimiento de la mascota.
            self.navigationController?.pushViewController(mantenerMascotaVC, animated: true)
        }
    }
}
