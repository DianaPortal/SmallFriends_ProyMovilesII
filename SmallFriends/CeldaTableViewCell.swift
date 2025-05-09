//
//  CeldaTableViewCell.swift
//  SmallFriends
//
//  Created by Diana on 28/04/25.
//

import UIKit

/// Celda personalizada para mostrar eventos en una tabla.
class CeldaEventosTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    /// Etiqueta que muestra el título del evento.
    @IBOutlet weak var eventoLabel: UILabel!
    
    /// Etiqueta que muestra la fecha del evento.
    @IBOutlet weak var fechaEventoLabel: UILabel!
    
    // MARK: - Métodos del ciclo de vida de la celda
    
    /// Se llama cuando la celda se ha cargado desde el archivo de diseño (.xib o .storyboard).
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Estiliza la celda
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Sombra (en el layer de la celda, no del contentView)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
        // Estilización de las etiquetas de texto
        eventoLabel.font = UIFont.boldSystemFont(ofSize: 17)
        eventoLabel.textColor = UIColor.systemBlue
        
        fechaEventoLabel.font = UIFont.systemFont(ofSize: 15)
        fechaEventoLabel.textColor = UIColor.darkGray
    }
    
    /// Se llama cuando la celda es seleccionada o deseleccionada.
    /// Se utiliza para animar el cambio de color de fondo cuando se selecciona la celda.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animación al seleccionar
        if selected {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = UIColor.systemGray6
            }
        }
    }
    
    /// Ajusta los márgenes de la celda.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Establece un margen entre las celdas
        let margins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
