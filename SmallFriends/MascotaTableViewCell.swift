//
//  MascotaTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

/// Celda personalizada para mostrar información de una mascota en la tabla.
class MascotaTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fotoMascotaIV: UIImageView!  // Imagen de la mascota.
    @IBOutlet weak var detalleMascotaLabel: UILabel!  // Etiqueta que muestra los detalles de la mascota.
    
    //@IBOutlet weak var detallesMascota: UILabel!  // Esta línea está comentada, posiblemente por un motivo de no uso.
    
    // MARK: - Métodos del ciclo de vida
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Inicialización de la celda cuando se carga desde el storyboard.
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configuración de la vista cuando la celda es seleccionada.
    }
}
