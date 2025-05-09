//
//  ListNotificacionesTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//

import UIKit

/// Celda personalizada para mostrar la información de una notificación en una tabla.
class ListNotificacionesTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    /// Vista contenedora de la celda, utilizada para aplicar el estilo visual.
    @IBOutlet weak var containerView: UIView!
    
    /// Etiqueta que muestra el título de la notificación.
    @IBOutlet weak var tituloLabel: UILabel!
    
    /// Etiqueta que muestra la fecha programada de la notificación.
    @IBOutlet weak var fechaLabel: UILabel!
    
    // MARK: - Métodos
    
    /// Método llamado cuando la celda es cargada desde el Nib o el storyboard.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Deshabilita la selección de la celda
        self.selectionStyle = .none
        
        // Fondo transparente para la contentView y la celda
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Estilo visual para la celda: contenedor con bordes redondeados y sombra
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .systemBackground
    }
}
